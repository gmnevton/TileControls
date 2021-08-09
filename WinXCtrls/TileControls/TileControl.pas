unit TileControl;

interface

uses
  SysUtils,
  Windows,
  Messages,
  Classes,
  Controls,
  Types,
  Graphics;

type
  TTileControl = class;
  TCustomTileControl = class;

  TTileControlDrawState = (cdsNormal, cdsSelected, cdsFocused, cdsSelFocused); //, cdsHovered, cdsSelectedHovered, cdsFocusedHovered, cdsSelFocusedHovered);

  TTilePaintEvent = procedure (const Sender: TCustomTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect{; var StdPaint: Boolean}) of object;

  TTileControlPaintEvent = procedure (const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState) of object;

  TTileGlyphAlign = (gaDefault, gaTopLeft, gaTopCenter, gaTopRight,
                                gaMiddleLeft, gaMiddleCenter, gaMiddleRight ,
                                gaBottomLeft, gaBottomCenter, gaBottomRight);
  TTileGlyphAlignWithCaption = (gacNone, gacLeft, gacRight, gacTop, gacBottom);
  TTileGlyphMode = (gmFill, gmFit, gmNormal, gmProportionalStretch, gmStretch);

  TTileGlyph = class(TPersistent)
  private
    FOwner: TCustomTileControl;
    FAlign: TTileGlyphAlign; // polozenie obrazu
    FAlignWithCaption: TTileGlyphAlignWithCaption; // polozenie wzgledem tekstu
    FImage: TPicture;
    FImageIndex: Integer;
    FImages: TImageList;
    FIndentHorz: Word;
    FIndentVert: Word;
    FMode: TTileGlyphMode; // tryb wyswietlania obrazu

    procedure SetAlign(const Value: TTileGlyphAlign);
    procedure SetAlignWithCaption(const Value: TTileGlyphAlignWithCaption);
    procedure SetImage(const Value: TPicture);
    procedure SetImageIndex(const Value: Integer);
    procedure SetImages(const Value: TImageList);
    procedure SetIndentHorz(const Value: Word);
    procedure SetIndentVert(const Value: Word);
    procedure SetMode(const Value: TTileGlyphMode);
    procedure ImageChanged(Sender: TObject);
  protected
    function GetOwner: TPersistent; override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TCustomTileControl); reintroduce;
    destructor Destroy; override;
  published
    property Align: TTileGlyphAlign read FAlign write SetAlign default gaDefault;
    property AlignWithCaption: TTileGlyphAlignWithCaption read FAlignWithCaption write SetAlignWithCaption default gacNone;
    property Image: TPicture read FImage write SetImage;
    property Images: TImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex stored True default -1;
    property IndentHorz: Word read FIndentHorz write SetIndentHorz default 0;
    property IndentVert: Word read FIndentVert write SetIndentVert default 0;
    property Mode: TTileGlyphMode read FMode write SetMode default gmNormal;
  end;

  TTileTextAlign = (ttaDefault, ttaTopLeft, ttaTopCenter, ttaTopRight,
                                ttaMiddleLeft, ttaMiddleCenter, ttaMiddleRight ,
                                ttaBottomLeft, ttaBottomCenter, ttaBottomRight);

  TTileText = class(TPersistent)
  private
    FOwner: TCustomTileControl;
    FAlign: TTileTextAlign;
    FAlignment: TAlignment;
    FBackgroundColor: TColor;
    FFont: TFont;
    FIndentHorz: Word;
    FIndentVert: Word;
    FTransparent: Boolean;
    FValue: String;
    FWordWrap: Boolean;

    procedure SetAlign(const Value: TTileTextAlign);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetIndentHorz(const Value: Word);
    procedure SetIndentVert(const Value: Word);
    procedure SetTransparent(const Value: Boolean);
    procedure SetValue(const Value: String);
    procedure SetWordWrap(const Value: Boolean);
    procedure FontChanged(Sender: TObject);
  protected
    function GetOwner: TPersistent; override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TCustomTileControl); reintroduce;
    destructor Destroy; override;
  published
    property Align: TTileTextAlign read FAlign write SetAlign default ttaDefault;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clDefault;
    property Font: TFont read FFont write SetFont;
    property IndentHorz: Word read FIndentHorz write SetIndentHorz default 4;
    property IndentVert: Word read FIndentVert write SetIndentVert default 4;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Value: String read FValue write SetValue;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default True;
  end;

  TTileSize = (tsSmall, tsRegular, tsLarge, tsExtraLarge, tsCustom);
  TTileSizeType = 1..MAXBYTE;

  TCustomTileControl = class(TGraphicControl)
  private
    FAlignment: TAlignment;
    FVerticalAlignment: TVerticalAlignment;
    FGlyph: TTileGlyph;
    FSize: TTileSize;
    FSizeCustomCols: TTileSizeType;
    FSizeCustomRows: TTileSizeType;
    FSizeFixed: Boolean;
    FText1: TTileText;
    FText2: TTileText;
    FText3: TTileText;
    FText4: TTileText;
    FWordWrap: Boolean;
    FHovered: Boolean;
    FTransparent: Boolean;
    FOnPaint: TTilePaintEvent;
    FLastLMouseClick: TPoint;
    FLMouseClicked: Boolean;

    procedure SetAlignment(Value: TAlignment);
    procedure SetVerticalAlignment(const Value: TVerticalAlignment);
    procedure SetGlyph(const Value: TTileGlyph);
    procedure SetSize(const Value: TTileSize);
    procedure SetSizeCustomCols(const Value: TTileSizeType);
    procedure SetSizeCustomRows(const Value: TTileSizeType);
    procedure SetSizeFixed(const Value: Boolean);
    procedure SetText1(const Value: TTileText);
    procedure SetText2(const Value: TTileText);
    procedure SetText3(const Value: TTileText);
    procedure SetText4(const Value: TTileText);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetHovered(const Value: Boolean);
    procedure SetTransparent(const Value: Boolean);
    procedure SetManualUserPosition;
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMControlListChanging(var Msg: TCMControlListChanging); message CM_CONTROLLISTCHANGING;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
//    procedure DisplayShadow; virtual;
//    procedure HideShadow; virtual;
//    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure Paint; override;
    procedure PaintTo(DC: HDC; X, Y: Integer); overload;
    procedure PaintTo(Canvas: TCanvas; X, Y: Integer); overload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
//    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property Canvas;
    property OnPaint: TTilePaintEvent read FOnPaint write FOnPaint;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property VerticalAlignment: TVerticalAlignment read FVerticalAlignment write SetVerticalAlignment default taVerticalCenter;
    property Glyph: TTileGlyph read FGlyph write SetGlyph;
    property Size: TTileSize read FSize write SetSize default tsRegular;
    property SizeCustomCols: TTileSizeType read FSizeCustomCols write SetSizeCustomCols default 2;
    property SizeCustomRows: TTileSizeType read FSizeCustomRows write SetSizeCustomRows default 2;
    property SizeFixed: Boolean read FSizeFixed write SetSizeFixed default True;
    property Text1: TTileText read FText1 write SetText1;
    property Text2: TTileText read FText2 write SetText2;
    property Text3: TTileText read FText3 write SetText3;
    property Text4: TTileText read FText4 write SetText4;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property Hovered: Boolean read FHovered write SetHovered default False;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TTileControl = class(TCustomTileControl)
  published
    property Caption;
    property Color;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
  end;

implementation

uses
  TileTypes,
  TileBox,
  TileControlDrag;

type
  TTileBoxAccess = class(TTileBox);

{ TTileGlyph }

constructor TTileGlyph.Create(AOwner: TCustomTileControl);
begin
  inherited Create;
  FOwner:=AOwner;
  FAlign:=gaDefault;
  FAlignWithCaption:=gacNone;
  FImage:=TPicture.Create;
  FImage.OnChange:=ImageChanged;
  FImageIndex:=-1;
  FImages:=Nil;
  FIndentHorz:=0;
  FIndentVert:=0;
  FMode:=gmNormal;
end;

destructor TTileGlyph.Destroy;
begin
  FImages:=Nil;
  FImage.OnChange:=Nil;
  FreeAndNil(FImage);
  FOwner:=Nil;
  inherited Destroy;
end;

function TTileGlyph.GetOwner: TPersistent;
begin
  Result:=FOwner;
end;

procedure TTileGlyph.AssignTo(Dest: TPersistent);
begin
  if Dest is TTileGlyph then
    with TTileGlyph(Dest) do begin
      FAlign:=Self.FAlign;
      FAlignWithCaption:=Self.FAlignWithCaption;
      FImage:=Self.FImage;
      FImageIndex:=Self.FImageIndex;
      FImages:=Self.FImages;
      FIndentHorz:=Self.FIndentHorz;
      FIndentVert:=Self.FIndentVert;
      FMode:=Self.FMode;
      if FOwner <> Nil then
        FOwner.Invalidate;
    end
  else
    inherited;
end;

procedure TTileGlyph.SetAlign(const Value: TTileGlyphAlign);
begin
  if FAlign <> Value then begin
    FAlign:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileGlyph.SetAlignWithCaption(const Value: TTileGlyphAlignWithCaption);
begin
  if FAlignWithCaption <> Value then begin
    FAlignWithCaption:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileGlyph.SetImage(const Value: TPicture);
begin
  FImage.Assign(Value);
  if FOwner <> Nil then
    FOwner.Invalidate;
end;

procedure TTileGlyph.SetImageIndex(const Value: Integer);
begin
  if (FImages = Nil) and (csLoading in FOwner.ComponentState) then begin
    FImageIndex:=Value;
  end
  else if (FImages <> Nil) and (FImageIndex <> Value) then begin
    if ((Value >= -1) and (Value < FImages.Count)) then
      FImageIndex:=Value
    else
      FImageIndex:=-1;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end
  else if (FImages = Nil) and (Value <> -1) then
    FImageIndex:=-1;
end;

procedure TTileGlyph.SetImages(const Value: TImageList);
begin
  FImages:=Value;
  if not (csLoading in FOwner.ComponentState) then
    FImageIndex:=-1;
  if FOwner <> Nil then
    FOwner.Invalidate;
end;

procedure TTileGlyph.SetIndentHorz(const Value: Word);
begin
  if FIndentHorz <> Value then begin
    FIndentHorz:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileGlyph.SetIndentVert(const Value: Word);
begin
  if FIndentVert <> Value then begin
    FIndentVert:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileGlyph.SetMode(const Value: TTileGlyphMode);
begin
  if FMode <> Value then begin
    FMode:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileGlyph.ImageChanged(Sender: TObject);
begin
  if FOwner <> Nil then
    FOwner.Invalidate;
end;

{ TTileText }

constructor TTileText.Create(AOwner: TCustomTileControl);
begin
  inherited Create;
  FOwner:=AOwner;
  FAlign:=ttaDefault;
  FAlignment:=taLeftJustify;
  FBackgroundColor:=clDefault;
  FFont:=TFont.Create;
  FFont.OnChange:=FontChanged;
  FIndentHorz:=4;
  FIndentVert:=4;
  FTransparent:=True;
  FValue:='';
  FWordWrap:=True;
end;

destructor TTileText.Destroy;
begin
  FFont.OnChange:=Nil;
  FreeAndNil(FFont);
  FOwner:=Nil;
  inherited Destroy;
end;

function TTileText.GetOwner: TPersistent;
begin
  Result:=FOwner;
end;

procedure TTileText.AssignTo(Dest: TPersistent);
begin
  if Dest is TTileText then
    with TTileText(Dest) do begin
      FAlign:=Self.FAlign;
      FAlignment:=Self.FAlignment;
      FBackgroundColor:=Self.FBackgroundColor;
      FFont:=Self.FFont;
      FIndentHorz:=Self.FIndentHorz;
      FIndentVert:=Self.FIndentVert;
      FTransparent:=Self.FTransparent;
      FValue:=Self.FValue;
      FWordWrap:=Self.FWordWrap;
      if FOwner <> Nil then
        FOwner.Invalidate;
    end
  else
    inherited;
end;

procedure TTileText.SetAlign(const Value: TTileTextAlign);
begin
  if FAlign <> Value then begin
    FAlign:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetAlignment(const Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor <> Value then begin
    FBackgroundColor:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  if FOwner <> Nil then
    FOwner.Invalidate;
end;

procedure TTileText.SetIndentHorz(const Value: Word);
begin
  if FIndentHorz <> Value then begin
    FIndentHorz:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetIndentVert(const Value: Word);
begin
  if FIndentVert <> Value then begin
    FIndentVert:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then begin
    FTransparent:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetValue(const Value: String);
begin
  if FValue <> Value then begin
    FValue:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then begin
    FWordWrap:=Value;
    if FOwner <> Nil then
      FOwner.Invalidate;
  end;
end;

procedure TTileText.FontChanged(Sender: TObject);
begin
  if FOwner <> Nil then
    FOwner.Invalidate;
end;

{ TCustomTileControl }

constructor TCustomTileControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle:=ControlStyle + [csOpaque, csDisplayDragImage, csReplicatable] - [{csOpaque,} csSetCaption, csParentBackground];
  Caption:='';
  Color:=clWebTurquoise;
  DragCursor:=crDefault;

  FAlignment:=taCenter;
  FVerticalAlignment:=taVerticalCenter;
  FSize:=tsRegular;
  FSizeCustomCols:=2;
  FSizeCustomRows:=2;
  FSizeFixed:=True;
  FWordWrap:=False;
  FHovered:=False;

  FGlyph:=TTileGlyph.Create(Self);
  FText1:=TTileText.Create(Self);
  FText2:=TTileText.Create(Self);
  FText3:=TTileText.Create(Self);
  FText4:=TTileText.Create(Self);
end;

destructor TCustomTileControl.Destroy;
begin
  FreeAndNil(FText4);
  FreeAndNil(FText3);
  FreeAndNil(FText2);
  FreeAndNil(FText1);
  FreeAndNil(FGlyph);
  inherited Destroy;
end;

procedure TCustomTileControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and not (ssDouble in Shift) then begin
    FLastLMouseClick:=Point(X, Y);
    FLMouseClicked:=True;
//    Self.BeginDrag(True);
  end;

  inherited;
end;

procedure TCustomTileControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FLMouseClicked and (ssLeft in Shift) and not PointsEqual(Point(X, Y), FLastLMouseClick) and not Self.Dragging then begin
    Self.BeginDrag(True);
  end;
  inherited;
end;

procedure TCustomTileControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and not (ssDouble in Shift) then begin
    FLastLMouseClick:=EmptyPoint;
    FLMouseClicked:=False;
  end;
  inherited;
end;

procedure TCustomTileControl.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Tile: TCustomTileControl;
  idx: Integer;
  drop_pt: TPoint;
begin
  Accept:=(Source is TTileDragObject);
  if Accept and (State = dsDragMove) then begin
    drop_pt:=TTileBoxAccess(Parent).CalculateControlPos(Point(X, Y));
    if TTileDragObject(Source).Control is TCustomTileControl then begin
      Tile:=TCustomTileControl(TTileDragObject(Source).Control);
      if Tile <> Nil then begin
        idx:=TTileBoxAccess(Parent).ControlsCollection.IndexOfTileControl(Tile);
        if idx > -1 then begin
          TTileBoxAccess(Parent).ControlsCollection.Items[idx].SetPosition(drop_pt.X, drop_pt.Y);
          TTileBoxAccess(Parent).UpdateControls(True);
        end;
      end;
    end;
  end;
end;

procedure TCustomTileControl.DoStartDrag(var DragObject: TDragObject);
var
  Pt: TPoint;
begin
  //Get cursor pos
  GetCursorPos(Pt);
  //Make cursor pos relative to button
  Pt:=Self.ScreenToClient(Pt);
  //Pass info to drag object
  DragObject:=TTileDragObject.CreateWithHotSpot(Self, Pt.X, Pt.Y);
  //Modify the var parameter
  TTileBoxAccess(Parent).FDragObject:=TTileDragObject(DragObject);
  SetManualUserPosition;
end;

procedure TCustomTileControl.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  TTileBoxAccess(Parent).SharedEndDrag(Target, X, Y);
end;

{
procedure TCustomTileControl.DisplayShadow;
begin
//  if CheckWin32Version(5, 1) then
//    Exit;
  if not Assigned(FRShadow) then begin
    FRShadow := TShadowWindow.CreateShadow(Self, csRight);
    FBShadow := TShadowWindow.CreateShadow(Self, csBottom);
  end;
  if Assigned(FRShadow) then begin
    FRShadow.Control := Self;
    FBShadow.Control := Self;
  end;
end;

procedure TCustomTileControl.HideShadow;
begin
//  if CheckWin32Version(5, 1) or not Assigned(FRShadow) then
//    Exit;
  if Assigned(FRShadow) then begin
    FRShadow.Hide;
    FBShadow.Hide;
  end;
end;

procedure TCustomTileControl.CMVisibleChanged(var Message: TMessage);
begin
  if Visible then
    DisplayShadow
  else
    HideShadow;
  inherited;
end;
}

procedure TCustomTileControl.Paint;
var
  LBuffer: TBitmap;
  LCanvas: TCanvas;
//  LBrushStyle: TBrushStyle;
begin
  LBuffer:=Nil; // satisfy compiler
  LCanvas:=Self.Canvas;
  if Parent.DoubleBuffered then begin
    LBuffer:=TBitmap.Create;
    LBuffer.PixelFormat:=pf32bit; // 4 bytes of color information
    LBuffer.SetSize(Width, Height);
    //
    LCanvas:=LBuffer.Canvas;
    LCanvas.Brush.Assign(Self.Canvas.Brush);
    LCanvas.Pen.Assign(Self.Canvas.Pen);
    LCanvas.Font.Assign(Self.Canvas.Font);
    LCanvas.CopyMode:=Self.Canvas.CopyMode;
  end;
  try
    LCanvas.Brush.Style:=bsClear;
    if not Transparent then begin
//      LBrushStyle:=LCanvas.Brush.Style;
      try
        LCanvas.Brush.Style:=bsSolid;
        if Enabled then
          LCanvas.Brush.Color:=Self.Color
        else
          LCanvas.Brush.Color:=clGray;
        LCanvas.FillRect(Rect(0, 0, Width, Height));
      finally
//        LCanvas.Brush.Style:=LBrushStyle;
        LCanvas.Brush.Style:=bsClear;
      end;
    end;
    if Assigned(FOnPaint) {and not (csDesigning in ComponentState)} then
      OnPaint(Self, LCanvas, Self.ClientRect)
  finally
    if Parent.DoubleBuffered then begin
      Self.Canvas.Draw(Self.ClientRect.Left, Self.ClientRect.Top, LBuffer);
      LBuffer.Free;
    end;
  end;
//  else
//    inherited;
end;

procedure TCustomTileControl.PaintTo(DC: HDC; X, Y: Integer);
var
  SaveIndex: Integer;
begin
  SaveIndex := SaveDC(DC);
  try
    MoveWindowOrg(DC, X, Y);
    IntersectClipRect(DC, 0, 0, Width, Height);

    Perform(WM_ERASEBKGND, DC, 0);
    Perform(WM_PAINT, DC, 0);
  finally
    RestoreDC(DC, SaveIndex);
  end;
end;

procedure TCustomTileControl.PaintTo(Canvas: TCanvas; X, Y: Integer);
begin
  Canvas.Lock;
  try
    PaintTo(Canvas.Handle, X, Y);
  finally
    Canvas.Unlock;
  end;
end;

{
procedure TCustomTileControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  HideShadow;
  inherited;
  DisplayShadow;
end;
}

procedure TCustomTileControl.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TCustomTileControl.SetVerticalAlignment(const Value: TVerticalAlignment);
begin
  FVerticalAlignment := Value;
  Invalidate;
end;

procedure TCustomTileControl.SetGlyph(const Value: TTileGlyph);
begin
  FGlyph.Assign(Value);
end;

procedure TCustomTileControl.SetSize(const Value: TTileSize);
begin
  if FSize <> Value then begin
    FSize:=Value;
    if Parent <> Nil then begin
      Invalidate;
      TTileBoxAccess(Parent).DoUpdate:=True;
      Parent.Realign;
    end;
  end;
end;

procedure TCustomTileControl.SetSizeCustomCols(const Value: TTileSizeType);
begin
  if (FSize = tsCustom) and (FSizeCustomCols <> Value) then begin
    FSizeCustomCols:=Value;
    if Parent <> Nil then
      Invalidate;
  end
  else
    FSizeCustomCols:=1;
  if Parent <> Nil then begin
    TTileBoxAccess(Parent).DoUpdate:=True;
    Parent.Realign;
  end;
end;

procedure TCustomTileControl.SetSizeCustomRows(const Value: TTileSizeType);
begin
  if (FSize = tsCustom) and (FSizeCustomRows <> Value) then begin
    FSizeCustomRows:=Value;
    if Parent <> Nil then
      Invalidate;
  end
  else
    FSizeCustomRows:=1;
  if Parent <> Nil then begin
    TTileBoxAccess(Parent).DoUpdate:=True;
    Parent.Realign;
  end;
end;

procedure TCustomTileControl.SetSizeFixed(const Value: Boolean);
begin
  if (FSize = tsCustom) and (FSizeFixed <> Value) then begin
    FSizeFixed:=Value;
    if Parent <> Nil then
      Invalidate;
  end
  else
    FSizeFixed:=True;
  if Parent <> Nil then begin
    TTileBoxAccess(Parent).DoUpdate:=True;
    Parent.Realign;
  end;
end;

procedure TCustomTileControl.SetText1(const Value: TTileText);
begin
  FText1.Assign(Value);
end;

procedure TCustomTileControl.SetText2(const Value: TTileText);
begin
  FText2.Assign(Value);
end;

procedure TCustomTileControl.SetText3(const Value: TTileText);
begin
  FText3.Assign(Value);
end;

procedure TCustomTileControl.SetText4(const Value: TTileText);
begin
  FText4.Assign(Value);
end;

procedure TCustomTileControl.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then begin
    FWordWrap:=Value;
    Invalidate;
  end;
end;

procedure TCustomTileControl.SetHovered(const Value: Boolean);
begin
  if FHovered <> Value then begin
    FHovered:=Value;
    Invalidate;
  end;
end;

procedure TCustomTileControl.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then begin
    FTransparent:=Value;
    Invalidate;
  end;
end;

procedure TCustomTileControl.SetManualUserPosition;
var
  idx: Integer;
begin
  idx:=TTileBox(Parent).ControlsCollection.IndexOfTileControl(Self);
  if idx > -1 then
    TTileBox(Parent).ControlsCollection.Items[idx].FUserPosition:=True;
end;

procedure TCustomTileControl.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
begin
  if Transparent then
    Msg.Result:=1
  else
    inherited;
end;

procedure TCustomTileControl.CMControlListChanging(var Msg: TCMControlListChanging);
begin
  if Msg.Inserting and
     (TControl(Msg.ControlListItem^.Parent) = TControl(Self)) and
     (Msg.ControlListItem^.Control <> Nil) and (Msg.ControlListItem^.Control is TCustomTileControl) then begin
    Msg.ControlListItem^.Parent:=Self.Parent;
    Msg.ControlListItem^.Control.Parent:=Self.Parent;
    Exit;
  end;
  inherited;
end;

end.
