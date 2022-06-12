page 50129 ShowWonLostQuotes
{
    Caption = 'Show Won/Lost Quotes';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Sales Header";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Rep)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Quote", Rec);
                    end;
                }
                field(SellToCustomerName; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = all;
                    Caption = 'Sell-to Customer Name';
                }
                field(Amount; rec.Amount)
                {
                    ApplicationArea = all;
                    Caption = 'Amount';
                }

                field(WonLostDate; Rec.WonLostDate)
                {
                    ApplicationArea = all;
                    Caption = 'Won/loste Date';
                }
                field(WonLostReason; Rec.WonLostReasonDesc)
                {

                    ApplicationArea = all;
                    Caption = 'Won/Lost Description';
                }
            }
        }
        area(Factboxes)
        {

        }
    }


    trigger OnOpenPage()
    begin
        GetQuotesForCurrentUser();
    end;

    local procedure GetQuotesForCurrentUser()
    var
        QuoteStatusMgt: Codeunit "Quote Status Mgt";
        SalesPersonCode: Code[20];
    begin
        SalesPersonCode := QuoteStatusMgt.GetSalesPersonForLoggedInUser();
        Rec.FilterGroup(2);
        Rec.SetRange("Salesperson Code", SalesPersonCode);
        Rec.FilterGroup(0);
    end;
}