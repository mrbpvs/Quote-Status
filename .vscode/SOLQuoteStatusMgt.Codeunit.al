codeunit 50129 "Quote Status Mgt"
{
    SingleInstance = true;
    procedure CloseQuote(var SalesHeader: Record "Sales Header")
    begin
        ArchiveSalesQuote(SalesHeader);
    end;

    local procedure ArchiveSalesQuote(var SalesHeader: Record "Sales Header")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        SalesSetup.Get();

        case SalesSetup."Archive Quotes" of
            SalesSetup."Archive Quotes"::Always:
                ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);
            SalesSetup."Archive Quotes"::Question:
                ArchiveManagement.ArchiveSalesDocument(SalesHeader);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", 'OnBeforeActionEvent', 'Archive Document', true, true)]
    local procedure OnBeforeActionArchiveDocumentQuote(var Rec: Record "Sales Header")
    var
        ArchiveCanNotBeCompletedErr: Label 'document archive cannot be completed.';
    begin
        RunCloseQuotePage(Rec, ArchiveCanNotBeCompletedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", 'OnBeforeActionEvent', 'MakeOrder', true, true)]
    local procedure OnBeforeActionMakeOrderQuote(var Rec: Record "Sales Header")
    var
        OrderCreationCannoteCompletedErr: Label 'Order creation cannot be completed.';
    begin
        RunCloseQuotePage(Rec, OrderCreationCannoteCompletedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quotes", 'OnBeforeActionEvent', 'MakeOrder', true, true)]
    local procedure OnBeforeActionMakeOrderQuotes(var Rec: Record "Sales Header")
    var
        OrderCreationCannotBeCompletedErr: Label 'document creation cannot be completed.';
    begin
        RunCloseQuotePage(Rec, OrderCreationCannotBeCompletedErr);
    end;

    local procedure RunCloseQuotePage(var SalesHeader: Record "Sales Header"; NotCompltederr: Text)
    begin
        if SalesHeader."Won/Lost Quote Status" <> SalesHeader."Won/Lost Quote Status"::InProgress then
            exit;
        if Page.RunModal(Page::"Sales Quote Status List", SalesHeader) <> Action::LookupOK then
            Error(NotCompltederr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnBeforeSalesHeaderArchiveInsert', '', true, true)]
    local procedure OnBeforeSalesHeaderArchiveInsert(var SalesHeaderArchive: Record "Sales Header Archive"; SalesHeader: Record "Sales Header")
    begin
        if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Quote) then
            exit;

        SalesHeaderArchive.WonLostStatus := SalesHeader."Won/Lost Quote Status";
        SalesHeaderArchive.WonLostDate := SalesHeader.WonLostDate;
        SalesHeaderArchive.WonLostReasonCode := SalesHeader.WonLostReasonCode;
        SalesHeaderArchive.WonLostReasonDesc := SalesHeader.WonLostReasonDesc;
        SalesHeaderArchive.WonLostRemarks := SalesHeader.WonLostRemarks;

    end;

    procedure GetSalesPersonForLoggedInUser(): Code[20]

    var
        User: Record User;
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        User.Reset();
        if not User.Get(UserSecurityId()) then
            exit('');

        if User."Contact Email".Trim() = '' then
            exit('');

        SalesPerson.Reset();
        SalesPerson.SetRange("E-Mail", User."Contact Email");
        if SalesPerson.FindFirst() then
            exit(SalesPerson.Code);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure ShowNotificationInRoleCenter()
    var
        SalespersonCode: Code[20];
        SalesHeader: Record "Sales Header";

    begin
        SalespersonCode := GetSalesPersonForLoggedInUser();

        if SalespersonCode = '' then
            exit;

        // Get won quotes
        GetQuoteRecords(SalesHeader."Won/Lost Quote Status"::Won, SalespersonCode);
        //Get lost quotes
        GetQuoteRecords(SalesHeader."Won/Lost Quote Status"::Lost, SalespersonCode);
    end;

    local procedure GetQuoteRecords(WonLostStatus: Enum "Won/Lost Status "; SalespersonCode: Code[20])
    var
        SalesHeader: Record "Sales Header";
        NoOfrecords: Integer;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Salesperson Code", SalespersonCode);
        SalesHeader.SetRange("Won/Lost Quote Status", WonLostStatus);
        SalesHeader.SetRange(WonLostDate, AddDaystoDateTime(CurrentDateTime(), -5), CurrentDateTime());
        NoOfrecords := SalesHeader.Count();

        if NoOfrecords <> 0 then
            SendNoOfQuoteNotification(NoOfrecords, WonLostStatus, SalespersonCode);
    end;

    local procedure AddDaysToDateTime(SourceDateTime: DateTime; NoOfDays: Integer): DateTime
    begin
        exit(SourceDateTime + (NoOfDays * 86400000));
    end;

    local procedure SendNoOfQuoteNotification(NoOfQuotes: Integer; WonLostStatus: Enum "Won/Lost Status "; SalespersonCode: Code[20])
    var
        QuoteNotification: Notification;
        YouWonLostQuoteMsg: Label 'you %1 ''%2'' quote(s) during the last 5 days.', Comment = '%1 = Won/Lost; %2= No of quotes';
        ShowQuotesLbl: Label 'Show %1 Quotes', Comment = '%1 = Won/Lost';

    begin
        QuoteNotification.Message := StrSubstNo(YouWonLostQuoteMsg, WonLostStatus, NoOfQuotes);
        QuoteNotification.SetData('SalespersonCode', SalespersonCode);
        QuoteNotification.SetData('WonLostStatus', Format(WonLostStatus.AsInteger()));
        QuoteNotification.AddAction(StrSubstNo(ShowQuotesLbl, WonLostStatus), Codeunit::"Quote Status Mgt", 'OpenQuotes');
    end;
}