pageextension 50130 BusinessManagerRCExt extends "Business Manager Role Center"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Favorite Accounts")
        {
            part(SalesQuoteWon; "Sales Quote Status List")
            {
                Caption = 'Your Won Sales Quotes';
                ApplicationArea = all;
                SubPageView = where("Won/Lost Quote Status" = const("Lost"));
            }
            part(SalesQuoteLost; "Sales Quote Status List")
            {
                Caption = 'Your Lost Sales Quotes';
                ApplicationArea = all;
                SubPageView = where("Won/Lost Quote Status" = const("Lost"));
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}