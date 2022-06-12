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
}