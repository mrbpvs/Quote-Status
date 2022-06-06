pageextension 50125 SalesQuotesExt extends "Sales Quotes"
{
    layout
    {
        // Add changes to page layout here
        addafter("Due Date")
        {
            field(WonLostStatus; Rec.WonLostStatus)
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
}