unit TileControls_Register;

interface

procedure Register;

implementation

uses
  Classes,
  TileBox,
  TileControl;

procedure Register;
begin
  Classes.RegisterClass(TTileControlItem);
  Classes.RegisterClass(TTileControlsCollection);
  Classes.RegisterComponents('WinX Controls', [TTileBox, TTileControl]);
//  RegisterPropertyEditor(TypeInfo(TUsersListBoxItems), TUsersListBox, 'DesignItems', TUsersListBoxProperty);
end;

end.
