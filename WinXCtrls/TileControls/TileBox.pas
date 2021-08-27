{
// Component.......: TTileBox v.2.0
// Author..........: Grzegorz Marek Molenda aka NevTon
// Creation.Date...: 08.12.2016
// Copyright.......: ViTE Software Solutions, (C) 1998 - 2021
// E-mail..........: gmnevton@o2.pl
// Web.page........: vitesoft.net
// Status..........: Private
}

unit TileBox;

interface

uses
  SysUtils,
  Classes,
  Controls,
  Windows,
  Messages,
  Forms,
  Graphics,
  Types,
  ExtCtrls,
  Menus,
  Contnrs,
  pngimage,
  jpeg,
  ShadowWnd,
  TileControl,
  TileControlDrag;

type
  TTilesBoxPaintBkgndEvent = procedure (const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState; var TargetStdPaint: Boolean) of object;
  TTilesBoxMeasureEvent = procedure (const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState; var TargetSize: TPoint) of object;
  TTilesBoxClickEvent = procedure (const Sender: TObject; const TargetControl: TTileControl; const Index: Integer) of object;
  TTilesBoxDblClickEvent = procedure (const Sender: TObject; const TargetControl: TTileControl; const Index: Integer) of object;

  TTileBox = class;
  TTileControlsCollection = class;
  TTileItemPosition = class;

  TTileControlItem = class(TCollectionItem)
  private
    FTileControl: TCustomTileControl;
    FTilePosition: TTileItemPosition;
    FCol: Integer;
    FRow: Integer;

    function GetPosition: TPoint;
    procedure SetTileControl(const Value: TCustomTileControl);
    procedure SetCol(const Value: Integer);
    procedure SetRow(const Value: Integer);
  protected
    procedure SetIndex(Value: Integer); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    FUserPosition: Boolean;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    //
    procedure SetPosition(const ACol, ARow: Integer);
    function Owner: TTileBox;
    function OwnerCollection: TTileControlsCollection;
    property Position: TPoint read GetPosition;
  published
    property TileControl: TCustomTileControl read FTileControl write SetTileControl;
    property TilePosition: TTileItemPosition read FTilePosition write FTilePosition;
    property Col: Integer read FCol write SetCol;
    property Row: Integer read FRow write SetRow;
    property Index;
  end;

  TTileItemPosition = class(TPersistent)
  private
    FOwnerCollectionItem: TTileControlItem;
    InternalUpdate: Boolean;
    FAutoPositioning: Boolean;
    FMinimumCol: Integer;
    FMinimumRow: Integer;
    FMaximumCol: Integer;
    FMaximumRow: Integer;

    procedure SetAutoPositioning(const Value: Boolean);
    procedure SetMinimumCol(const Value: Integer);
    procedure SetMinimumRow(const Value: Integer);
    procedure SetMaximumCol(const Value: Integer);
    procedure SetMaximumRow(const Value: Integer);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(ACollectionItem: TTileControlItem);
  published
    property AutoPositioning: Boolean read FAutoPositioning write SetAutoPositioning;
    property MinimumCol: Integer read FMinimumCol write SetMinimumCol;
    property MinimumRow: Integer read FMinimumRow write SetMinimumRow;
    property MaximumCol: Integer read FMaximumCol write SetMaximumCol;
    property MaximumRow: Integer read FMaximumRow write SetMaximumRow;
  end;

  TTileControlsCollection = class(TOwnedCollection)
  private
    HorzScrollBarVisible, VertScrollBarVisible: Boolean;
    Internal: Boolean;
  protected
    function GetAttrCount: Integer; override;
    function GetItem(Index: Integer): TTileControlItem;
    procedure SetItem(Index: Integer; Value: TTileControlItem);
    procedure Update(Item: TCollectionItem); override;

    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Added(var Item: TCollectionItem); override;
    procedure Deleting(Item: TCollectionItem); override;

    function cellIsAvailable(const posx, posy: Integer; const ParentRect: TRect; const TargetSize: TPoint): Boolean;
    function findEmptyCellX(const X, Y: Integer; const ParentRect: TRect; const TargetSize: TPoint; out OX, OY: Integer): Boolean;
    function findEmptyCellY(const X, Y: Integer; const ParentRect: TRect; const TargetSize: TPoint; out OX, OY: Integer): Boolean;
    procedure findEmptySlot(Orientation: TScrollBarKind; const ParentRect: TRect; var TargetPosition: TPoint; const TargetSize: TPoint);
    function GetHorizontalPos(const StartPoint: TPoint; const HostRect: TRect; const TileSize: TPoint): TPoint;
    function GetVerticalPos(const StartPoint: TPoint; const HostRect: TRect; const TileSize: TPoint): TPoint;
    procedure GetDefaultPosition(const ATileControl: TCustomTileControl; var ACol, ARow: Integer);
  public
    constructor Create(AOwner: TPersistent);

    function Owner: TTileBox;
    function Add: TTileControlItem;

    procedure AddTileControl(const ATileControl: TCustomTileControl; AIndex: Integer = -1);
    procedure RemoveTileControl(const ATileControl: TCustomTileControl);
    function ControlIndex(const ATileControl: TCustomTileControl): Integer; inline;
    procedure RebuildAlignment;
    procedure AlignTileControls(const ATileControl: TCustomTileControl);

    property Items[Index: Integer]: TTileControlItem read GetItem write SetItem; default;
  end;

  TTileBoxDragMode = (dmNormal, dmDragging, dmDraggingOutside);

  TTileBox = class(TScrollingWinControl) // TScrollBox
  private
    FBorderStyle: TBorderStyle;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure PaintWindow(DC: HDC); override;
  published
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
  private
    FControlsCollection: TTileControlsCollection;
    FControlPaint: TTileControlPaintEvent;
    FControlPaintBkgnd: TTilesBoxPaintBkgndEvent;
    FControlMeasure: TTilesBoxMeasureEvent;
    FControlsMultiPopupMenu: TPopupMenu;
    FOnControlClick: TTilesBoxClickEvent;
    FOnControlDblClick: TTilesBoxDblClickEvent;
    FOnPopup: TNotifyEvent;
    FOnPopupMulti: TNotifyEvent;
    FSelectedColor: TColor;
    FHoverColor: TColor;
    FSelectedControls: TObjectList;
    FMultiselect: Boolean;
    FOrientation: TScrollBarKind;
    FControlIndex: Integer;
    FRowCount: Integer;
    FColCount: Integer;
    FOnChange: TNotifyEvent;
    FSpacer: Word;
    FMouseInControl: Boolean;
    FIndentHorz: Word;
    FIndentVert: Word;
    FGroupIndent: Word;
//    FGroupWidth: Byte;
    //
    FActiveControl: TTileControl;
    //
    WheelAccumulator: Integer;
    Updating: Boolean;
    DragMode: TTileBoxDragMode;
    SavedBkgndColor: TColor;

    procedure SetControlsCollection(const Value: TTileControlsCollection);
    procedure SetSelectedColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetMultiselect(const Value: Boolean);
    procedure SetOrientation(const Value: TScrollBarKind);
    procedure SetControlIndex(const Value: Integer);
    procedure SetTileControl(Index: Integer; const Control: TTileControl);
    procedure SetControlDrawState(Index: Integer; const DrawState: TTileControlDrawState);
    procedure SetSpacer(const Value: Word);
    procedure SetIndentHorz(const Value: Word);
    procedure SetIndentVert(const Value: Word);
    procedure SetGroupIndent(const Value: Word);
    function GetTileControl(Index: Integer): TTileControl;
    function GetControlDrawState(Index: Integer): TTileControlDrawState;
    function GetControlsCount: Integer;
    function GetSelectedCount: Integer;
    //
    procedure CalcScrollBar(const ScrollBar: TControlScrollBar);
    //
    procedure CNKeyDown(var Msg: TWMKey); message CN_KEYDOWN;
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure WMMouseWheel(var Msg: TMessage); message WM_MOUSEWHEEL;
    procedure CMControlListChanging(var Message: TCMControlListChanging); message CM_CONTROLLISTCHANGING;
    procedure CMControlListChange(var Message: TCMControlListChange); message CM_CONTROLLISTCHANGE;
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
  protected
    DoUpdate: Boolean;
    ControlPainting: Boolean;
    LastControlClicked: TTileControl;
    FDragObject: TTileDragObject;

    procedure SetActiveControl(const Value: TTileControl);
    procedure SetSelected(const Control: TTileControl; const CanDeselect: Boolean = True);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
//    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
//    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure SharedEndDrag(Target: TObject; X, Y: Integer);
    //
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure ControlsAligned; override;
    procedure DoClick; virtual;
    procedure DoDblClick; virtual;
    procedure DoPopup(const Sender: TObject); virtual;
    procedure DoPopupMulti(const Sender: TObject); virtual;
    procedure DoControlPaint(const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState); virtual;
    procedure DoControlPaintBkgnd(const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState; var TargetStdPaint: Boolean); virtual;
    procedure Loaded; override;
    procedure Resize; override;
    procedure CalcRowsCols; virtual;
    function  cellsToSize(const cels, spacer: Integer): Integer; inline;
    procedure MakeVisible(const Bounds: TRect); virtual;
    procedure UpdateControl(const Index: Integer); virtual;
    procedure UpdateControls(const Rebuild: Boolean); virtual;
    procedure UpdateControlsCollectionIndexes;
    function  CalculateControlPos(const FromPoint: TPoint): TPoint; virtual;
    procedure CalculateControlSize(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint);
    procedure CalculateControlBounds(const Index: Integer; out ControlSize: TPoint); overload; virtual;
    procedure CalculateControlBounds(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint); overload; virtual;
    procedure DrawControl(const TargetControl: TTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState); virtual;
//    function CompareStrings(const S1, S2: String): Integer; virtual;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure AfterConstruction; override;
    procedure ClearSelection(const Update: Boolean = False);
    procedure SelectAll;
    function IndexOf(const Control: TCustomTileControl): Integer; inline;
    function IndexOfPopup(const Sender: TObject): Integer; inline;
    function IndexOfSelected(const Control: TCustomTileControl): Integer; inline;
    procedure UpdateTiles;

    function AddTile(const Size: TTileSize = tsRegular): TTileControl;
    procedure Clear;
    function RemoveTile(var Tile: TTileControl): Boolean;

    property ActiveControl: TTileControl read FActiveControl write SetActiveControl;
    property ColCount: Integer read FColCount;
    property RowCount: Integer read FRowCount;
    property SelectedCount: Integer read GetSelectedCount;
    property TileControl[Index: Integer]: TTileControl read GetTileControl write SetTileControl stored False; default;
    property TileControlIndex: Integer read FControlIndex write SetControlIndex default -1;
    property TileControlsCount: Integer read GetControlsCount;
    property TileSelected[Index: Integer]: TTileControlDrawState read GetControlDrawState write SetControlDrawState stored False;
  published
    property Align default alNone;
    property Color;
    property ControlsCollection: TTileControlsCollection read FControlsCollection write SetControlsCollection;
    property DoubleBuffered;
    property ParentColor;
    property ParentDoubleBuffered;
    property HorzScrollBar stored False;
    property VertScrollBar stored False;
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor default clWebOrange;
    property HoverColor: TColor read FHoverColor write SetHoverColor default cl3DLight;
    property Multiselect: Boolean read FMultiselect write SetMultiselect default False;
    property Orientation: TScrollBarKind read FOrientation write SetOrientation default sbVertical;
    property TabOrder;
    property TabStop default True;
    property OnChangeSelection: TNotifyEvent read FOnChange write FOnChange;
    property OnControlPaint: TTileControlPaintEvent read FControlPaint write FControlPaint;
    property OnControlPaintBkgnd: TTilesBoxPaintBkgndEvent read FControlPaintBkgnd write FControlPaintBkgnd;
    property OnControlMeasure: TTilesBoxMeasureEvent read FControlMeasure write FControlMeasure;
    property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;
    property OnPopupMulti: TNotifyEvent read FOnPopupMulti write FOnPopupMulti;
    property MultiselectPopupMenu: TPopupMenu read FControlsMultiPopupMenu write FControlsMultiPopupMenu;
    property OnControlClick: TTilesBoxClickEvent read FOnControlClick write FOnControlClick;
    property OnControlDblClick: TTilesBoxDblClickEvent read FOnControlDblClick write FOnControlDblClick;
    property Spacer: Word read FSpacer write SetSpacer default 4;
    property IndentHorz: Word read FIndentHorz write SetIndentHorz default 32;
    property IndentVert: Word read FIndentVert write SetIndentVert default 24;
    property GroupIndent: Word read FGroupIndent write SetGroupIndent default 32;
  end;

implementation

uses
  RTLConsts,
  Dialogs,
  Character,
  Math,
  ImgList,
  TileTypes,
  TileUtils;

resourcestring
  sBadControlClassType = 'Can not add class ''%s'' to TTileBox !';

{ TTileControlItem }

constructor TTileControlItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FTileControl:=Nil;
  FTilePosition:=TTileItemPosition.Create(Self);
  FRow:=0;
  FCol:=0;
  FUserPosition:=False;
end;

destructor TTileControlItem.Destroy;
begin
  FTileControl:=Nil;
  FTilePosition.Free;
  FTilePosition:=Nil;
  FRow:=0;
  FCol:=0;
  inherited;
end;

procedure TTileControlItem.AssignTo(Dest: TPersistent);
begin
  if Dest is TTileControlItem then with TTileControlItem(Dest) do begin
    FTileControl:=Self.FTileControl;
    FTilePosition.FOwnerCollectionItem:=Self;
    FTilePosition.FAutoPositioning:=Self.FTilePosition.FAutoPositioning;
    FTilePosition.FMinimumCol:=Self.FTilePosition.FMinimumCol;
    FTilePosition.FMinimumRow:=Self.FTilePosition.FMinimumRow;
    FRow:=Self.FRow;
    FCol:=Self.FCol;
    FUserPosition:=Self.FUserPosition;
  end;
end;

function TTileControlItem.Owner: TTileBox;
begin
  Result:=TTileBox(OwnerCollection.Owner);
end;

function TTileControlItem.OwnerCollection: TTileControlsCollection;
begin
  if Collection is TTileControlsCollection then
    Result:=TTileControlsCollection(Collection)
  else
    Result:=Nil;
end;

procedure TTileControlItem.SetPosition(const ACol, ARow: Integer);
begin
  FCol:=ACol;
  FRow:=ARow;
end;

function TTileControlItem.GetPosition: TPoint;
begin
  Result:=Point(FCol, FRow);
end;

procedure TTileControlItem.SetTileControl(const Value: TCustomTileControl);
begin
  if not (csLoading in Owner.ComponentState) and not (csDesigning in Owner.ComponentState) then
    Exit;

  if (csDesigning in Owner.ComponentState) and (FTileControl <> Nil) then
    Exit;

  if FTileControl <> Value then
    FTileControl:=Value;
//  FTileControl:=Value;
//  if not (csLoading in Owner.ComponentState) and not (csUpdating in Owner.ComponentState) and not (csDestroying in Owner.ComponentState) then begin
//    if Assigned(FTileControl) then begin
//      FTileControl.Align:=alNone;
//    end;
//
//    Owner.Realign;
//  end;
end;

procedure TTileControlItem.SetRow(const Value: Integer);
begin
  if FRow <> Value then begin
    FRow:=Value;
    if not (csLoading in Owner.ComponentState) and not (csUpdating in Owner.ComponentState) and not (csDestroying in Owner.ComponentState) then
      Owner.Realign;
  end;
end;

procedure TTileControlItem.SetCol(const Value: Integer);
begin
  if FCol <> Value then begin
    FCol:=Value;
    if not (csLoading in Owner.ComponentState) and not (csUpdating in Owner.ComponentState) and not (csDestroying in Owner.ComponentState) then
      Owner.Realign;
  end;
end;

procedure TTileControlItem.SetIndex(Value: Integer);
begin
  inherited SetIndex(Value);

  if not (csLoading in Owner.ComponentState) and not (csUpdating in Owner.ComponentState) and not (csDestroying in Owner.ComponentState) then begin
//    OwnerCollection.SetDefaultPositions;
    Owner.Realign;
  end;
end;

{ TTileItemPosition }

constructor TTileItemPosition.Create(ACollectionItem: TTileControlItem);
begin
  inherited Create;
  FOwnerCollectionItem:=ACollectionItem;
  InternalUpdate:=False;
  FAutoPositioning:=True;
  FMinimumCol:=-1;
  FMinimumRow:=-1;
  FMaximumCol:=-1;
  FMaximumRow:=-1;
end;

function TTileItemPosition.GetOwner: TPersistent;
begin
  Result:=FOwnerCollectionItem;
end;

procedure TTileItemPosition.SetAutoPositioning(const Value: Boolean);
begin
  if FAutoPositioning <> Value then begin
    FAutoPositioning:=Value;
    if (FOwnerCollectionItem.FTileControl <> Nil) and (FOwnerCollectionItem.OwnerCollection <> Nil) and Value then begin
      if not (csLoading in FOwnerCollectionItem.Owner.ComponentState) and
         not (csUpdating in FOwnerCollectionItem.Owner.ComponentState) and
         not (csDestroying in FOwnerCollectionItem.Owner.ComponentState) then begin
        FOwnerCollectionItem.OwnerCollection.GetDefaultPosition(FOwnerCollectionItem.FTileControl, FOwnerCollectionItem.FCol, FOwnerCollectionItem.FRow);
        FOwnerCollectionItem.Owner.Realign;
      end;
    end;
  end;
end;

procedure TTileItemPosition.SetMinimumCol(const Value: Integer);
begin
  if (FMinimumCol <> Value) or InternalUpdate then begin
    if Value > -2 then begin
      if (FMaximumCol > -1) and (Value <= FMaximumCol) then
        FMinimumCol:=Value
      else if FMaximumCol = -1 then
        FMinimumCol:=Value
      else
        FMinimumCol:=FMaximumCol;
    end
    else
      FMinimumCol:=-1;
    //
    if not InternalUpdate then
      FOwnerCollectionItem.Owner.Realign;
  end;
end;

procedure TTileItemPosition.SetMinimumRow(const Value: Integer);
begin
  if (FMinimumRow <> Value) or InternalUpdate then begin
    if Value > -2 then begin
      if (FMaximumRow > -1) and (Value <= FMaximumRow) then
        FMinimumRow:=Value
      else if FMaximumRow = -1 then
        FMinimumRow:=Value
      else
        FMinimumRow:=FMaximumRow;
    end
    else
      FMinimumRow:=-1;
    //
    if not InternalUpdate then
      FOwnerCollectionItem.Owner.Realign;
  end;
end;

procedure TTileItemPosition.SetMaximumCol(const Value: Integer);
begin
  if FMaximumCol <> Value then begin
    if Value > -2 then
      FMaximumCol:=Value
    else
      FMaximumCol:=-1;
    InternalUpdate:=True;
    SetMinimumCol(FMinimumCol);
    InternalUpdate:=False;
    //
    FOwnerCollectionItem.Owner.Realign;
  end;
end;

procedure TTileItemPosition.SetMaximumRow(const Value: Integer);
begin
  if FMaximumRow <> Value then begin
    if Value > -2 then
      FMaximumRow:=Value
    else
      FMaximumRow:=-1;
    InternalUpdate:=True;
    SetMinimumRow(FMinimumRow);
    InternalUpdate:=False;
    //
    FOwnerCollectionItem.Owner.Realign;
  end;
end;

{ TTileControlsCollection }

constructor TTileControlsCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TTileControlItem);
  Internal:=False;
end;

procedure TTileControlsCollection.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  case Action of
//    cnAdded: Added(Item); // stop double popup
    cnDeleting: inherited;
  end;
end;

procedure TTileControlsCollection.Added(var Item: TCollectionItem);
var
  Tile: TCustomTileControl;
  X, Y: Integer;
  max_num, i, j: Integer;
  num: String;
begin
  if not Internal and not (csLoading in Owner.ComponentState) then begin
    max_num:=0;
    for i:=0 to Owner.ControlCount - 1 do begin
      j:=0;
      num:=Owner.Controls[i].Name;
      try
        while (j < Length(num)) and not IsNumber(num[j + 1]) do
          Inc(j);
        if (j > 0) and (j < Length(num)) then
          num:=Copy(num, j + 1, MaxInt);
        max_num:=Max(max_num, StrToIntDef(num, 0));
      finally
        num:='';
      end;
    end;

    Tile:=TTileControl.Create(Owner);
    try
      Tile.Name:='TileControl' + IntToStr(max_num + 1);
      Tile.Visible:=False;
      Tile.ControlsCollectionIndex:=Item.Index;
      //
      TTileControlItem(Item).FTileControl:=Tile;
      TTileControlItem(Item).FCol:=-1;
      TTileControlItem(Item).FRow:=-1;
      GetDefaultPosition(Tile, X, Y);
      TTileControlItem(Item).FCol:=X;
      TTileControlItem(Item).FRow:=Y;
      //
      Tile.Parent:=Owner;
      Tile.Visible:=True;
    except
      Tile.Free;
      Delete(Count - 1);
    end;
  end;
end;

procedure TTileControlsCollection.Deleting(Item: TCollectionItem);
begin

end;

function TTileControlsCollection.GetAttrCount: Integer;
begin
  Result:=0;
end;

function TTileControlsCollection.GetItem(Index: Integer): TTileControlItem;
begin
  Result:=TTileControlItem(inherited GetItem(Index));
end;

procedure TTileControlsCollection.SetItem(Index: Integer; Value: TTileControlItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TTileControlsCollection.Update(Item: TCollectionItem);
var
  i: Integer;
begin
  // update all indexes
  if (csLoading in Owner.ComponentState) or (csReading in Owner.ComponentState) then
    Exit;
  if Item = Nil then begin
    for i:=0 to Count - 1 do begin
      if Items[i].TileControl <> Nil then
        Items[i].TileControl.ControlsCollectionIndex:=i;
    end;
  end;
  if Owner <> Nil then
    Owner.Realign;
end;

function TTileControlsCollection.Owner: TTileBox;
begin
  Result:=TTileBox(GetOwner);
end;

function TTileControlsCollection.Add: TTileControlItem;
begin
  Internal:=True;
  try
    Result:=TTileControlItem(inherited Add);
  finally
    Internal:=False;
  end;
end;

procedure TTileControlsCollection.AddTileControl(const ATileControl: TCustomTileControl; AIndex: Integer);
var
  Item: TTileControlItem;
  X, Y: Integer;
begin
  if ControlIndex(ATileControl) = -1 then begin
    X:=0;
    Y:=0;
    if AIndex < 0 then begin
      Item:=Add;
      Item.FCol:=-1;
      Item.FRow:=-1;
    end
    else
      Item:=Items[AIndex];

    ATileControl.ControlsCollectionIndex:=Item.Index;
    Item.FTileControl:=ATileControl;
    if not (csLoading in Owner.ComponentState) and not (csUpdating in Owner.ComponentState) and not (csDestroying in Owner.ComponentState) then begin
      GetDefaultPosition(ATileControl, X, Y);
      Item.FCol:=X;
      Item.FRow:=Y;
    end;
  end;
end;

procedure TTileControlsCollection.RemoveTileControl(const ATileControl: TCustomTileControl);
var
  i, idx: Integer;
begin
  idx:=-1;
  for i:=0 to Count - 1 do
    if Items[i].TileControl = ATileControl then begin
      idx:=i;
      Break;
    end;
  if idx > -1 then begin
    Items[idx].FTileControl:=Nil;
    Delete(idx);
  end;
end;

function TTileControlsCollection.ControlIndex(const ATileControl: TCustomTileControl): Integer;
begin
  if ATileControl <> Nil then begin
//    for Result:=0 to Count - 1 do
//      if Items[Result].TileControl = ATileControl then
    Result:=ATileControl.ControlsCollectionIndex;
    Exit;
  end;
  Result:=-1;
end;

procedure TTileControlsCollection.RebuildAlignment;
var
  i: Integer;
  Item: TTileControlItem;
  Tile: TCustomTileControl;
  ACol, ARow: Integer;
begin
  Owner.CalcRowsCols;
  for i:=0 to Count - 1 do begin
    Item:=Items[i];
    if not Item.TilePosition.AutoPositioning then
      Continue;
    Tile:=Item.TileControl;
    if Tile = Nil then
      Continue;
    Item.SetPosition(-1, -1);
  end;
  for i:=0 to Count - 1 do begin
    Item:=Items[i];
    if not Item.TilePosition.AutoPositioning then
      Continue;
    Tile:=Item.TileControl;
    if Tile = Nil then
      Continue;
    GetDefaultPosition(Tile, ACol, ARow);
    Item.SetPosition(ACol, ARow);
  end;
end;

procedure TTileControlsCollection.AlignTileControls(const ATileControl: TCustomTileControl);
var
  i, idx: Integer;
//  ScrollPos: TPoint;
//  TileSize: TPoint;
//  ViewPos: TPoint;
  Tile: TTileControl;
//  HorzSpace, VertSpace: Integer;

  ParentRect: TRect;
  Position, ControlPos: TPoint;
  Size: TPoint;
//  MaxHeight, MaxWidth: Integer;
//  GroupWidth, GroupHeight: Integer;
//  SizeX, SizeY: Integer;
//  GroupCnt: Integer;
begin
  idx:=ControlIndex(ATileControl);
  if idx = -1 then
    idx:=0;

  ParentRect:=Owner.GetClientRect;
  Owner.AdjustClientRect(ParentRect);
  InflateRect(ParentRect, -Owner.IndentHorz, -Owner.IndentVert);

  HorzScrollBarVisible:=Owner.HorzScrollBar.IsScrollBarVisible;
  VertScrollBarVisible:=Owner.VertScrollBar.IsScrollBarVisible;
  Owner.HorzScrollBar.Visible:=(Owner.Orientation = sbHorizontal) or HorzScrollBarVisible;
  Owner.VertScrollBar.Visible:=(Owner.Orientation = sbVertical) or VertScrollBarVisible;

//  Position:=ParentRect.TopLeft;
//  MaxHeight:=0;
//  MaxWidth:=0;
  for i:=idx to Count - 1 do begin
    Position:=ParentRect.TopLeft;
    Tile:=TTileControl(Items[i].TileControl);
    if (Tile = Nil) or (not Tile.Visible and not (csDesigning in Owner.ComponentState)) then
      Continue;

    Owner.CalculateControlBounds(Tile, {-1, }ParentRect, Size);

    ControlPos:=Point(48 * Items[i].Col + Owner.Spacer * Items[i].Col,
                      48 * Items[i].Row + Owner.Spacer * Items[i].Row);

    Position:=PointsAdd(Position, ControlPos);

//    if Owner.Orientation = sbVertical then begin
//      if (MaxHeight > 0) and (Position.X + Size.X > ParentRect.Right{GroupWidth}) then begin
//        Inc(Position.Y, MaxHeight + Owner.Spacer);
//        //Inc(SizeY, MaxHeight + Owner.Spacer);
//        MaxHeight:=0;
//        Position.X:=ParentRect.Left;
//      end;
//    end
//    else begin
//      if (MaxWidth > 0) and (Position.Y + Size.Y > ParentRect.Bottom{GroupHeight}) then begin
//        Inc(Position.X, MaxWidth + Owner.Spacer);
//        //Inc(SizeX, MaxWidth + Owner.Spacer);
//        MaxWidth:=0;
//        Position.Y:=ParentRect.Top;
//      end;
//    end;

//    if Size.Y > MaxHeight then
//      MaxHeight:=Size.Y;
//    if Size.X > MaxWidth then
//      MaxWidth:=Size.X;

    if not EqualRect(Tile.BoundsRect, Bounds(Position.X, Position.Y, Size.X, Size.Y)) then
      Tile.SetBounds(Position.X, Position.Y, Size.X, Size.Y);

//    if Owner.Orientation = sbVertical then
//      Inc(Position.X, Size.X + Owner.Spacer)
//    else
//      Inc(Position.Y, Size.Y + Owner.Spacer);
  end;

//  GroupWidth:=(8 * 48) + (7 * Self.Spacer) + IndentHorz;
//  GroupHeight:=(8 * 48) + (7 * Self.Spacer) + IndentVert;
//  SizeX:=0;
//  SizeY:=0;
end;

{
    Inc(X, 1);
      first_empty:=-1;
      if Orientation = sbHorizontal then begin
        a:=x;
        b:=Owner.ColCount;
        if b <= 0 then
          Exit;
      end
      else begin
        a:=y;
        b:=Owner.RowCount;
        if b <= 0 then
          Exit;
      end;
      if a > (b - 1) then begin
        if not canChangeOrientation then begin
          if Orientation = sbHorizontal then begin
            x:=-1;
            Inc(y);
          end
          else begin
            Inc(x);
            y:=-1;
          end;
          Continue;
        end;
        first_empty:=a - 1;
        Break;
      end;
      // szukaj wolnego miejsca
      for k:=a to b - 1 do begin
        if Orientation = sbHorizontal then
          found:=iterateItems(k, y)
        else
          found:=iterateItems(x, k);
        if not found then begin
          first_empty:=k;
          Break;
        end;
      end;
      if (first_empty = -1) and canChangeOrientation then begin
        if Orientation = sbHorizontal then begin
          x:=-1;
          Inc(y);
        end
        else begin
          Inc(x);
          y:=-1;
        end;
      end;
  until (first_empty > -1) or expired;
}

function TTileControlsCollection.cellIsAvailable(const posx, posy: Integer; const ParentRect: TRect; const TargetSize: TPoint): Boolean;
var
  i: Integer;
  LPos, LSize: TPoint;
  LResult: Boolean;
  LRect: TRect;
begin
  Result:=True;
  for i:=0 to Count - 1 do begin
    LPos:=Items[i].Position;
    if PointsEqual(LPos, EmptyPoint) then
      Continue;
    Owner.CalculateControlSize(Items[i].TileControl, ParentRect, LSize);
//        if PtInRect(Rect(LPos.X, LPos.Y, LPos.X + LSize.X, LPos.Y + LSize.Y), Point(posx, posy)) then begin
    LResult:=IntersectRect(LRect, Rect(LPos.X, LPos.Y, LPos.X + LSize.X, LPos.Y + LSize.Y), Rect(posx, posy, posx + TargetSize.X, posy + TargetSize.Y));
    if LResult then begin
//        if ((posx >= Items[i].Position.X) and (posx <= Items[i].Position.X + Size.X)) and
//           ((posy >= Items[i].Position.Y) and (posy <= Items[i].Position.Y + Size.Y)) then begin
      Result:=False;
      Break;
    end;
  end;
end;

function TTileControlsCollection.findEmptyCellX(const X, Y: Integer; const ParentRect: TRect; const TargetSize: TPoint; out OX, OY: Integer): Boolean;
var
  a, b, k: Integer;
  available: Boolean;
begin
  Result:=False;
  OX:=X;
  OY:=Y;
  a:=X;
  b:=Owner.ColCount;
  if (a < 0) or (b <= 0) then
    Exit;
  if a > (b - 1) then begin
    OX:=0;
    Inc(OY);
    Exit;
  end;
  // szukaj wolnego miejsca
  for k:=a to b - 1 do begin
    available:=cellIsAvailable(k, Y, ParentRect, TargetSize);
    if available then begin
      OX:=k;
      Exit(True);
    end;
  end;
end;

function TTileControlsCollection.findEmptyCellY(const X, Y: Integer; const ParentRect: TRect; const TargetSize: TPoint; out OX, OY: Integer): Boolean;
var
  a, b, k: Integer;
  available: Boolean;
begin
  Result:=False;
  OX:=X;
  OY:=Y;
  a:=X;
  b:=Owner.RowCount;
  if b <= 0 then
    Exit;
  if a > (b - 1) then begin
    OY:=0;
    Inc(OX);
    Exit;
  end;
  // szukaj wolnego miejsca
  for k:=a to b - 1 do begin
    available:=cellIsAvailable(X, k, ParentRect, TargetSize);
    if available then begin
      OY:=k;
      Exit(True);
    end;
  end;
end;

procedure TTileControlsCollection.findEmptySlot(Orientation: TScrollBarKind; const ParentRect: TRect; var TargetPosition: TPoint; const TargetSize: TPoint);
var
  X, Y: Integer;
  found: Boolean;
begin
  if Orientation = sbHorizontal then begin
    found:=findEmptyCellX(TargetPosition.X, TargetPosition.Y, ParentRect, TargetSize, X, Y);
    if not found and (TargetPosition.Y < Y) then begin
      TargetPosition.X:=X;
      TargetPosition.Y:=Y;
      findEmptySlot(Orientation, ParentRect, TargetPosition, TargetSize);
      Exit;
    end
    else if not found and PointsEqual(TargetPosition, Point(X, Y)) then begin
      // we have not found empty space for our tile, try going to other row and find again
      TargetPosition.X:=0;
      Inc(TargetPosition.Y);
      findEmptySlot(Orientation, ParentRect, TargetPosition, TargetSize);
      Exit;
    end;
  end
  else begin
    found:=findEmptyCellY(TargetPosition.X, TargetPosition.Y, ParentRect, TargetSize, X, Y);
    if not found and (TargetPosition.X < X) then begin
      TargetPosition.X:=X;
      TargetPosition.Y:=Y;
      findEmptySlot(Orientation, ParentRect, TargetPosition, TargetSize);
      Exit;
    end
    else if not found and PointsEqual(TargetPosition, Point(X, Y)) then begin
      Inc(TargetPosition.X);
      TargetPosition.Y:=0;
      findEmptySlot(Orientation, ParentRect, TargetPosition, TargetSize);
      Exit;
    end;
  end;

  TargetPosition.X:=X;
  TargetPosition.Y:=Y;
end;

function TTileControlsCollection.GetHorizontalPos(const StartPoint: TPoint; const HostRect: TRect; const TileSize: TPoint): TPoint;
begin
  Result:=StartPoint;
  while True do begin
    findEmptySlot(sbHorizontal, HostRect, Result, TileSize);
    if Owner.cellsToSize(Result.X + TileSize.X, Owner.Spacer) > HostRect.Right then begin
      // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
      if (Owner.ColCount >= TileSize.X) and (Result.X > 0) then begin
        Result.X:=-1;
        Inc(Result.Y);
      end
      else begin
        if Result.X = 0 then begin
          Break;
        end
        else begin
          if (Owner.ColCount > 0) and (Owner.ColCount < TileSize.X) then begin
            Result.X:=-1;
            Inc(Result.Y);
          end
          else begin
            Result.X:=0;
            Break;
          end;
        end;
      end;
    end
    else
      Break;
  end;
end;

function TTileControlsCollection.GetVerticalPos(const StartPoint: TPoint; const HostRect: TRect; const TileSize: TPoint): TPoint;
begin
  Result:=StartPoint;
  while True do begin
    findEmptySlot(sbVertical, HostRect, Result, TileSize);
    if Owner.cellsToSize(Result.Y + TileSize.Y, Owner.Spacer) > HostRect.Bottom then begin
      // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
      if (Owner.RowCount >= TileSize.Y) and (Result.Y > 0) then begin
        Result.Y:=-1;
        Inc(Result.X);
      end
      else begin
        if Result.Y = 0 then begin
          Break;
        end
        else begin
          if (Owner.RowCount > 0) and (Owner.RowCount < TileSize.Y) then begin
            Result.Y:=-1;
            Inc(Result.X);
          end
          else begin
            Result.Y:=0;
            Break;
          end;
        end;
      end;
    end
    else
      Break;
  end;
end;

procedure TTileControlsCollection.GetDefaultPosition(const ATileControl: TCustomTileControl; var ACol, ARow: Integer);
var
  idx, before: Integer;
  Control: TTileControl;
  ParentRect: TRect;
  Position, Size1, Size2, TempPosition: TPoint;
begin
  if (Owner <> Nil) and not (csLoading in Owner.ComponentState) then begin
    Position:=EmptyPoint; // Point(-1, -1);
    Size1:=Point(0, 0);
    Size2:=Point(0, 0);
    Control:=Nil;

    ParentRect:=Owner.GetClientRect;
    Owner.AdjustClientRect(ParentRect);
    InflateRect(ParentRect, -Owner.IndentHorz, -Owner.IndentVert);

    idx:=ControlIndex(ATileControl);
    if idx > -1 then begin
      before:=idx - 1;
      if before > -1 then begin
        Control:=TTileControl(Items[before].TileControl);
//        Position:=Control.BoundsRect.TopLeft;
        Position:=Items[before].Position;
      end;
      if Control <> Nil then
        Owner.CalculateControlSize(Control, ParentRect, Size1);
      Owner.CalculateControlSize(ATileControl, ParentRect, Size2);

      // Owner.Orientation states the orientation of TileBox scrollability:
      //   default sbVertical means that we can scroll up/down, so we place our tiles from left to right
      //   and if there is no more room on the right side, then we move row down from top to bottom;
      //   in other situation (sbHorizontal), we place tiles from top to bottom and if we cant go down any more,
      //   than we move column right from left to right.
      if Owner.Orientation = sbVertical then begin
        if Owner.cellsToSize(Position.X + Size1.X + Size2.X, Owner.Spacer) > ParentRect.Right then begin
          // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
          TempPosition:=Point(Position.X + Size1.X + Size2.X, Position.Y);
          TempPosition:=GetHorizontalPos(TempPosition, ParentRect, Size2);
          Position:=TempPosition;
        end
        else if before > -1 then begin
          Position:=GetHorizontalPos(Position, ParentRect, Size2);
        end;
      end
      else begin // Owner.Orientation = sbHorizontal
        if Owner.cellsToSize(Position.Y + Size1.Y + Size2.Y, Owner.Spacer) > ParentRect.Bottom then begin
          // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
          TempPosition:=Point(Position.X, Position.Y + Size1.Y + Size2.Y);
          TempPosition:=GetVerticalPos(TempPosition, ParentRect, Size2);
          Position:=TempPosition;
        end
        else if before > -1 then begin
          Position:=GetVerticalPos(Position, ParentRect, Size2);
        end;
      end;

      //Position:=PointsDec(Position, ParentRect.TopLeft);
      if Position.X < 0 then
        Position.X:=0;
      if Position.Y < 0 then
        Position.Y:=0;
      // sprawdz minimalne pozycje
      if Position.X < Items[idx].FTilePosition.FMinimumCol then
        Position.X:=Items[idx].FTilePosition.FMinimumCol;
      if Position.Y < Items[idx].FTilePosition.FMinimumRow then
        Position.Y:=Items[idx].FTilePosition.FMinimumRow;
      if (Items[idx].FTilePosition.FMaximumCol > -1) and (Position.X > Items[idx].FTilePosition.FMaximumCol) then
        Position.X:=Items[idx].FTilePosition.FMaximumCol;
      if (Items[idx].FTilePosition.FMaximumRow > -1) and (Position.Y > Items[idx].FTilePosition.FMaximumRow) then
        Position.Y:=Items[idx].FTilePosition.FMaximumRow;

      ACol:=Position.X;
      ARow:=Position.Y;
    end;
  end;
end;

//          if (Control <> Nil) then begin
//            if (Control.Size = ATileControl.Size) then begin
//              findEmptySlot(Owner.Orientation,{ ParentRect.TopLeft,} Position, ATileControl.Size, Size2{, Owner.Spacer});
//            end
//            else begin
//              findEmptySlot(Owner.Orientation,{ ParentRect.TopLeft,} Position, ATileControl.Size, Size2{, Owner.Spacer});
//            end;
//          end
//          else begin
//            findEmptySlot(Owner.Orientation,{ ParentRect.TopLeft,} Position, ATileControl.Size, Size2{, Owner.Spacer});
//          end;

{ TTileBox }

function TTileBox.AddTile(const Size: TTileSize = tsRegular): TTileControl;
begin
  Result:=TTileControl.Create(Self);
  try
    Result.Visible:=False;
    Result.Size:=Size;
    Result.Parent:=Self;
    Result.Visible:=True;
  except
    FreeAndNil(Result);
  end;
end;

procedure TTileBox.AdjustClientRect(var Rect: TRect);
begin
  Rect:=Bounds(-HorzScrollBar.Position,
               -VertScrollBar.Position,
               IfThen(Orientation = sbHorizontal, Max(HorzScrollBar.Range, ClientWidth), ClientWidth),
               IfThen(Orientation = sbVertical, Max(VertScrollBar.Range, ClientHeight), ClientHeight));
end;

procedure TTileBox.AlignControls(AControl: TControl; var ARect: TRect);
begin
  if GetControlsCount > 0 then begin
//    UpdateControls((AControl <> Nil) or DoUpdate);
    if (AControl <> Nil) or DoUpdate then
      FControlsCollection.RebuildAlignment;
    FControlsCollection.AlignTileControls(TCustomTileControl(AControl));
    CalcScrollBar(HorzScrollBar);
    CalcScrollBar(VertScrollBar);
    DoUpdate:=False;
    ControlsAligned;
  end;
  if Showing then
    AdjustSize;
end;

function TTileBox.CalculateControlPos(const FromPoint: TPoint): TPoint;
var
  ClientPoint: TPoint;
  dx, dy: Integer;
begin
  ClientPoint:=PointsAdd(FromPoint, Point(-IndentHorz, -IndentVert));
  ClientPoint.X:=Abs(ClientPoint.X);
  ClientPoint.Y:=Abs(ClientPoint.Y);
  dx:=ClientPoint.X div 48;
  if dx > 0 then
    Dec(dx);
  dy:=ClientPoint.Y div 48;
  if dy > 0 then
    Dec(dy);
  ClientPoint:=PointsDec(ClientPoint, Point(dx * Spacer, dy * Spacer));
  //
  Result:=Point(ClientPoint.X div 48, ClientPoint.Y div 48);
  if (Result.X > 0) and (Result.X > ColCount) then
    Result.X:=ColCount;
  if (Result.Y > 0) and (Result.Y > RowCount) then
    Result.Y:=RowCount;
end;

procedure TTileBox.CalculateControlSize(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint);
var
  MaxSizeX, MaxSizeY: Integer;
begin
  ControlSize:=Point(1, 1); // minimum size
  if Control = Nil then
    Exit;

  case Control.Size of
    tsSmall: Exit;
    tsRegular   : ControlSize:=Point(2, 2);
    tsLarge     : ControlSize:=Point(4, 2);
    tsExtraLarge: ControlSize:=Point(4, 4);
    tsCustom: begin
      if Control.SizeFixed then
        ControlSize:=Point(Control.SizeCustomCols, Control.SizeCustomRows)
      else begin
        MaxSizeX:=Control.SizeCustomCols;
        MaxSizeY:=Control.SizeCustomRows;
        if Orientation = sbVertical then begin
          MaxSizeX:=ColCount;
          while (MaxSizeX > 0) and ((48 * MaxSizeX + Self.Spacer * (MaxSizeX - 1)) > Abs(RectWidth(TargetRect))) do
            Dec(MaxSizeX);
          if MaxSizeX = 0 then
            MaxSizeX:=1;
          if MaxSizeX > Control.SizeCustomCols then
            MaxSizeX:=Control.SizeCustomCols;
//          MaxSizeX:=48 * MaxSizeX + Self.Spacer * (MaxSizeX - 1);
        end
        else begin
          MaxSizeY:=RowCount;
          while (MaxSizeY > 0) and ((48 * MaxSizeY + Self.Spacer * (MaxSizeY - 1)) > Abs(RectHeight(TargetRect))) do
            Dec(MaxSizeY);
          if MaxSizeY = 0 then
            MaxSizeY:=1;
          if MaxSizeY > Control.SizeCustomRows then
            MaxSizeY:=Control.SizeCustomRows;
//          MaxSizeY:=48 * MaxSizeY + Self.Spacer * (MaxSizeY - 1);
        end;
        ControlSize:=Point(MaxSizeX, MaxSizeY);
      end;
    end;
  end;
end;

procedure TTileBox.CalculateControlBounds(const Index: Integer; out ControlSize: TPoint);
var
  Control: TTileControl;
  ParentRect: TRect;
begin
  ControlSize:=Point(48, 48); // minimum size

  if GetControlsCount = 0 then
    Exit;

  if (Index < 0) or (Index >= GetControlsCount) then
    Exit;

  Control:=GetTileControl(Index);

  ParentRect:=GetClientRect;
  AdjustClientRect(ParentRect);
  Inc(ParentRect.Left, IndentHorz);
  Inc(ParentRect.Top,  IndentVert);
  Dec(ParentRect.Right, IndentHorz);
  Dec(ParentRect.Bottom, IndentVert);

  CalculateControlBounds(Control, {Index, }ParentRect, ControlSize);
end;

procedure TTileBox.CalculateControlBounds(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint);
var
//  Sel: TTileControlDrawState;
  MaxSizeX, MaxSizeY: Integer;
begin
  ControlSize:=Point(48, 48); // minimum size
//  Sel:=cdsNormal;

//  if not FMultiselect then begin
//    if (ActiveControl <> Nil) and (ActiveControl = Control) then begin
//      Sel:=cdsSelected;
//      if Index = FControlIndex then
//        Sel:=cdsSelFocused;
//    end
//    else if Index = FControlIndex then
//      Sel:=cdsFocused;
//  end
//  else begin
//    if FSelectedControls.IndexOf(Control) >= 0 then begin
//      Sel:=cdsSelected;
//      if Index = FControlIndex then
//        Sel:=cdsSelFocused;
//    end
//    else if Index = FControlIndex then
//      Sel:=cdsFocused;
//  end;

  case Control.Size of
    tsSmall: Exit;
    tsRegular   : ControlSize:=Point(ControlSize.X * 2 + Self.Spacer    , ControlSize.Y * 2 + Self.Spacer);
    tsLarge     : ControlSize:=Point(ControlSize.X * 4 + Self.Spacer * 3, ControlSize.Y * 2 + Self.Spacer);
    tsExtraLarge: ControlSize:=Point(ControlSize.X * 4 + Self.Spacer * 3, ControlSize.Y * 4 + Self.Spacer * 3);
    tsCustom: begin
      if Control.SizeFixed then
        ControlSize:=Point(ControlSize.X * Control.SizeCustomCols + Self.Spacer * (Control.SizeCustomCols - 1),
                           ControlSize.Y * Control.SizeCustomRows + Self.Spacer * (Control.SizeCustomRows - 1))
      else begin
        MaxSizeX:=48 * Control.SizeCustomCols + Self.Spacer * (Control.SizeCustomCols - 1);
        MaxSizeY:=48 * Control.SizeCustomRows + Self.Spacer * (Control.SizeCustomRows - 1);
        if Orientation = sbVertical then begin
          MaxSizeX:=Abs(RectWidth(TargetRect)) div 48;
          while (MaxSizeX > 0) and ((48 * MaxSizeX + Self.Spacer * (MaxSizeX - 1)) > Abs(RectWidth(TargetRect))) do
            Dec(MaxSizeX);
          if MaxSizeX = 0 then
            MaxSizeX:=1;
          if MaxSizeX > Control.SizeCustomCols then
            MaxSizeX:=Control.SizeCustomCols;
          MaxSizeX:=48 * MaxSizeX + Self.Spacer * (MaxSizeX - 1);
        end
        else begin
          MaxSizeY:=Abs(RectHeight(TargetRect)) div 48;
          while (MaxSizeY > 0) and ((48 * MaxSizeY + Self.Spacer * (MaxSizeY - 1)) > Abs(RectHeight(TargetRect))) do
            Dec(MaxSizeY);
          if MaxSizeY = 0 then
            MaxSizeY:=1;
          if MaxSizeY > Control.SizeCustomRows then
            MaxSizeY:=Control.SizeCustomRows;
          MaxSizeY:=48 * MaxSizeY + Self.Spacer * (MaxSizeY - 1);
        end;
        ControlSize:=Point(MaxSizeX, MaxSizeY);
      end;
    end;
  end;

//  ControlSize.X:=48;
//
//  if not Assigned(FControlMeasure) then
//    ControlSize.Y:=DrawItemHeight(Control, Control.Canvas, Self.ClientRect, Sel, True)
//  else
//    OnControlMeasure(Control, Control.Canvas, Self.ClientRect, Sel, ControlSize);
end;

procedure TTileBox.CalcRowsCols;
var
  ClientRect: TRect;
begin
  if not HandleAllocated then
    Exit;
  //
  ClientRect:=GetClientRect;
  if IsRectEmpty(ClientRect) then
    Exit;
  AdjustClientRect(ClientRect);
  InflateRect(ClientRect, -IndentHorz, -IndentVert);
  FColCount:=Abs(RectWidth(ClientRect)) div 48;
  while (FColCount > 0) and (cellsToSize(FColCount, Spacer) > Abs(RectWidth(ClientRect))) do
    Dec(FColCount);
  Inc(FColCount);
//  FColCount:=Abs(RectWidth(ClientRect)) div (48 + Spacer);
//  if FColCount < 1 then
//    FColCount:=1;

  FRowCount:=Abs(RectHeight(ClientRect)) div 48;
  while (FRowCount > 0) and (cellsToSize(FRowCount, Spacer) > Abs(RectHeight(ClientRect))) do
    Dec(FRowCount);
  Inc(FRowCount);
//  FRowCount:=Abs(RectHeight(ClientRect)) div (48 + Spacer);
//  if FRowCount < 1 then
//    FRowCount:=1;
end;

function TTileBox.cellsToSize(const cels, spacer: Integer): Integer;
begin
  Result:=(48 + spacer) * cels;
end;

procedure TTileBox.CalcScrollBar(const ScrollBar: TControlScrollBar);
var
  I: Integer;
  NewRange, AlignMargin: Integer;

  procedure ProcessHorz(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alLeft, alNone:
          if (Control.Align = alNone) or (Control.Align = alLeft) or (Control.Anchors * [akLeft, akRight] = [akLeft]) then
            NewRange:=Max(NewRange, ScrollBar.Position + Control.Left + Control.Width);
        alRight: Inc(AlignMargin, Control.Width);
      end;
  end;

  procedure ProcessVert(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alTop, alNone:
          if (Control.Align = alNone) or (Control.Align = alTop) or (Control.Anchors * [akTop, akBottom] = [akTop]) then
            NewRange:=Max(NewRange, ScrollBar.Position + Control.Top + Control.Height);
        alBottom: Inc(AlignMargin, Control.Height);
      end;
  end;

//var
//  HorzScrollSize, VertScrollSize: Integer;
begin
//  HorzScrollSize:=GetSystemMetrics(SM_CXHSCROLL) * 2;
//  VertScrollSize:=GetSystemMetrics(SM_CXVSCROLL) * 2;
  NewRange:=0;
  AlignMargin:=0;
  for I:=0 to Self.ControlCount - 1 do
    if ScrollBar.Kind = sbHorizontal then
      ProcessHorz(Self.Controls[I])
    else
      ProcessVert(Self.Controls[I]);
  NewRange:=NewRange + AlignMargin + ScrollBar.Margin + IfThen(Orientation = sbHorizontal, IndentHorz, IndentVert);
  ScrollBar.Range:=NewRange;
end;

procedure TTileBox.Clear;
var
  Tile: TTileControl;
begin
  while GetControlsCount > 0 do begin
    Tile:=GetTileControl(0);
    RemoveTile(Tile);
  end;
end;

procedure TTileBox.ClearSelection(const Update: Boolean = False);
begin
  if GetControlsCount = 0 then
    Exit;

  FSelectedControls.Clear;
  if Multiselect then begin
    if Update then
      UpdateControls(True);
  end
  else begin
    if Update then begin
      TileControlIndex:=-1;
      ActiveControl:=Nil;
    end;
  end;
end;

procedure TTileBox.SelectAll;
var
  i: Integer;
begin
  if GetControlsCount = 0 then
    Exit;

  FSelectedControls.Clear;
  for i:=0 to GetControlsCount - 1 do
    FSelectedControls.Add(GetTileControl(i));

  UpdateControls(True);
end;

procedure TTileBox.CMControlListChanging(var Message: TCMControlListChanging);
begin
  if (Message.ControlListItem^.Parent = Self) and(Message.ControlListItem^.Control <> Nil) then begin
    if Message.Inserting and not (Message.ControlListItem^.Control is TCustomTileControl) and not (Message.ControlListItem^.Control is TShadowWindow) then
      raise Exception.CreateFmt(sBadControlClassType, [Message.ControlListItem^.Control.ClassName]);
  end;
  inherited;
end;

procedure TTileBox.CMControlListChange(var Message: TCMControlListChange);
begin
  inherited;
  if Message.Inserting and (Message.Control <> Nil) and (Message.Control is TCustomTileControl) then begin
    TCustomTileControl(Message.Control).Align:=alNone;
    TCustomTileControl(Message.Control).Anchors:=[];
    //
    if not (csLoading in Owner.ComponentState){ and not (csDesigning in Owner.ComponentState)} then
      FControlsCollection.AddTileControl(TCustomTileControl(Message.Control));
  end;
end;

procedure TTileBox.CMControlChange(var Message: TCMControlChange);
begin
  inherited;
  if not Message.Inserting and (Message.Control <> Nil) and (Message.Control is TCustomTileControl) and (Message.Control.Parent = Self) then begin
    FControlsCollection.RemoveTileControl(TCustomTileControl(Message.Control));
  end;
end;

procedure TTileBox.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
    RecreateWnd;
  inherited;
end;

procedure TTileBox.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  UpdateControls(True);
end;

procedure TTileBox.CNKeyDown(var Msg: TWMKey);
var
  Key: Word;
  Shift: TShiftState;

  procedure SelectControl;
  begin
    if (TileControlIndex >= 0) and (TileControlIndex <= GetControlsCount - 1) then
      SetSelected(GetTileControl(TileControlIndex));
  end;

begin
  if GetControlsCount > 0 then begin
    with Msg do begin
      Key:=CharCode;
      Shift:=KeyDataToShiftState(KeyData);
    end;

    if (Shift = []) or (Shift = [ssCtrl]) then begin
      case Key of
        VK_LEFT: begin
          if Orientation = sbHorizontal then
            TileControlIndex:=TileControlIndex - 1 // RowCount
          else
            TileControlIndex:=TileControlIndex - 1;

          ClearSelection();
          SelectControl;
        end;
        VK_RIGHT: begin
          if Orientation = sbHorizontal then
            TileControlIndex:=TileControlIndex + 1 // RowCount
          else
            TileControlIndex:=TileControlIndex + 1;

          ClearSelection();
          SelectControl;
        end;
        VK_UP: begin
          if Orientation = sbVertical then
            TileControlIndex:=TileControlIndex - 1 // ColCount
          else
            TileControlIndex:=TileControlIndex - 1;

          ClearSelection();
          SelectControl;
        end;
        VK_DOWN: begin
          if Orientation = sbVertical then
            TileControlIndex:=TileControlIndex + 1 // ColCount
          else
            TileControlIndex:=TileControlIndex + 1;

          ClearSelection();
          SelectControl;
        end;
        VK_NEXT: begin
          TileControlIndex:=TileControlIndex + 1;

          ClearSelection();
          SelectControl;
        end;
        VK_PRIOR: begin
          TileControlIndex:=TileControlIndex - 1;

          ClearSelection();
          SelectControl;
        end;
      end;
    end
    else if Shift = [ssShift] then begin
      case Key of
        VK_LEFT: begin
          if Orientation = sbHorizontal then
            TileControlIndex:=TileControlIndex - 1 // RowCount
          else
            TileControlIndex:=TileControlIndex - 1;

          SelectControl;
        end;
        VK_RIGHT: begin
          if Orientation = sbHorizontal then
            TileControlIndex:=TileControlIndex + 1 // RowCount
          else
            TileControlIndex:=TileControlIndex + 1;

          SelectControl;
        end;
        VK_UP: begin
          if Orientation = sbVertical then
            TileControlIndex:=TileControlIndex - 1 // ColCount
          else
            TileControlIndex:=TileControlIndex - 1;

          SelectControl;
        end;
        VK_DOWN: begin
          if Orientation = sbVertical then
            TileControlIndex:=TileControlIndex + 1 // ColCount
          else
            TileControlIndex:=TileControlIndex + 1;

          SelectControl;
        end;
        VK_NEXT: begin
          TileControlIndex:=GetControlsCount - 1;

          SelectControl;
        end;
        VK_PRIOR: begin
          TileControlIndex:=0;

          SelectControl;
        end;
      end;
    end
    else
      inherited;
  end
  else
    inherited;
end;

//function TTileBox.CompareStrings(const S1, S2: String): Integer;
//begin
//  Result:=AnsiCompareText(S1, S2);
//end;

procedure TTileBox.ControlsAligned;

  procedure ShowScrollBar(const ScrollBar: TControlScrollBar);
  var
    HorzScrollSize, VertScrollSize: Integer;
  begin
    if not ScrollBar.IsScrollBarVisible then begin
      HorzScrollSize:=GetSystemMetrics(SM_CXHSCROLL) * 2;
      VertScrollSize:=GetSystemMetrics(SM_CXVSCROLL) * 2;
      if ((Orientation = sbVertical) and (ScrollBar.Kind = sbHorizontal) and (ScrollBar.Range > (ClientWidth + HorzScrollSize))) or
         ((Orientation = sbHorizontal) and (ScrollBar.Kind = sbVertical) and (ScrollBar.Range > (ClientHeight + VertScrollSize))) then
        ScrollBar.Visible:=True;
    end;
  end;

var
  HorzScrollBarVisible, VertScrollBarVisible: Boolean;
begin
  if not Updating then begin
    HorzScrollBarVisible:=HorzScrollBar.IsScrollBarVisible;
    VertScrollBarVisible:=VertScrollBar.IsScrollBarVisible;
    HorzScrollBar.Visible:=(Orientation = sbHorizontal) or HorzScrollBarVisible;
    VertScrollBar.Visible:=(Orientation = sbVertical) or VertScrollBarVisible;
    if Orientation = sbHorizontal then
      ShowScrollBar(VertScrollBar)
    else
      ShowScrollBar(HorzScrollBar);
  end;
end;

constructor TTileBox.Create(AOwner: TComponent);
begin
  FControlsCollection:=TTileControlsCollection.Create(Self);
  inherited Create(AOwner);
  ControlPainting:=False;

  ControlStyle:=ControlStyle + [csAcceptsControls, csCaptureMouse, csDesignInteractive, csClickEvents, csDoubleClicks, csDisplayDragImage];
  Align:=alNone;
  TabStop:=True;
  FSelectedColor:=clWebOrange;
  FHoverColor:=cl3DLight;
  FOrientation:=sbVertical;
  FSelectedControls:=TObjectList.Create(False);
//  FSelectedObjects.Clear;
  DoubleBuffered:=True;
//  FullRepaint:=True;
  FMultiselect:=False;
  LastControlClicked:=Nil;
  FActiveControl:=Nil;
  FControlIndex:=-1;
  FIndentHorz:=32;
  FIndentVert:=24;
  FGroupIndent:=32;
  FSpacer:=4;
  DoUpdate:=False;
  FRowCount:=0;
  FColCount:=0;
//  CalcRowsCols;
  FDragObject:=Nil;
  FControlPaint:=Nil;
  FControlPaintBkgnd:=Nil;
  FControlMeasure:=Nil;
  FControlsMultiPopupMenu:=Nil;
  FOnControlClick:=Nil;
  FOnControlDblClick:=Nil;
  DragMode:=dmNormal;


  VertScrollBar.Smooth:=True;
  VertScrollBar.Tracking:=True;
  HorzScrollBar.Smooth:=True;
  HorzScrollBar.Tracking:=True;
end;

procedure TTileBox.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do begin
    Style:=Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then begin
      Style:=Style and not WS_BORDER;
      ExStyle:=ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

destructor TTileBox.Destroy;
begin
//  FUserObjects.Clear;
//  FUserObjects.Free;
  FSelectedControls.Clear;
  FSelectedControls.Free;
  FControlsCollection.Free;
  inherited Destroy;
end;

procedure TTileBox.AfterConstruction;
begin
//
end;

procedure TTileBox.Loaded;
begin
  inherited;
  UpdateControlsCollectionIndexes;
end;

procedure TTileBox.DoClick;
begin
  if Assigned(FOnControlClick) then
    FOnControlClick(Self, ActiveControl, TileControlIndex);
end;

procedure TTileBox.DoDblClick;
begin
  if Assigned(FOnControlDblClick) then
    FOnControlDblClick(Self, ActiveControl, TileControlIndex);
end;

procedure TTileBox.DoPopup(const Sender: TObject);
begin
  if Assigned(FOnPopup) then
    FOnPopup(Sender);
end;

procedure TTileBox.DoPopupMulti(const Sender: TObject);
begin
  if Assigned(FOnPopupMulti) then
    FOnPopupMulti(Sender);
end;

procedure TTileBox.DoControlPaint(const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState);
begin
  if Assigned(FControlPaint) then
    FControlPaint(Sender, TargetCanvas, TargetRect, TargetState);
end;

procedure TTileBox.DoControlPaintBkgnd(const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState; var TargetStdPaint: Boolean);
begin
  if Assigned(FControlPaintBkgnd) then
    FControlPaintBkgnd(Sender, TargetCanvas, TargetRect, TargetState, TargetStdPaint);
end;

procedure TTileBox.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Tile: TCustomTileControl;
  idx: Integer;
  pt: TPoint;
begin
  Accept:=(Source is TTileBox) or (Source is TCustomTileControl) or (Source is TTileDragObject);
  if Accept then begin
    if State = dsDragEnter then begin
      if DragMode <> dmDragging then begin
        DragMode:=dmDragging;
        SavedBkgndColor:=Color;
        Color:=$002d2d2d;
      end;
    end
    else if State = dsDragMove then begin
      // here we have logic to move out columns or rows of Tiles from underneath of our dragging Tile
      // this will be done in the future updates
{
      pt:=CalculateControlPos(Point(X, Y));
      if (TTileDragObject(Source).Control <> Nil) and (TTileDragObject(Source).Control is TCustomTileControl) then begin
        Tile:=TCustomTileControl(TTileDragObject(Source).Control);
        //idx:=ControlsCollection.IndexOfTileControl(Tile);
        idx:=Tile.ControlsCollectionIndex;
        if idx > -1 then begin
          ControlsCollection.Items[idx].SetPosition(pt.X, pt.Y);
          UpdateControls(True);
        end;
      end;
}
    end
    else if State = dsDragLeave then begin
      // we can't relay on (X, Y) values from parameters, because they are control related only, and we need to know where we are relative to whole screen
      pt:=Mouse.CursorPos;
      pt:=ScreenToClient(pt);
      // so, here we have to determine if we are dragging ouside of TileBox or are we still inside
      // if we are inside, than we do nothing
      if not PtInRect(Rect(0, 0, ClientWidth, ClientHeight), pt) then begin
        DragMode:=dmDraggingOutside;
        Color:=SavedBkgndColor;
      end;
    end;
  end;
end;

procedure TTileBox.DragDrop(Source: TObject; X, Y: Integer);
var
  Tile: TCustomTileControl;
  idx: Integer;
  drop_pt: TPoint;
begin
  if Source is TTileDragObject then begin
    drop_pt:=CalculateControlPos(Point(X, Y));
    if (TTileDragObject(Source).Control <> Nil) and (TTileDragObject(Source).Control is TCustomTileControl) then begin
      Tile:=TCustomTileControl(TTileDragObject(Source).Control);
      //idx:=ControlsCollection.IndexOfTileControl(Tile);
      idx:=Tile.ControlsCollectionIndex;
      if idx > -1 then begin
        if PointsEqual(drop_pt, ControlsCollection.Items[idx].GetPosition) then begin
          ControlsCollection.Items[idx].FUserPosition:=False;
        end
        else begin
          if ControlsCollection.Items[idx].FUserPosition and ControlsCollection.Items[idx].TilePosition.AutoPositioning then
            ControlsCollection.Items[idx].TilePosition.AutoPositioning:=False;
        end;
        ControlsCollection.Items[idx].SetPosition(drop_pt.X, drop_pt.Y);
        UpdateControls(True);
      end;
    end;
  end;

//  ShowMessage(Format('DragDrop %s at %d, %d', [TTileDragObject(Source).Control.Name, X, Y]));
end;

procedure TTileBox.DoStartDrag(var DragObject: TDragObject);
begin
  DragMode:=dmDragging;
end;

procedure TTileBox.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  DragMode:=dmNormal;
  SharedEndDrag(Target, X, Y);
  Color:=SavedBkgndColor;
end;

procedure TTileBox.SharedEndDrag(Target: TObject; X, Y: Integer);
begin
  //All draggable controls share this event handler
  FDragObject.Free;
  FDragObject:=Nil;
end;

procedure TTileBox.DrawControl(const TargetControl: TTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState);
var
  CaptionText, Text1, Text2, Text3, Text4: String;
  H1, H2, H3, H4, text_width, text_height: Integer;
  MaxWidth, MaxHeight, IcoWidth, IcoHeight: Integer;
  text1_rect, text2_rect, text3_rect, text4_rect, text_rect: TRect;

  function HeightOfText(ACanvas: TCanvas; AText: String; var ARect: TRect; HAlignment: TAlignment; const VAlignment: TVerticalAlignment; WordWrap: Boolean; CanDraw: Boolean = False): Integer;
  const
    HAlignments: Array[TAlignment] of LongWord = (DT_LEFT, DT_RIGHT, DT_CENTER);
    VAlignments: array[TVerticalAlignment] of LongWord = (DT_TOP, DT_BOTTOM, DT_VCENTER);
    WordWrapOrNot: Array[Boolean] of LongWord = (DT_SINGLELINE, DT_WORDBREAK);
    DrawOrNot: Array[Boolean] of LongWord = (DT_CALCRECT, 0);
  var
    Flags: LongInt;
  begin
    if not CanDraw then
      ARect.Bottom:=1;
    Flags:=DT_EXPANDTABS or DT_NOPREFIX or DT_NOCLIP or HAlignments[HAlignment] or VAlignments[VAlignment] or WordWrapOrNot[WordWrap] or DT_END_ELLIPSIS or DrawOrNot[CanDraw];
    Flags:=DrawTextBiDiModeFlags(Flags);
    Result:=DrawText(ACanvas.Handle, PChar(AText), Length(AText), ARect, Flags);
  end;

  function CreateBitmap(const w: LongWord = 0; const h: LongWord = 0): TBitmap;
  begin
    Result:=TBitmap.Create;
    Result.PixelFormat:=pf32bit;
    Result.AlphaFormat:=afDefined;
    Result.TransparentMode:=tmFixed;
    Result.TransparentColor:=clWhite;
    Result.Transparent:=True;
    if (w <> 0) and (h <> 0) then
      Result.SetSize(w, h);
  end;

  function MakeBitmap(const Images: TImageList; const Index: Integer): TBitmap;
  begin
    Result:=CreateBitmap(Images.Width, Images.Height);
    Images.Draw(Result.Canvas, 0, 0, Index, dsNormal, itImage, True); // this is exactly the same as GetBitmap
  end;

  procedure DrawPicture(const Canvas: TCanvas; const StartPosX, StartPosY: Integer);
  var
    Ratio: Double;
    DestIcoWidth, DestIcoHeight: Integer;
    IcoRect: TRect;
    TempBmp: TBitmap;
  begin
    SetBkMode(Canvas.Handle, TRANSPARENT);
    try
      case TargetControl.Glyph.Mode of
        gmFill: begin // wypelnij caly kafelek
          IcoRect:=TargetControl.ClientRect;
          case TargetControl.Glyph.Align of
            gaDefault: ;
            gaTopLeft: OffsetRect(IcoRect, StartPosX, StartPosY);
            gaTopCenter: OffsetRect(IcoRect, 0, StartPosY);
            gaTopRight: OffsetRect(IcoRect, -TargetControl.Glyph.IndentHorz, StartPosY);
            gaMiddleLeft: OffsetRect(IcoRect, StartPosX, 0);
            gaMiddleCenter: OffsetRect(IcoRect, 0, 0);
            gaMiddleRight: OffsetRect(IcoRect, -TargetControl.Glyph.IndentHorz, 0);
            gaBottomLeft: OffsetRect(IcoRect, StartPosX, -TargetControl.Glyph.IndentVert);
            gaBottomCenter: OffsetRect(IcoRect, 0, -TargetControl.Glyph.IndentVert);
            gaBottomRight: OffsetRect(IcoRect, -TargetControl.Glyph.IndentHorz, -TargetControl.Glyph.IndentVert);
          end;
          if CaptionText <> '' then begin
            case TargetControl.Glyph.AlignWithCaption of
              gacNone: ;
              gacLeft  : OffsetRect(text_rect, MaxWidth - text_width - TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacRight : OffsetRect(text_rect, TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacTop   : OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, MaxHeight - text_height - TargetControl.Glyph.IndentVert);
              gacBottom: OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, TargetControl.Glyph.IndentVert);
            end;
          end;
          if (TargetControl.Glyph.Images <> Nil) and (TargetControl.Glyph.ImageIndex > -1) then begin
            TempBmp:=MakeBitmap(TargetControl.Glyph.Images, TargetControl.Glyph.ImageIndex);
            try
              Canvas.StretchDraw(IcoRect, TempBmp);
            finally
              TempBmp.Free;
            end;
          end
          else
            Canvas.StretchDraw(IcoRect, TargetControl.Glyph.Image.Graphic);
        end;
        gmFit: begin // probuj dopasowac do wysokosci lub szerokosci kafelka
          if IcoWidth > TargetControl.Width then begin
            DestIcoWidth:=TargetControl.Width;
            DestIcoHeight:=(TargetControl.Width * IcoHeight) div IcoWidth;
            IcoRect.Left:=0;
            IcoRect.Top:=0; // (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2;
            IcoRect.Right:=IcoRect.Left + DestIcoWidth;
            IcoRect.Bottom:=IcoRect.Top + DestIcoHeight;
          end
          else if IcoHeight > TargetControl.Height then begin
            DestIcoHeight:=TargetControl.Height;
            DestIcoWidth:=(TargetControl.Height * IcoWidth) div IcoHeight;
            IcoRect.Left:=0; // (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2;
            IcoRect.Top:=0;
            IcoRect.Right:=IcoRect.Left + DestIcoWidth;
            IcoRect.Bottom:=IcoRect.Top + DestIcoHeight;
          end
          else begin
            DestIcoHeight:=IcoWidth;
            DestIcoWidth:=IcoHeight;
            IcoRect.Left:=0; // (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2 - IcoWidth div 2;
            IcoRect.Top:=0; // (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2 - IcoHeight div 2;
            IcoRect.Right:=IcoRect.Left + DestIcoWidth;
            IcoRect.Bottom:=IcoRect.Top + DestIcoHeight;
          end;
          OffsetRect(IcoRect, StartPosX, StartPosY);
          if CaptionText <> '' then begin
            case TargetControl.Glyph.AlignWithCaption of
              gacNone: ;
              gacLeft  : OffsetRect(text_rect, MaxWidth - text_width - TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacRight : OffsetRect(text_rect, TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacTop   : OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, MaxHeight - text_height - TargetControl.Glyph.IndentVert);
              gacBottom: OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, TargetControl.Glyph.IndentVert);
            end;
          end;
          case TargetControl.Glyph.Align of
            gaDefault: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight div 2);
            gaTopLeft: ;
            gaTopCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, 0);
            gaTopRight: OffsetRect(IcoRect, -DestIcoWidth, 0);
            gaMiddleLeft: OffsetRect(IcoRect, 0, -DestIcoHeight div 2);
            gaMiddleCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight div 2);
            gaMiddleRight: OffsetRect(IcoRect, -DestIcoWidth, -DestIcoHeight div 2);
            gaBottomLeft: OffsetRect(IcoRect, 0, -DestIcoHeight);
            gaBottomCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight);
            gaBottomRight: OffsetRect(IcoRect, -DestIcoWidth, -DestIcoHeight);
          end;
          if (TargetControl.Glyph.Images <> Nil) and (TargetControl.Glyph.ImageIndex > -1) then begin
            TempBmp:=MakeBitmap(TargetControl.Glyph.Images, TargetControl.Glyph.ImageIndex);
            try
              Canvas.StretchDraw(IcoRect, TempBmp);
            finally
              TempBmp.Free;
            end;
          end
          else
            Canvas.StretchDraw(IcoRect, TargetControl.Glyph.Image.Graphic);
        end;
        gmNormal: begin
          IcoRect.Left:=0; // (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2 - IcoWidth div 2
          IcoRect.Top:=0; // (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2 - IcoHeight div 2;
          IcoRect.Right:=IcoRect.Left + IcoWidth;
          IcoRect.Bottom:=IcoRect.Top + IcoHeight;
          OffsetRect(IcoRect, StartPosX, StartPosY);
          if CaptionText <> '' then begin
            case TargetControl.Glyph.AlignWithCaption of
              gacNone: ;
              gacLeft: begin
                OffsetRect(text_rect, MaxWidth div 2 + IcoWidth div 2 - text_width div 2 + TargetControl.Glyph.IndentHorz div 2, MaxHeight div 2 - text_height div 2);
                OffsetRect(IcoRect, -TargetControl.Glyph.IndentHorz div 2 - text_width div 2, 0);
              end;
              gacRight: begin
                OffsetRect(text_rect, MaxWidth div 2 - IcoWidth div 2 - text_width div 2 - TargetControl.Glyph.IndentHorz div 2, MaxHeight div 2 - text_height div 2);
                OffsetRect(IcoRect, TargetControl.Glyph.IndentHorz div 2 + text_width div 2, 0);
              end;
              gacTop: begin;
                OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, MaxHeight div 2 + text_height div 2 + TargetControl.Glyph.IndentVert div 2);
                OffsetRect(IcoRect, 0, -TargetControl.Glyph.IndentVert div 2 - text_height div 2);
              end;
              gacBottom: begin
                OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, MaxHeight div 2 - IcoHeight div 2 - text_height div 2 - TargetControl.Glyph.IndentVert div 2);
                OffsetRect(IcoRect, 0, TargetControl.Glyph.IndentVert div 2 + text_height div 2);
              end;
            end;
          end;
          case TargetControl.Glyph.Align of
            gaDefault: OffsetRect(IcoRect, -IcoWidth div 2, -IcoHeight div 2);
            gaTopLeft: ;
            gaTopCenter: OffsetRect(IcoRect, -IcoWidth div 2, 0);
            gaTopRight: OffsetRect(IcoRect, -IcoWidth, 0);
            gaMiddleLeft: OffsetRect(IcoRect, 0, -IcoHeight div 2);
            gaMiddleCenter: OffsetRect(IcoRect, -IcoWidth div 2, -IcoHeight div 2);
            gaMiddleRight: OffsetRect(IcoRect, -IcoWidth, -IcoHeight div 2);
            gaBottomLeft: OffsetRect(IcoRect, 0, -IcoHeight);
            gaBottomCenter: OffsetRect(IcoRect, -IcoWidth div 2, -IcoHeight);
            gaBottomRight: OffsetRect(IcoRect, -IcoWidth, -IcoHeight);
          end;
          if (TargetControl.Glyph.Images <> Nil) and (TargetControl.Glyph.ImageIndex > -1) then begin
            TempBmp:=MakeBitmap(TargetControl.Glyph.Images, TargetControl.Glyph.ImageIndex);
            try
              Canvas.Draw(IcoRect.Left, IcoRect.Top, TempBmp);
            finally
              TempBmp.Free;
            end;
          end
          else
            Canvas.Draw(IcoRect.Left, IcoRect.Top, TargetControl.Glyph.Image.Graphic);
        end;
        gmProportionalStretch: begin
          if IcoWidth > IcoHeight then begin
            DestIcoHeight:=TargetControl.Height;
            DestIcoWidth:=(TargetControl.Height * IcoWidth) div IcoHeight;
            IcoRect.Left:=0; // - DestIcoWidth div 2; // (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2 - DestIcoWidth div 2;
            IcoRect.Top:=0;
            IcoRect.Right:=IcoRect.Left + DestIcoWidth;
            IcoRect.Bottom:=IcoRect.Top + DestIcoHeight;
          end
          else begin
            DestIcoWidth:=TargetControl.Width;
            DestIcoHeight:=(TargetControl.Width * IcoHeight) div IcoWidth;
            IcoRect.Left:=0;
            IcoRect.Top:=0; // - DestIcoHeight div 2; // (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2 - DestIcoHeight div 2;
            IcoRect.Right:=IcoRect.Left + DestIcoWidth;
            IcoRect.Bottom:=IcoRect.Top + DestIcoHeight;
          end;
          OffsetRect(IcoRect, StartPosX, StartPosY);
          if CaptionText <> '' then begin
            case TargetControl.Glyph.AlignWithCaption of
              gacNone: ;
              gacLeft  : OffsetRect(text_rect, MaxWidth - text_width - TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacRight : OffsetRect(text_rect, TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacTop   : OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, MaxHeight - text_height - TargetControl.Glyph.IndentVert);
              gacBottom: OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, TargetControl.Glyph.IndentVert);
            end;
          end;
          case TargetControl.Glyph.Align of
            gaDefault: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight div 2);
            gaTopLeft: OffsetRect(IcoRect, 0, 0);
            gaTopCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, 0);
            gaTopRight: OffsetRect(IcoRect, -DestIcoWidth, 0);
            gaMiddleLeft: OffsetRect(IcoRect, 0, -DestIcoHeight div 2);
            gaMiddleCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight div 2);
            gaMiddleRight: OffsetRect(IcoRect, -DestIcoWidth, -DestIcoHeight div 2);
            gaBottomLeft: OffsetRect(IcoRect, 0, -DestIcoHeight);
            gaBottomCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight);
            gaBottomRight: OffsetRect(IcoRect, -DestIcoWidth, -DestIcoHeight);
          end;
          if (TargetControl.Glyph.Images <> Nil) and (TargetControl.Glyph.ImageIndex > -1) then begin
            TempBmp:=MakeBitmap(TargetControl.Glyph.Images, TargetControl.Glyph.ImageIndex);
            try
              Canvas.StretchDraw(IcoRect, TempBmp);
            finally
              TempBmp.Free;
            end;
          end
          else
            Canvas.StretchDraw(IcoRect, TargetControl.Glyph.Image.Graphic);
        end;
        gmStretch: begin
          if IcoWidth > IcoHeight then begin
            Ratio:=IcoHeight / IcoWidth;
            DestIcoWidth:=Round(IcoWidth * Ratio);
            DestIcoHeight:=IcoHeight;
          end
          else begin
            Ratio:=IcoWidth / IcoHeight;
            DestIcoWidth:=IcoWidth;
            DestIcoHeight:=Round(IcoHeight * Ratio);
          end;
          IcoRect.Left:=0;
          IcoRect.Top:=0;
          IcoRect.Right:=IcoRect.Left + DestIcoWidth;
          IcoRect.Bottom:=IcoRect.Top + DestIcoHeight;
          OffsetRect(IcoRect, StartPosX, StartPosY);
          if CaptionText <> '' then begin
            case TargetControl.Glyph.AlignWithCaption of
              gacNone: ;
              gacLeft  : OffsetRect(text_rect, MaxWidth - text_width - TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacRight : OffsetRect(text_rect, TargetControl.Glyph.IndentHorz, MaxHeight div 2 - text_height div 2);
              gacTop   : OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, MaxHeight - text_height - TargetControl.Glyph.IndentVert);
              gacBottom: OffsetRect(text_rect, MaxWidth div 2 - text_width div 2, TargetControl.Glyph.IndentVert);
            end;
          end;
          case TargetControl.Glyph.Align of
            gaDefault: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight div 2);
            gaTopLeft: OffsetRect(IcoRect, 0, 0);
            gaTopCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, 0);
            gaTopRight: OffsetRect(IcoRect, -DestIcoWidth, 0);
            gaMiddleLeft: OffsetRect(IcoRect, 0, -DestIcoHeight div 2);
            gaMiddleCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight div 2);
            gaMiddleRight: OffsetRect(IcoRect, -DestIcoWidth, -DestIcoHeight div 2);
            gaBottomLeft: OffsetRect(IcoRect, 0, -DestIcoHeight);
            gaBottomCenter: OffsetRect(IcoRect, -DestIcoWidth div 2, -DestIcoHeight);
            gaBottomRight: OffsetRect(IcoRect, -DestIcoWidth, -DestIcoHeight);
          end;
          if (TargetControl.Glyph.Images <> Nil) and (TargetControl.Glyph.ImageIndex > -1) then begin
            TempBmp:=MakeBitmap(TargetControl.Glyph.Images, TargetControl.Glyph.ImageIndex);
            try
              Canvas.StretchDraw(IcoRect, TempBmp);
            finally
              TempBmp.Free;
            end;
          end
          else
            Canvas.StretchDraw(IcoRect, TargetControl.Glyph.Image.Graphic);
        end;
      end;
    finally
      SetBkMode(Canvas.Handle, OPAQUE);
    end;
  end;

//            if IcoHeight > H1 then begin
//              Draw(2, 2, TargetControl.Glyph.Image.Graphic);
//              Font.Assign(Self.Font);
//  //                if (TargetState = cdsSelected) or (TargetState = cdsSelFocused) then
//  //                  Font.Assign(FUserNameFontSelected);
//              HeightOfText(TargetCanvas, Text1, Rect(2 + IcoWidth + FSpacer, 2 + (IcoHeight - H1) div 2, IcoWidth + BM.Width - FSpacer - 6, 0), True);
//            end
//            else begin
            //Draw(2, 2 + (H1 - IcoHeight) div 2, TargetControl.Glyph.Image.Graphic);

//              Font.Assign(Self.Font);
  //                if (TargetState = cdsSelected) or (TargetState = cdsSelFocused) then
  //                  Font.Assign(FUserNameFontSelected);
//              HeightOfText(TargetCanvas, Text1, Rect(2 + IcoWidth + FSpacer, 2, IcoWidth + BM1.Width - FSpacer - 6, 0), True);
//            end;

  //              if (TargetState = cdsSelected) or (TargetState = cdsSelFocused) then
  //                Font.Assign(FUserNameFontSelected);

//            if (TargetState.UserInfoMsg <> '') and FShowUserInfo then begin
//              Font.Assign(FUserInfoMsgFont);
//
//              if (AState = idSelected) or (AState = idSelFocused) then
//                Font.Assign(FUserInfoMsgFontSelected);
//
//              if IcoHeight > H1 then
//                HeightOfText(ACanvas, Text2, Rect(0, 2 + IcoHeight, BM2.Width, 0), True)
//              else
//                HeightOfText(ACanvas, Text2, Rect(0, 2 + H1, BM2.Width, 0), True);
//            end;

begin
  MaxWidth:=Abs(TargetRect.Right - TargetRect.Left);
  MaxHeight:=Abs(TargetRect.Bottom - TargetRect.Top);
  IcoWidth:=0;
  IcoHeight:=0;

  CaptionText:=TargetControl.Caption;
  Text1:=TargetControl.Text1.Value;
  Text2:=TargetControl.Text2.Value;
  Text3:=TargetControl.Text3.Value;
  Text4:=TargetControl.Text4.Value;

  if (TargetControl.Glyph.Images <> Nil) and (TargetControl.Glyph.ImageIndex > -1) then begin
    IcoWidth:=TargetControl.Glyph.Images.Width;
    IcoHeight:=TargetControl.Glyph.Images.Height;
  end
  else if (TargetControl.Glyph.Image.Graphic <> Nil) and not TargetControl.Glyph.Image.Graphic.Empty then begin
    IcoWidth:=TargetControl.Glyph.Image.Width;
    IcoHeight:=TargetControl.Glyph.Image.Height;
  end;

  H1:=0;
  H2:=0;
  H3:=0;
  H4:=0;
  with TargetCanvas do begin
    //Lock;// already locked by TCustomControl.PaintWindow(DC: HDC);
    //try
      text_rect:=TargetControl.ClientRect;
      if (IcoWidth > 0) and (IcoHeight > 0) then begin
        InflateRect(text_rect, -2, -2);
        if (TargetControl.Glyph.AlignWithCaption > gacNone) and (CaptionText <> '') then begin
          Font.Assign(TargetControl.Font);
          text_width:=TextWidth(CaptionText);
          if text_width > (MaxWidth - 4) then
            text_width:=MaxWidth - 4;
          text_height:=HeightOfText(TargetCanvas, CaptionText, text_rect, taLeftJustify, taAlignTop, False);
          OffsetRect(text_rect, -2, -2);
        end;

        case TargetControl.Glyph.Align of
          gaDefault     : DrawPicture(TargetCanvas,
                                      (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2,
                                      (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2);
          gaTopLeft     : DrawPicture(TargetCanvas,
                                      TargetControl.Glyph.IndentHorz,
                                      TargetControl.Glyph.IndentVert);
          gaTopCenter   : DrawPicture(TargetCanvas,
                                      (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2,
                                      TargetControl.Glyph.IndentVert);
          gaTopRight    : DrawPicture(TargetCanvas,
                                      TargetControl.ClientRect.Right - TargetControl.Glyph.IndentHorz,
                                      TargetControl.Glyph.IndentVert);
          gaMiddleLeft  : DrawPicture(TargetCanvas,
                                      TargetControl.Glyph.IndentHorz,
                                      (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2);
          gaMiddleCenter: DrawPicture(TargetCanvas,
                                      (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2,
                                      (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2);
          gaMiddleRight : DrawPicture(TargetCanvas,
                                      TargetControl.ClientRect.Right - TargetControl.Glyph.IndentHorz,
                                      (TargetControl.ClientRect.Bottom - TargetControl.ClientRect.Top) div 2);
          gaBottomLeft  : DrawPicture(TargetCanvas,
                                      TargetControl.Glyph.IndentHorz,
                                      TargetControl.ClientRect.Bottom - TargetControl.Glyph.IndentVert);
          gaBottomCenter: DrawPicture(TargetCanvas,
                                      (TargetControl.ClientRect.Right - TargetControl.ClientRect.Left) div 2,
                                      TargetControl.ClientRect.Bottom - TargetControl.Glyph.IndentVert);
          gaBottomRight : DrawPicture(TargetCanvas,
                                      TargetControl.ClientRect.Right - TargetControl.Glyph.IndentHorz,
                                      TargetControl.ClientRect.Bottom - TargetControl.Glyph.IndentVert);
        end;
      end;
      if TargetControl.Caption <> '' then begin
        Brush.Style:=bsClear;
        Font.Assign(TargetControl.Font);
        if TargetControl.Glyph.AlignWithCaption = gacNone then
          HeightOfText(TargetCanvas, TargetControl.Caption, text_rect, TargetControl.Alignment, TargetControl.VerticalAlignment, TargetControl.WordWrap, True)
        else
          HeightOfText(TargetCanvas, TargetControl.Caption, text_rect, taLeftJustify, taAlignTop, False, True);
      end;
      if TargetControl.Size > tsSmall then begin
        if Text1 <> '' then begin
          text1_rect:=Rect(0, 0, Max(MaxWidth - TargetControl.Text1.IndentHorz * 2, 0), 0);
          Font.Assign(TargetControl.Text1.Font);
          H1:=HeightOfText(TargetCanvas, Text1, text1_rect, TargetControl.Text1.Alignment, taAlignTop, TargetControl.Text1.WordWrap);
          text_rect:=text1_rect;
          case TargetControl.Text1.Align of
            ttaDefault,
            ttaTopLeft: OffsetRect(text_rect, TargetControl.Text1.IndentHorz, TargetControl.Text1.IndentVert);
            ttaTopCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, TargetControl.Text1.IndentVert);
            ttaTopRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text1.IndentHorz, TargetControl.Text1.IndentVert);
            ttaMiddleLeft: OffsetRect(text_rect, TargetControl.Text1.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text1.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaBottomLeft: OffsetRect(text_rect, TargetControl.Text1.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text1.IndentVert);
            ttaBottomCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text1.IndentVert);
            ttaBottomRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text1.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text1.IndentVert);
          end;
          text1_rect:=text_rect;
          if TargetControl.Text1.Transparent then
            Brush.Style:=bsClear
          else begin
            if (TargetControl.Text1.BackgroundColor <> clNone) then begin
              Brush.Style:=bsSolid;
              if TargetControl.Text1.BackgroundColor <> clDefault then
                Brush.Color:=TargetControl.Text1.BackgroundColor
              else
                Brush.Color:=TargetControl.Color;
            end
            else
              Brush.Style:=bsClear;
          end;
          HeightOfText(TargetCanvas, Text1, text1_rect, TargetControl.Text1.Alignment, taAlignTop, TargetControl.Text1.WordWrap, True);
        end;

        if Text2 <> '' then begin
          text2_rect:=Rect(0, 0, Max(MaxWidth - TargetControl.Text2.IndentHorz * 2, 0), 0);
          Font.Assign(TargetControl.Text2.Font);
          H2:=HeightOfText(TargetCanvas, Text2, text2_rect, TargetControl.Text2.Alignment, taAlignTop, TargetControl.Text2.WordWrap);
          text_rect:=text2_rect;
          case TargetControl.Text2.Align of
            ttaTopLeft: OffsetRect(text_rect, TargetControl.Text2.IndentHorz, TargetControl.Text2.IndentVert);
            ttaTopCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, TargetControl.Text2.IndentVert);
            ttaDefault,
            ttaTopRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text2.IndentHorz, TargetControl.Text2.IndentVert);
            ttaMiddleLeft: OffsetRect(text_rect, TargetControl.Text2.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text2.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaBottomLeft: OffsetRect(text_rect, TargetControl.Text2.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text2.IndentVert);
            ttaBottomCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text2.IndentVert);
            ttaBottomRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text2.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text2.IndentVert);
          end;
          text2_rect:=text_rect;
          if TargetControl.Text2.Transparent then
            Brush.Style:=bsClear
          else begin
            if (TargetControl.Text2.BackgroundColor <> clNone) then begin
              Brush.Style:=bsSolid;
              if TargetControl.Text2.BackgroundColor <> clDefault then
                Brush.Color:=TargetControl.Text2.BackgroundColor
              else
                Brush.Color:=TargetControl.Color;
            end
            else
              Brush.Style:=bsClear;
          end;
          HeightOfText(TargetCanvas, Text2, text2_rect, TargetControl.Text2.Alignment, taAlignTop, TargetControl.Text2.WordWrap, True);
        end;

        if Text3 <> '' then begin
          text3_rect:=Rect(0, 0, Max(MaxWidth - TargetControl.Text3.IndentHorz * 2, 0), 0);
          Font.Assign(TargetControl.Text3.Font);
          H3:=HeightOfText(TargetCanvas, Text3, text3_rect, TargetControl.Text3.Alignment, taAlignTop, TargetControl.Text3.WordWrap);
          text_rect:=text3_rect;
          case TargetControl.Text3.Align of
            ttaTopLeft: OffsetRect(text_rect, TargetControl.Text3.IndentHorz, TargetControl.Text3.IndentVert);
            ttaTopCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, TargetControl.Text3.IndentVert);
            ttaTopRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text3.IndentHorz, TargetControl.Text3.IndentVert);
            ttaMiddleLeft: OffsetRect(text_rect, TargetControl.Text3.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text3.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaDefault,
            ttaBottomLeft: OffsetRect(text_rect, TargetControl.Text3.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text3.IndentVert);
            ttaBottomCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text3.IndentVert);
            ttaBottomRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text3.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text3.IndentVert);
          end;
          text3_rect:=text_rect;
          if TargetControl.Text3.Transparent then
            Brush.Style:=bsClear
          else begin
            if (TargetControl.Text3.BackgroundColor <> clNone) then begin
              Brush.Style:=bsSolid;
              if TargetControl.Text3.BackgroundColor <> clDefault then
                Brush.Color:=TargetControl.Text3.BackgroundColor
              else
                Brush.Color:=TargetControl.Color;
            end
            else
              Brush.Style:=bsClear;
          end;
          HeightOfText(TargetCanvas, Text3, text3_rect, TargetControl.Text3.Alignment, taAlignTop, TargetControl.Text3.WordWrap, True);
        end;

        if Text4 <> '' then begin
          text4_rect:=Rect(0, 0, Max(MaxWidth - TargetControl.Text4.IndentHorz * 2, 0), 0);
          Font.Assign(TargetControl.Text4.Font);
          H4:=HeightOfText(TargetCanvas, Text4, text4_rect, TargetControl.Text4.Alignment, taAlignTop, TargetControl.Text4.WordWrap);
//          OffsetRect(text4_rect, TargetControl.ClientWidth - (text4_rect.Right - text4_rect.Left) - TargetControl.Text4.IndentHorz, TargetControl.ClientHeight - (text4_rect.Bottom - text4_rect.Top) - TargetControl.Text4.IndentVert);
          text_rect:=text4_rect;
          case TargetControl.Text4.Align of
            ttaTopLeft: OffsetRect(text_rect, TargetControl.Text4.IndentHorz, TargetControl.Text4.IndentVert);
            ttaTopCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, TargetControl.Text4.IndentVert);
            ttaTopRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text4.IndentHorz, TargetControl.Text4.IndentVert);
            ttaMiddleLeft: OffsetRect(text_rect, TargetControl.Text4.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaMiddleRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text4.IndentHorz, MaxHeight div 2 - (text_rect.Bottom - text_rect.Top) div 2);
            ttaBottomLeft: OffsetRect(text_rect, TargetControl.Text4.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text4.IndentVert);
            ttaBottomCenter: OffsetRect(text_rect, MaxWidth div 2 - (text_rect.Right - text_rect.Left) div 2, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text4.IndentVert);
            ttaDefault,
            ttaBottomRight: OffsetRect(text_rect, MaxWidth - (text_rect.Right - text_rect.Left) - TargetControl.Text4.IndentHorz, MaxHeight - (text_rect.Bottom - text_rect.Top) - TargetControl.Text4.IndentVert);
          end;
          text4_rect:=text_rect;
          if TargetControl.Text4.Transparent then
            Brush.Style:=bsClear
          else begin
            if (TargetControl.Text4.BackgroundColor <> clNone) then begin
              Brush.Style:=bsSolid;
              if TargetControl.Text4.BackgroundColor <> clDefault then
                Brush.Color:=TargetControl.Text4.BackgroundColor
              else
                Brush.Color:=TargetControl.Color;
            end
            else
              Brush.Style:=bsClear;
          end;
          HeightOfText(TargetCanvas, Text4, text4_rect, TargetControl.Text4.Alignment, taAlignTop, TargetControl.Text4.WordWrap, True);
        end;
      end;
    //finally
    //  Unlock;
    //end;
  end;
end;

function TTileBox.GetTileControl(Index: Integer): TTileControl;
begin
  if (Index < 0) or (Index >= GetControlsCount) then
    Exception.CreateFmt(SListIndexError, [Index]);
  Result:=TTileControl(Self.Controls[Index]);
end;

function TTileBox.GetControlDrawState(Index: Integer): TTileControlDrawState;
var
  Tile: TTileControl;
begin
  Result:=cdsNormal;

  if GetControlsCount = 0 then
    Exit;

  if (Index < 0) or (Index >= GetControlsCount) then
    Exit;

  Tile:=GetTileControl(Index);
  if not FMultiselect then begin
    if (ActiveControl <> Nil) and (ActiveControl = Tile) then begin
      Result:=cdsSelected;
      if Index = FControlIndex then
        Result:=cdsSelFocused;
    end
    else if Index = FControlIndex then
      Result:=cdsFocused;
  end
  else begin
    if Self.IndexOf(Tile) >= 0 then begin
      Result:=cdsSelected;
      if Index = FControlIndex then
        Result:=cdsSelFocused;
    end
    else if Index = FControlIndex then
      Result:=cdsFocused;
  end;
end;

function TTileBox.GetControlsCount: Integer;
begin
  Result:=Self.ControlCount;
end;

function TTileBox.GetSelectedCount: Integer;
var
  i: Integer;
begin
  Result:=0;
  if GetControlsCount > 0 then begin
    for i:=0 to GetControlsCount - 1 do begin
      if TileSelected[i] in [cdsSelected, cdsSelFocused] then
        Inc(Result);
    end;
  end;
end;

function TTileBox.IndexOf(const Control: TCustomTileControl): Integer;
var
  i: Integer;
  Tile: TTileControl;
begin
  Result:=-1;
  if Control = Nil then
    Exit;

  for i:=0 to GetControlsCount - 1 do begin
    Tile:=GetTileControl(i);
    if Tile = Control then begin
      Result:=i;
      Break;
    end;
  end;
end;

function TTileBox.IndexOfPopup(const Sender: TObject): Integer;
var
  Popup: TPopupMenu;
begin
  for Result:=0 to GetControlsCount - 1 do begin
    Popup:=GetTileControl(Result).PopupMenu;

    if (Popup <> Nil) and (Sender <> Nil) and (Sender is TMenuItem) then
      if Popup = (Sender as TMenuItem).GetParentMenu then
        Exit;
  end;

  Result:=-1;
end;

function TTileBox.IndexOfSelected(const Control: TCustomTileControl): Integer;
begin
  Result:=FSelectedControls.IndexOf(Control);
end;

procedure TTileBox.MakeVisible(const Bounds: TRect);
var
  Rect: TRect;
begin
  // dodac sprawdzanie skrolowania, bo sie nie da przewijac, jak ciagle probuje zachowac kafelek na widoku
  Rect:=Bounds;
  Dec(Rect.Left, HorzScrollBar.Margin);
  Inc(Rect.Right, HorzScrollBar.Margin);
  Dec(Rect.Top, VertScrollBar.Margin);
  Inc(Rect.Bottom, VertScrollBar.Margin);

  if Rect.Left < 0 then begin
    with HorzScrollBar do
      Position:=Position + Rect.Left;
  end
  else if Rect.Right > ClientWidth then begin
    if Rect.Right - Rect.Left > ClientWidth then
      Rect.Right:=Rect.Left + ClientWidth;

    with HorzScrollBar do
      Position:=Position + Rect.Right - ClientWidth;
  end;

  if Rect.Top < 0 then begin
    with VertScrollBar do
      Position:=Position + Rect.Top;
  end
  else if Rect.Bottom > ClientHeight then begin
    if Rect.Bottom - Rect.Top > ClientHeight then
      Rect.Bottom:=Rect.Top + ClientHeight;

    with VertScrollBar do
      Position:=Position + Rect.Bottom - ClientHeight;
  end;
end;

procedure TTileBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TabStop and CanFocus then
    SetFocus;
  inherited;
  if Button = mbLeft then
    ClearSelection(True);
end;

procedure TTileBox.PaintWindow(DC: HDC);
begin
  //  Do nothing
end;

function TTileBox.RemoveTile(var Tile: TTileControl): Boolean;
begin
  Result:=False;
  if (Tile <> Nil) and (Tile.Parent = Self) then begin
    Tile.Visible:=False;
    Tile.Free;
    Tile:=Nil;
    Result:=True;
  end;
end;

procedure TTileBox.Resize;
begin
  inherited Resize;
  CalcRowsCols;
  UpdateControls(True);
  CalcScrollBar(HorzScrollBar);
  CalcScrollBar(VertScrollBar);
end;

procedure TTileBox.SetActiveControl(const Value: TTileControl);
begin
//  if FActiveControl <> Value then
    FActiveControl:=Value;
end;

procedure TTileBox.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then begin
    if Value = bsSingle then begin
      FBorderStyle := Value;
      RecreateWnd;
    end
    else
      FBorderStyle := Value;
  end;
end;

procedure TTileBox.SetTileControl(Index: Integer; const Control: TTileControl);
begin
  if (Index < 0) or (Index >= GetControlsCount) then
    Exception.CreateFmt(SListIndexError, [Index]);

//  Self.Components[Index]:=Value;
  UpdateControls(True);
end;

procedure TTileBox.SetControlDrawState(Index: Integer; const DrawState: TTileControlDrawState);
var
  Tile: TTileControl;
begin
  if not FMultiselect then
    Exit;

  if GetControlsCount = 0 then
    Exit;

  if (Index < 0) or (Index >= GetControlsCount) then
    Exit;

  Tile:=GetTileControl(Index);

  if DrawState = cdsSelected then
    SetSelected(Tile, False)
  else if DrawState = cdsNormal then
    SetSelected(Tile);

  UpdateControls(True);
end;

procedure TTileBox.SetControlIndex(const Value: Integer);
var
  Tile: TTileControl;
  LastActiveControl: TTileControl;
begin
  if Value = FControlIndex then
    Exit;

  if (Value >= 0) and (Value < GetControlsCount) then begin
    FControlIndex:=Value;
    Tile:=GetTileControl(FControlIndex);
    if Tile <> Nil then
      MakeVisible(Tile.BoundsRect);

    if TabStop and not Focused then
      SetFocus;

    LastActiveControl:=ActiveControl;
    ActiveControl:=Tile;
    if LastActiveControl <> Nil then
      LastActiveControl.Invalidate;
//    UpdateControls(True);
    if ActiveControl <> Nil then
      ActiveControl.Invalidate;
  end
  else begin
    if GetControlsCount > 0 then begin
      FControlIndex:=0;
      Tile:=GetTileControl(FControlIndex);
      if Tile <> Nil then
        MakeVisible(Tile.BoundsRect);

      if TabStop and not Focused then
        SetFocus;

      LastActiveControl:=ActiveControl;
      ActiveControl:=Tile;
      if LastActiveControl <> Nil then
        LastActiveControl.Invalidate;
//      UpdateControls(True);
      if ActiveControl <> Nil then
        ActiveControl.Invalidate;
    end
    else begin
      FControlIndex:=-1;
      LastActiveControl:=ActiveControl;
      ActiveControl:=Nil;
      if LastActiveControl <> Nil then
        LastActiveControl.Invalidate;
//      UpdateControl(FControlIndex);
      if ActiveControl <> Nil then
        ActiveControl.Invalidate;
    end;
  end;

  if Assigned(FOnChange) then
    OnChangeSelection(Self);
end;

procedure TTileBox.SetControlsCollection(const Value: TTileControlsCollection);
begin
  FControlsCollection.Assign(Value);
end;

procedure TTileBox.SetGroupIndent(const Value: Word);
begin
  if FGroupIndent <> Value then begin
    FGroupIndent:=Value;
    DoUpdate:=True;
    Realign;
  end;
end;

procedure TTileBox.SetHoverColor(const Value: TColor);
begin
  if FHoverColor <> Value then begin
    FHoverColor:=Value;
    UpdateControls(True);
  end;
end;

procedure TTileBox.SetIndentHorz(const Value: Word);
begin
  if FIndentHorz <> Value then begin
    FIndentHorz:=Value;
    DoUpdate:=True;
    Realign;
  end;
end;

procedure TTileBox.SetIndentVert(const Value: Word);
begin
  if FIndentVert <> Value then begin
    FIndentVert:=Value;
    DoUpdate:=True;
    Realign;
  end;
end;

procedure TTileBox.SetSpacer(const Value: Word);
begin
  if FSpacer <> Value then begin
    FSpacer:=Value;
    UpdateControls(True);
  end;
end;

procedure TTileBox.SetOrientation(const Value: TScrollBarKind);
begin
  if FOrientation <> Value then begin
    FOrientation:=Value;
    UpdateControls(True);
  end;
end;

procedure TTileBox.SetSelectedColor(const Value: TColor);
begin
  if FSelectedColor <> Value then begin
    FSelectedColor:=Value;
    UpdateControls(True);
  end;
end;

procedure TTileBox.SetMultiselect(const Value: Boolean);
begin
  if FMultiselect <> Value then begin
    FMultiselect:=Value;
    UpdateControls(True);
  end;
end;

procedure TTileBox.SetSelected(const Control: TTileControl; const CanDeselect: Boolean = True);
var
  LastActiveControl: TTileControl;
begin


  if Control = Nil then
    Exit;

  if FMultiselect then begin
    if FSelectedControls.IndexOf(Control) = - 1 then
      FSelectedControls.Add(Control)
    else if CanDeselect then
      FSelectedControls.Remove(Control);

    UpdateControls(True);
  end
  else begin
    LastActiveControl:=ActiveControl;
    ActiveControl:=Control;
    if CanDeselect and (LastActiveControl <> Nil) then
      LastActiveControl.Invalidate;
//    UpdateControls(True);
    if ActiveControl <> Nil then
      ActiveControl.Invalidate;
  end;
end;

procedure TTileBox.UpdateTiles;
begin
  if HandleAllocated and (GetControlsCount > 0) and HorzScrollBar.Visible and VertScrollBar.Visible then
    UpdateControls(True);
end;

procedure TTileBox.UpdateControl(const Index: Integer);
var
  i: Integer;
begin
  if (Index >= 0) and (Index < GetControlsCount) then
    GetTileControl(Index).Invalidate
  else if Index = - 1 then begin
    for i:=GetControlsCount - 1 downto 0 do
      GetTileControl(i).Invalidate;
    Update;
  end;
end;

procedure TTileBox.UpdateControls(const Rebuild: Boolean);
begin
  if Updating then
    Exit;
  //
  Updating:=True;
  try
    if (GetControlsCount > 0) then begin
      if Rebuild then begin
        FControlsCollection.RebuildAlignment;
        FControlsCollection.AlignTileControls(Nil);
      end;

      Update;
    end;
  finally
    Updating:=False;
  end;
end;

procedure TTileBox.UpdateControlsCollectionIndexes;
begin
  FControlsCollection.Update(Nil);
end;

procedure TTileBox.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  if not ControlPainting then
    inherited
  else
    Message.Result:=1;
end;

procedure TTileBox.WMMouseWheel(var Msg: TMessage);
var
  IsNeg: Boolean;
  Rect: TRect;
  Pt: TPoint;
begin
  GetWindowRect(WindowHandle, Rect);
  Pt.X:=LoWord(Msg.LParam);
  Pt.Y:=HiWord(Msg.LParam);

  if PtInRect(Rect, Pt) then begin
    Msg.Result:=1;
    Inc(WheelAccumulator, SmallInt(HiWord(Msg.WParam)));

    while Abs(WheelAccumulator) >= WHEEL_DELTA do begin
      IsNeg:=(WheelAccumulator < 0);
      WheelAccumulator:=Abs(WheelAccumulator) - WHEEL_DELTA;

      if IsNeg then begin
        WheelAccumulator:=-WheelAccumulator;

        if Orientation = sbVertical then begin
          if VertScrollBar.Visible then
            VertScrollBar.Position := VertScrollBar.Position + VertScrollBar.Increment;
        end
        else if HorzScrollBar.Visible then
          HorzScrollBar.Position := HorzScrollBar.Position + HorzScrollBar.Increment;
      end
      else begin
        if Orientation = sbVertical then begin
          if VertScrollBar.Visible then
            VertScrollBar.Position := VertScrollBar.Position - VertScrollBar.Increment;
        end
        else if HorzScrollBar.Visible then
          HorzScrollBar.Position := HorzScrollBar.Position - HorzScrollBar.Increment;
      end;
    end;
  end;
end;

procedure TTileBox.WMNCHitTest(var Message: TWMNCHitTest);
begin
  DefaultHandler(Message);
end;

procedure TTileBox.WMPrintClient(var Message: TWMPrintClient);
//var
//  LControlState: TControlState;
begin
//  LControlState:=Self.ControlState;
//  Exclude(LControlState, csPrintClient);
//  Self.ControlState:=LControlState;
//  Message.Result:=1;
  inherited;
end;

procedure TTileBox.WndProc(var Message: TMessage);
begin
  case Message.Msg of
//    WM_MOUSEWHEEL,
//    WM_MOUSEHWHEEL: begin
//      if TWMMouseWheel(Message).Keys = 0 then begin
//        if CheckWin32Version(6) then begin
//          if (Self.Orientation = sbVertical) and VertScrollBar.Visible then
//            Self.ScrollBy(0, TWMMouseWheel(Message).WheelDelta)
//          else if (Self.Orientation = sbHorizontal) and HorzScrollBar.Visible then
//            Self.ScrollBy(TWMMouseWheel(Message).WheelDelta, 0);
//        end
//        else
//          inherited;
//      end
//      else
//        inherited;
//    end;
    CM_MOUSEENTER: begin
      inherited;
      FMouseInControl:=True;
      Invalidate;
    end;
    CM_MOUSELEAVE: begin
      inherited;
      FMouseInControl:=False;
      Invalidate;
    end;
    CM_ENTER: begin
      inherited;
      Invalidate;
    end;
    CM_EXIT: begin
      inherited;
      Invalidate;
    end;
  else
    inherited;
  end;
end;

end.
