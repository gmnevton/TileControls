unit uTilesDemoMain;

interface

uses
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  TilesBoxControl,
  ExtCtrls,
  pngimage,
  jpeg, StdCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    RadioButton1: TRadioButton;
    Button3: TButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    TilesBoxControl1: TTilesBoxControl;
    TileControl1: TTileControl;
    TileControl2: TTileControl;
    TileControl3: TTileControl;
    TileControl4: TTileControl;
    TileControl5: TTileControl;
    TileControl6: TTileControl;
    TileControl7: TTileControl;
    TileControl8: TTileControl;
    TileControl9: TTileControl;
    TileControl10: TTileControl;
    TileControl11: TTileControl;
    TileControl12: TTileControl;
    TileControl13: TTileControl;
    TileControl14: TTileControl;
    TileControl15: TTileControl;
    TileControl16: TTileControl;
    TileControl17: TTileControl;
    TileControl18: TTileControl;
    TileControl19: TTileControl;
    TileControl20: TTileControl;
    TileControl21: TTileControl;
    TileControl22: TTileControl;
    TileControl23: TTileControl;
    TileControl24: TTileControl;
    TileControl25: TTileControl;
    TileControl26: TTileControl;
    TileControl27: TTileControl;
    TileControl28: TTileControl;
    TileControl29: TTileControl;
    TileControl30: TTileControl;
    TileControl31: TTileControl;
    TileControl32: TTileControl;
    TileControl33: TTileControl;
    TileControl34: TTileControl;
    TileControl35: TTileControl;
    TileControl36: TTileControl;
    TileControl37: TTileControl;
    TileControl38: TTileControl;
    TileControl39: TTileControl;
    TileControl40: TTileControl;
    TileControl41: TTileControl;
    TileControl42: TTileControl;
    TileControl43: TTileControl;
    TileControl44: TTileControl;
    TileControl45: TTileControl;
    TileControl46: TTileControl;
    TileControl47: TTileControl;
    TileControl48: TTileControl;
    TileControl49: TTileControl;
    TileControl50: TTileControl;
    TileControl51: TTileControl;
    TileControl52: TTileControl;
    TileControl53: TTileControl;
    TileControl54: TTileControl;
    TileControl55: TTileControl;
    TileControl56: TTileControl;
    TileControl57: TTileControl;
    TileControl58: TTileControl;
    TileControl59: TTileControl;
    TileControl60: TTileControl;
    TileControl61: TTileControl;
    TileControl62: TTileControl;
    TileControl63: TTileControl;
    TileControl64: TTileControl;
    TileControl65: TTileControl;
    TileControl66: TTileControl;
    TileControl67: TTileControl;
    TileControl68: TTileControl;
    TileControl69: TTileControl;
    TileControl70: TTileControl;
    TileControl71: TTileControl;
    TileControl72: TTileControl;
    TileControl73: TTileControl;
    TileControl74: TTileControl;
    TileControl75: TTileControl;
    TileControl76: TTileControl;
    TileControl77: TTileControl;
    TileControl78: TTileControl;
    TileControl79: TTileControl;
    TileControl80: TTileControl;
    TileControl81: TTileControl;
    Panel2: TPanel;
    lblGridSize: TLabel;
    Edit1: TEdit;

    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TilesBoxControl1Resize(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
begin
  lblGridSize.Caption:=Format('Grid size: %d / %d', [TilesBoxControl1.ColCount, TilesBoxControl1.RowCount]);
end;

procedure TForm1.TilesBoxControl1Resize(Sender: TObject);
begin
  lblGridSize.Caption:=Format('Grid size: %d / %d', [TilesBoxControl1.ColCount, TilesBoxControl1.RowCount]);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Tile: TTileControl;
  Size: TTileSize;
begin
  if RadioButton1.Checked then
    Size:=tsSmall
  else if RadioButton2.Checked then
    Size:=tsRegular
  else if RadioButton3.Checked then
    Size:=tsLarge
  else if RadioButton4.Checked then
    Size:=tsExtraLarge;
  Tile:=TilesBoxControl1.AddTile(Size);
end;

end.
