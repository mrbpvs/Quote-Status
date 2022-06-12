pageextension 50124 SalesQuoteExt extends "Sales Quote"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field(WonLostStatus; Rec."Won/Lost Quote Status")
            {

                Editable = false;
                Caption = 'Won/Lost Status';
            }
            field(wonLostDate; Rec.WonLostDate)
            {
                Editable = false;
                Caption = 'Won/lost Date';
            }
            field(WonLostReadonCode; Rec.WonLostReasonCode)
            {
                Editable = false;
                Caption = 'Won/Lost Reason Code';
            }
            field(WonLostReasonDesc; Rec.WonLostReasonDesc)
            {
                Editable = false;
                Caption = 'Won/Lost Reason Description';
            }
            field(WonLostRemarks; Rec.WonLostRemarks)
            {
                Editable = false;
                Caption = 'Won/Lost Remarks';
            }
        }

    }

    actions
    {
        addfirst(Create)
        {
            action(CloseQuote)
            {
                ApplicationArea = all;
                Caption = '&Close Quote';
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Closes the sales quote and archives.';

                trigger OnAction()
                var
                    QuoteStatusMgt: Codeunit "Quote Status Mgt";
                begin
                    if Page.RunModal(Page::"Close Quote", Rec) = Action::LookupOK then
                        QuoteStatusMgt.CloseQuote(Rec);
                end;
            }
        }
    }
}