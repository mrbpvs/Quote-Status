page 50128 "Close Quote"
{
    PageType = Card;
    Caption = 'Close Quote';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    UsageCategory = None;
    SourceTable = "Sales Header";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
                field(QuoteWon; Rec."Won/Lost Quote Status")
                {
                    ApplicationArea = All;
                    Editable = allowChangeStatus;
                    ToolTip = 'Specifies the status of the quote';
                }
                field("Won/lost Date"; Rec.WonLostDate)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specified the data this quote was closed';
                }
                field("Won/Lost Reason"; Rec.WonLostReasonCode)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the reason closing the quote';
                }
                field("Won/Lost Reason Desc."; Rec.WonLostReasonDesc)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specified the reason closing the quote';
                }
                field("Won/Lost Remarks"; Rec.WonLostRemarks)
                {
                    Caption = 'Remarks';
                    ApplicationArea = all;
                    MultiLine = true;
                    Editable = AllowChangeStatus;
                    ToolTip = 'Specified an extra remark on the quote status';
                }
            }
        }
    }
    var
    AllowChangeStatus: Boolean;
    trigger OnOpenPage()
    begin
    AllowChangeStatus := Rec. "Won/Lost Quote Status" <> Rec."Won/Lost Quote Status"::Won;
    end;

trigger OnQueryClosePage(CloseAction: Action): Boolean
begin
    if CloseAction = Action::LookupOK then
    FinishWizard();
end;

local procedure FinishWizard()
var
MustSelectWonOrLostErr: Label 'You must select either Won or Lost';
FieldMustBeFilledInErr: Label 'You must fill in the %1 field', Comment = '%1 = Caption of the field';
begin
    if not (Rec."Won/Lost Quote Status" in [Rec."Won/Lost Quote Status"::Won, Rec."Won/Lost Quote Status"::Lost]) then
    Error(MustSelectWonOrLostErr);

    if Rec.WonLostReasonCode = '' then
Error(FieldMustBeFilledInErr, Rec.FieldCaption(WonLostReasonCode));
end;
}