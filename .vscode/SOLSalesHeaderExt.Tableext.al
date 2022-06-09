tableextension 50121 SalesHeaderExt extends "Sales Header"
{
    fields
    {
        // Add changes to table fields here
        field(500; "Won/Lost Quote Status"; Enum "Won/Lost Status ")
        {
            DataClassification = CustomerContent;
            Caption = 'Won/Lost Status';

            trigger OnValidate()
            begin
                if WonLostDate = 0DT then
                    WonLostDate := CurrentDateTime();
            end;
        }
        field(501; WonLostDate; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Won/Lost Date';
            Editable = false;
        }
        field(502; WonLostReasonCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Won/Lost Reason Code';
            TableRelation = if ("Won/Lost Quote Status" = const(Won)) "Close Opportunity Code" where(Type = const(Won))
            else
            if ("Won/Lost Quote Status"= const(Lost)) "Close Opportunity Code" where(Type = const(Lost));

            trigger OnValidate()
            begin
                CalcFields(WonLostReasonDesc);
            end;

        }
        field(503; WonLostReasonDesc; Text[100])
        {
            Caption = 'Won/lost Reason Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Close Opportunity Code".Description where(Code = field(WonLostReasonCode)));

        }
        field(504; WonLostRemarks; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Won/Lost Remarks';
        }
    }
}