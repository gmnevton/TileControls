{ TilesBoxControl v1.0
  Delphi 2010+ Windows 10 like TilesBoxControl VCL Component

  https://github.com/gmnevton/TilesBoxControl

  (c) Copyrights 2016-2018 Grzegorz Molenda aka NevTon <gmnevton@gmail.com>

  This software source is free and can be used for any needs.
  The introduction of any changes and the use of those changed sources is permitted without limitations.
  Only requirement: This README text must be present without changes in all modifications of sources.

  > The contents of this file are used with permission,
  > subject to the Mozilla Public License Version 1.1 (the "License").
  > You may not use this file except in compliance with the License.
  > You may obtain a copy of the License at http: www.mozilla.org/MPL/MPL-1.1.html

  > Software distributed under the License is distributed on an "AS IS" basis,
  > WITHOUT WARRANTY OF ANY KIND, either express or implied.
  > See the License for the specific language governing rights and limitations under the License.
}
unit TilesBoxControl;

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
  ShadowWnd;

type
  TTileControl = class;
  TCustomTileControl = class;

  TTileControlDrawState = (cdsNormal, cdsSelected, cdsFocused, cdsSelFocused); //, cdsHovered, cdsSelectedHovered, cdsFocusedHovered, cdsSelFocusedHovered);

  TTilePaintEvent = procedure (const Sender: TCustomTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect) of object;

  TTileControlPaintEvent = procedure (const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState) of object;
  TTilesBoxPaintBkgndEvent = procedure (const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState; var TargetStdPaint: Boolean) of object;
  TTilesBoxMeasureEvent = procedure (const Sender: TObject; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState; var TargetSize: TPoint) of object;
  TTilesBoxClickEvent = procedure (const Sender: TObject; const TargetControl: TTileControl; const Index: Integer) of object;
  TTilesBoxDblClickEvent = procedure (const Sender: TObject; const TargetControl: TTileControl; const Index: Integer) of object;

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

  TCustomTileControl = class(TCustomPanel)
  private
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
    FOnPaint: TTilePaintEvent;
    FLastLMouseClick: TPoint;
    FLMouseClicked: Boolean;
    FLastItemIndexBeforeDrag: Integer;
//    FRShadow,
//    FBShadow: TShadowWindow;

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
    procedure SetManualUserPosition;
    procedure CMControlListChanging(var Message: TCMControlListChanging); message CM_CONTROLLISTCHANGING;
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
    procedure SetParentBackground(Value: Boolean); override;
    procedure Paint; override;
    property OnPaint: TTilePaintEvent read FOnPaint write FOnPaint;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
//    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function SizeInPoints: TPoint;
    property Canvas;
  published
    property Alignment;
    property Caption;
    property Color;
    property DoubleBuffered;
    property Enabled;
    property FullRepaint;
    property Font;
    property Glyph: TTileGlyph read FGlyph write SetGlyph;
    property Padding;
    property ParentBackground;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Size: TTileSize read FSize write SetSize default tsRegular;
    property SizeCustomCols: TTileSizeType read FSizeCustomCols write SetSizeCustomCols default 2;
    property SizeCustomRows: TTileSizeType read FSizeCustomRows write SetSizeCustomRows default 2;
    property SizeFixed: Boolean read FSizeFixed write SetSizeFixed default True;
    property Text1: TTileText read FText1 write SetText1;
    property Text2: TTileText read FText2 write SetText2;
    property Text3: TTileText read FText3 write SetText3;
    property Text4: TTileText read FText4 write SetText4;
    property VerticalAlignment;
    property Visible;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property Hovered: Boolean read FHovered write SetHovered default False;
  end;

  TTileControl = class(TCustomTileControl);

  TTilesBoxControl = class;
  TTileControlsCollection = class;
  TTileItemPosition = class;

  TTileControlItem = class(TCollectionItem)
  private
    FTileControl: TCustomTileControl;
    FTilePosition: TTileItemPosition;
    FCol: Integer;
    FRow: Integer;
    FUserPosition: Boolean;

    procedure SetPosition(const ACol, ARow: Integer);
    function GetPosition: TPoint;
    procedure SetTileControl(const Value: TCustomTileControl);
    procedure SetCol(const Value: Integer);
    procedure SetRow(const Value: Integer);
  protected
    procedure SetIndex(Value: Integer); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    function Owner: TTilesBoxControl;
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

    procedure GetDefaultPosition(const ATileControl: TCustomTileControl; var ACol, ARow: Integer);
  public
    constructor Create(AOwner: TPersistent);

    function Owner: TTilesBoxControl;
    function Add: TTileControlItem;

    procedure AddTileControl(const ATileControl: TCustomTileControl; AIndex: Integer = -1);
    procedure RemoveTileControl(const ATileControl: TCustomTileControl);
    function IndexOfTileControl(const ATileControl: TCustomTileControl): Integer;
    function IndexOfTileControlAt(const APoint: TPoint; var TileRect: TRect): Integer;
    procedure RebuildAlignment(StartFrom: Integer = -1);
    procedure AlignTileControls(const ATileControl: TCustomTileControl);

    property Items[Index: Integer]: TTileControlItem read GetItem write SetItem; default;
  end;

  TTileDragObject = class(TDragControlObject)
  private
    FDragImages: TDragImageList;
    FX, FY: Integer;
  protected
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override;
    function GetDragImages: TDragImageList; override;
  public
    constructor CreateWithHotSpot(Control: TWinControl; X, Y: Integer);
    destructor Destroy; override;
  end;

  TTilesBoxControl = class(TScrollingWinControl) // TScrollBox
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
    FControlsMultiPopupMenu: TPopupMenu;
    FSelectedColor: TColor;
    FHoverColor: TColor;
    FSelectedControls: TObjectList;
    FMultiselect: Boolean;
    FOrientation: TScrollBarKind;
    FControlIndex: Integer;
    FRowCount: Integer;
    FColCount: Integer;
    FSpacer: Word;
    FMouseInControl: Boolean;
    FIndentHorz: Word;
    FIndentVert: Word;
    FGroupIndent: Word;
    //FGroupWidth: Byte;
    //
    WheelAccumulator: Integer;
    ActiveControl: TTileControl;
    Updating: Boolean;
    ControlPainting: Boolean;
    // events
    FOnControlClick: TTilesBoxClickEvent;
    FOnControlDblClick: TTilesBoxDblClickEvent;
    FControlPaint: TTileControlPaintEvent;
    FControlPaintBkgnd: TTilesBoxPaintBkgndEvent;
    FControlMeasure: TTilesBoxMeasureEvent;
    FOnChange: TNotifyEvent;
    FOnPopup: TNotifyEvent;
    FOnPopupMulti: TNotifyEvent;
    FOnResize: TNotifyEvent;

    procedure SetControlsCollection(const Value: TTileControlsCollection);
    procedure SetSelectedColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetMultiselect(const Value: Boolean);
    procedure SetSelected(const Control: TTileControl; const CanDeselect: Boolean = True);
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
    procedure ControlClick(Sender: TObject);
    procedure ControlDblClick(Sender: TObject);
    //
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    //
    procedure ControlPaint(const Sender: TCustomTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect);
    //
    procedure ControlMouseEnter(Sender: TObject);
    procedure ControlMouseLeave(Sender: TObject);
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
    LastControlClicked: TTileControl;
    FDragObject: TTileDragObject;
    LastMovedIndex: Integer;

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
    procedure NormalizePointToRect(const Rect: TRect; var Point: TPoint);
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure ControlsAligned; override;
    procedure DoClick(const Control: TTileControl); virtual;
    procedure DoDblClick(const Control: TTileControl); virtual;
    procedure Loaded; override;
    procedure Resize; override;
    procedure CalcRowsCols; virtual;
    procedure MakeVisible(const Bounds: TRect); virtual;
    procedure MoveControls(const FromIndex: Integer); virtual;
    procedure UpdateControl(const Index: Integer); virtual;
    procedure UpdateControls(const Rebuild: Boolean); virtual;
    //
    function  CalculateControlPos(const FromPoint: TPoint): TPoint; virtual;
    //procedure CalculateControlSize(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint);
    procedure CalculateControlBounds(const Index: Integer; out ControlSize: TPoint); overload; virtual;
    procedure CalculateControlBounds(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint); overload; virtual;
    procedure DrawControl(const TargetControl: TTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState); virtual;
//    function CompareStrings(const S1, S2: String): Integer; virtual;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearSelection(const Update: Boolean = False);
    procedure SelectAll;
    function IndexOfTileControl(const Control: TCustomTileControl): Integer;
    function IndexOfPopup(const Sender: TObject): Integer;
    procedure UpdateTiles;

    function AddTile(const Size: TTileSize = tsRegular): TTileControl;
    procedure Clear;
    function RemoveTile(var Tile: TTileControl): Boolean;

    property RowCount: Integer read FRowCount;
    property ColCount: Integer read FColCount;
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
    property MultiselectPopupMenu: TPopupMenu read FControlsMultiPopupMenu write FControlsMultiPopupMenu;
    property Spacer: Word read FSpacer write SetSpacer default 4;
    property IndentHorz: Word read FIndentHorz write SetIndentHorz default 32;
    property IndentVert: Word read FIndentVert write SetIndentVert default 24;
    property GroupIndent: Word read FGroupIndent write SetGroupIndent default 32;

    // events
    property OnChangeSelection: TNotifyEvent read FOnChange write FOnChange;
    property OnControlClick: TTilesBoxClickEvent read FOnControlClick write FOnControlClick;
    property OnControlDblClick: TTilesBoxDblClickEvent read FOnControlDblClick write FOnControlDblClick;
    property OnControlPaint: TTileControlPaintEvent read FControlPaint write FControlPaint;
    property OnControlPaintBkgnd: TTilesBoxPaintBkgndEvent read FControlPaintBkgnd write FControlPaintBkgnd;
    property OnControlMeasure: TTilesBoxMeasureEvent read FControlMeasure write FControlMeasure;
    property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;
    property OnPopupMulti: TNotifyEvent read FOnPopupMulti write FOnPopupMulti;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
  end;

procedure Register;

implementation

uses
  RTLConsts,
  Dialogs,
  Character,
  Math,
  ImgList;

resourcestring
  sBadControlClassType = 'Can not add class ''%s'' to TTilesBoxControl !';

const
  EmptyRect: TRect = (Left: -1; Top: -1; Right: -1; Bottom: -1);
  EmptyPoint: TPoint = (X: -1; Y: -1);

procedure Register;
begin
  Classes.RegisterClass(TTileControlItem);
  Classes.RegisterClass(TTileControlsCollection);
  Classes.RegisterComponents('WinX Controls', [TTilesBoxControl, TTileControl]);
//  RegisterPropertyEditor(TypeInfo(TUsersListBoxItems), TUsersListBox, 'DesignItems', TUsersListBoxProperty);
end;

function GetTickDiff(const AOldTickCount, ANewTickCount: LongWord): LongWord; inline;
begin
  {This is just in case the TickCount rolled back to zero}
  if ANewTickCount >= AOldTickCount then
    Result := ANewTickCount - AOldTickCount
  else
    Result := High(LongWord) - AOldTickCount + ANewTickCount;
end;

procedure DrawTransparentBitmap(DC: HDC; hBmp: HBITMAP; xStart: Integer; yStart: Integer; cTransparentColor: COLORREF);
var
  bm: BITMAP;
  cColor: COLORREF;
  bmAndBack, bmAndObject, bmAndMem, bmSave: HBITMAP;
  bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBITMAP;
  hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave: HDC;
  ptSize: TPOINT;
begin
  hdcTemp := CreateCompatibleDC(DC);
  SelectObject(hdcTemp, hBmp); // Select the bitmap

  GetObject(hBmp, SizeOf(BITMAP), @bm);
  ptSize.x := bm.bmWidth; // Get width of bitmap
  ptSize.y := bm.bmHeight; // Get height of bitmap
  DPtoLP(hdcTemp, ptSize, 1); // Convert from device
  // to logical points

  // Create some DCs to hold temporary data.
  hdcBack := CreateCompatibleDC(DC);
  hdcObject := CreateCompatibleDC(DC);
  hdcMem := CreateCompatibleDC(DC);
  hdcSave := CreateCompatibleDC(DC);

  // Create a bitmap for each DC. DCs are required for a number of
  // GDI functions.

  // Monochrome DC
  bmAndBack := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);

  // Monochrome DC
  bmAndObject := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);

  bmAndMem := CreateCompatibleBitmap(DC, ptSize.x, ptSize.y);
  bmSave := CreateCompatibleBitmap(DC, ptSize.x, ptSize.y);

  // Each DC must select a bitmap object to store pixel data.
  bmBackOld := SelectObject(hdcBack, bmAndBack);
  bmObjectOld := SelectObject(hdcObject, bmAndObject);
  bmMemOld := SelectObject(hdcMem, bmAndMem);
  bmSaveOld := SelectObject(hdcSave, bmSave);

  // Set proper mapping mode.
  SetMapMode(hdcTemp, GetMapMode(DC));

  // Save the bitmap sent here, because it will be overwritten.
  BitBlt(hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);

  // Set the background color of the source DC to the color.
  // contained in the parts of the bitmap that should be transparent
  cColor := SetBkColor(hdcTemp, cTransparentColor);

  // Create the object mask for the bitmap by performing a BitBlt
  // from the source bitmap to a monochrome bitmap.
  BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);

  // Set the background color of the source DC back to the original
  // color.
  SetBkColor(hdcTemp, cColor);

  // Create the inverse of the object mask.
  BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, NOTSRCCOPY);

  // Copy the background of the main DC to the destination.
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, DC, xStart, yStart, SRCCOPY);

  // Mask out the places where the bitmap will be placed.
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);

  // Mask out the transparent colored pixels on the bitmap.
  BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);

  // XOR the bitmap with the background on the destination DC.
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT);

  // Copy the destination to the screen.
  BitBlt(DC, xStart, yStart, ptSize.x, ptSize.y, hdcMem, 0, 0, SRCCOPY);

  // Place the original bitmap back into the bitmap sent here.
  BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);

  // Delete the memory bitmaps.
  DeleteObject(SelectObject(hdcBack, bmBackOld));
  DeleteObject(SelectObject(hdcObject, bmObjectOld));
  DeleteObject(SelectObject(hdcMem, bmMemOld));
  DeleteObject(SelectObject(hdcSave, bmSaveOld));

  // Delete the memory DCs.
  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcSave);
  DeleteDC(hdcTemp);
end;

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

  ControlStyle:=ControlStyle + [csOpaque, csDisplayDragImage] - [csSetCaption] - [csParentBackground];
  Caption:='';
  ShowCaption:=False;
  Alignment:=taCenter;
  VerticalAlignment:=taVerticalCenter;
  BevelInner:=bvNone;
  BevelOuter:=bvNone;
  BevelWidth:=1;
  BevelEdges:=[];
  BevelKind:=bkNone;
  BorderStyle:=bsNone;
  Color:=clWebTurquoise;
  FullRepaint:=True;
  UseDockManager:=True;
  DoubleBuffered:=True;
  DragCursor:=crDefault;
  ParentBackground:=False;
  TabStop:=True;
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

  // TShadowWindow
//  FRShadow:=Nil;
//  FBShadow:=Nil;
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
  end;

  inherited;
end;

procedure TCustomTileControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FLMouseClicked and (ssLeft in Shift) and not PointsEqual(Point(X, Y), FLastLMouseClick) and not Self.Dragging then begin
    Self.BeginDrag(True);
    Self.Visible:=False;
  end;
  inherited;
end;

procedure TCustomTileControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and not (ssDouble in Shift) then begin
    FLastLMouseClick:=EmptyPoint;
    FLMouseClicked:=False;
//    TTilesBoxControl(Parent).UpdateControls(True);
  end;
  inherited;
end;

procedure TCustomTileControl.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Tile: TCustomTileControl;
  idx, insert_idx: Integer;
  drop_pt: TPoint;
//  drop_obj: TControl;
begin
  Accept:=(Source is TTileDragObject);
  if Accept and (State = dsDragMove) then begin
    insert_idx:=TTilesBoxControl(Parent).ControlsCollection.IndexOfTileControl(Self);
    if insert_idx > -1 then begin
      //item:=TTilesBoxControl(Parent).ControlsCollection.Insert(insert_idx);
      TTilesBoxControl(Parent).MoveControls(insert_idx);
    end;

//    drop_obj:=FindDragTarget(TTileDragObject(Source).);


//    drop_pt:=TTilesBoxControl(Parent).CalculateControlPos(Point(X, Y));
//    if TTileDragObject(Source).Control is TCustomTileControl then begin
//      Tile:=TCustomTileControl(TTileDragObject(Source).Control);
//      if Tile <> Nil then begin
//        idx:=TTilesBoxControl(Parent).ControlsCollection.IndexOfTileControl(Tile);
//        if idx > -1 then begin
//          TTilesBoxControl(Parent).ControlsCollection.Items[idx].SetPosition(drop_pt.X, drop_pt.Y);
//          TTilesBoxControl(Parent).UpdateControls(True);
//        end;
//      end;
//    end;
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
  TTilesBoxControl(Parent).FDragObject:=TTileDragObject(DragObject);
//  SetManualUserPosition;
end;

procedure TCustomTileControl.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  TTilesBoxControl(Parent).SharedEndDrag(Target, X, Y);
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
  LBrushStyle: TBrushStyle;
begin
  if Assigned(FOnPaint) {and not (csDesigning in ComponentState)} then begin
    LBuffer:=Nil; // satisfy compiler
    if DoubleBuffered then begin
      LBuffer:=TBitmap.Create;
      LBuffer.SetSize(Width, Height);
      LCanvas:=LBuffer.Canvas;
      LCanvas.Brush.Assign(Self.Canvas.Brush);
      LCanvas.Pen.Assign(Self.Canvas.Pen);
      LCanvas.Font.Assign(Self.Canvas.Font);
      LCanvas.CopyMode:=Self.Canvas.CopyMode;
      LCanvas.Brush.Color:=Self.Color;
      LBrushStyle:=LCanvas.Brush.Style;
      try
        LCanvas.Brush.Style:=bsSolid;
        LCanvas.FillRect(Rect(0, 0, Width, Height));
      finally
        LCanvas.Brush.Style:=LBrushStyle;
      end;
    end
    else
      LCanvas:=Self.Canvas;
    try
      OnPaint(Self, LCanvas, Self.ClientRect)
    finally
      if DoubleBuffered then begin
        Self.Canvas.Draw(Self.ClientRect.Left, Self.ClientRect.Top, LBuffer);
        LBuffer.Free;
      end;
    end;
  end
  else
    inherited;
end;

{
procedure TCustomTileControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  HideShadow;
  inherited;
  DisplayShadow;
end;
}

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
      TTilesBoxControl(Parent).DoUpdate:=True;
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
    TTilesBoxControl(Parent).DoUpdate:=True;
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
    TTilesBoxControl(Parent).DoUpdate:=True;
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
    TTilesBoxControl(Parent).DoUpdate:=True;
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

procedure TCustomTileControl.SetManualUserPosition;
var
  idx: Integer;
begin
  idx:=TTilesBoxControl(Parent).ControlsCollection.IndexOfTileControl(Self);
  if idx > -1 then
    TTilesBoxControl(Parent).ControlsCollection.Items[idx].FUserPosition:=True;
end;

procedure TCustomTileControl.SetParentBackground(Value: Boolean);
begin
// nothing to do here
end;

function TCustomTileControl.SizeInPoints: TPoint;
var
  MaxSizeX, MaxSizeY: Integer;
begin
  Result:=Point(1, 1); // minimum size
  case Size of
    tsSmall: Exit;
    tsRegular   : Result:=Point(2, 2);
    tsLarge     : Result:=Point(4, 2);
    tsExtraLarge: Result:=Point(4, 4);
    tsCustom: begin
      if SizeFixed then
        Result:=Point(SizeCustomCols, SizeCustomRows)
      else begin
        MaxSizeX:=SizeCustomCols;
        MaxSizeY:=SizeCustomRows;
        with TTilesBoxControl(Parent) do begin
          if Orientation = sbVertical then begin
            MaxSizeX:=ColCount;
            if MaxSizeX = 0 then
              MaxSizeX:=1;
            if MaxSizeX > SizeCustomCols then
              MaxSizeX:=SizeCustomCols;
          end
          else begin
            MaxSizeY:=RowCount;
            if MaxSizeY = 0 then
              MaxSizeY:=1;
            if MaxSizeY > SizeCustomRows then
              MaxSizeY:=SizeCustomRows;
          end;
          Result:=Point(MaxSizeX, MaxSizeY);
        end;
      end;
    end;
  end;
end;

procedure TCustomTileControl.CMControlListChanging(var Message: TCMControlListChanging);
begin
  if Message.Inserting and
     (Message.ControlListItem^.Parent = Self) and
     (Message.ControlListItem^.Control <> Nil) and (Message.ControlListItem^.Control is TCustomTileControl) then begin
    Message.ControlListItem^.Parent:=Self.Parent;
    Message.ControlListItem^.Control.Parent:=Self.Parent;
    Exit;
  end;
  inherited;
end;

function PointsAdd(const A, B: TPoint): TPoint;
begin
  Result:=Point(A.X + B.X, A.Y + B.Y);
end;

function PointsDec(const A, B: TPoint): TPoint;
begin
  Result:=Point(A.X - B.X, A.Y - B.Y);
end;

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

function TTileControlItem.Owner: TTilesBoxControl;
begin
  Result:=TTilesBoxControl(OwnerCollection.Owner);
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

    Tile:=TTileControl.Create(Owner.Parent);
    try
      Tile.Name:='TileControl' + IntToStr(max_num + 1);
      Tile.Visible:=False;
      TTileControlItem(Item).FTileControl:=Tile;
      TTileControlItem(Item).FCol:=-1;
      TTileControlItem(Item).FRow:=-1;
      GetDefaultPosition(Tile, X, Y);
      TTileControlItem(Item).FCol:=X;
      TTileControlItem(Item).FRow:=Y;
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
begin
  inherited Update(Item);
//  exit;
  if Owner <> Nil then
    Owner.Realign;
end;

function TTileControlsCollection.Owner: TTilesBoxControl;
begin
  Result:=TTilesBoxControl(GetOwner);
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
  if IndexOfTileControl(ATileControl) = -1 then begin
    X:=0;
    Y:=0;
    if AIndex < 0 then begin
      Item:=Add;
      Item.FCol:=-1;
      Item.FRow:=-1;
    end
    else
      Item:=Items[AIndex];

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

function TTileControlsCollection.IndexOfTileControl(const ATileControl: TCustomTileControl): Integer;
begin
  if ATileControl <> Nil then begin
    for Result:=0 to Count - 1 do
      if Items[Result].TileControl = ATileControl then
        Exit;
  end;
  Result:=-1;
end;

function TTileControlsCollection.IndexOfTileControlAt(const APoint: TPoint; var TileRect: TRect): Integer;
var
  tpos, tsize: TPoint;
begin
  for Result:=0 to Count - 1 do
    if (Items[Result].TileControl <> Nil) then begin
      tpos:=Items[Result].GetPosition;
      tsize:=Items[Result].FTileControl.SizeInPoints;
      TileRect:=Rect(tpos.X, tpos.Y, tpos.X + tsize.X, tpos.Y + tsize.Y);
      if PtInRect(TileRect, APoint) then
        Exit;
    end;
  TileRect:=EmptyRect;
  Result:=-1;
end;

procedure TTileControlsCollection.RebuildAlignment(StartFrom: Integer = -1);
var
  i: Integer;
  Item: TTileControlItem;
  Tile: TCustomTileControl;
  ACol, ARow: Integer;
begin
  if StartFrom < 0 then
    StartFrom:=0;

  for i:=StartFrom to Count - 1 do begin
    Item:=Items[i];
    if not Item.TilePosition.AutoPositioning then
      Continue;
    Tile:=Item.TileControl;
    if (Tile = Nil) or ((Tile <> Nil) and not Tile.Visible) then
      Continue;
    Item.SetPosition(-1, -1);
  end;

  for i:=StartFrom to Count - 1 do begin
    Item:=Items[i];
    if not Item.TilePosition.AutoPositioning then
      Continue;
    Tile:=Item.TileControl;
    if (Tile = Nil) or ((Tile <> Nil) and not Tile.Visible) then
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
  idx:=IndexOfTileControl(ATileControl);
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

procedure TTileControlsCollection.GetDefaultPosition(const ATileControl: TCustomTileControl; var ACol, ARow: Integer);

  procedure findEmptySlot(Orientation: TScrollBarKind; const ParentRect: TRect; var TargetPosition: TPoint; const TargetSize: TPoint; const canChangeOrientation: Boolean = False);
  var
    x, y, a, b, k, first_empty: Integer;
    found: Boolean;

    procedure adjustPosition;
    begin
      if Orientation = sbHorizontal then
        Inc(x, 1)
      else
        Inc(y, 1);
      // zostawiam to na wszelki wypadek
{
      case ATileControl.Size of
        tsSmall: begin
          if Orientation = sbHorizontal then
            Inc(x, 1)
          else
            Inc(y, 1);
        end;
        tsRegular: begin
          if Orientation = sbHorizontal then
            Inc(x, 2)
          else
            Inc(y, 2);
        end;
        tsLarge: begin
          if Orientation = sbHorizontal then
            Inc(x, 2)
          else
            Inc(y, 2);
        end;
        tsExtraLarge: begin
          if Orientation = sbHorizontal then
            Inc(x, 4)
          else
            Inc(y, 4);
        end;
        //tsCustom    : y:=Position.Y + 1;
      end;
}
    end;

    function iterateItems(const posx, posy: Integer): Boolean;
    var
      i: Integer;
      LPos, LSize: TPoint;
      LResult: Boolean;
      LRect: TRect;
    begin
      Result:=False;
      for i:=0 to Count - 1 do begin
        LPos:=Items[i].Position;
        if PointsEqual(LPos, EmptyPoint) then
          Continue;
        //Owner.CalculateControlSize(Items[i].TileControl, ParentRect, LSize);
        LSize:=Items[i].TileControl.SizeInPoints;
//        if PtInRect(Rect(LPos.X, LPos.Y, LPos.X + LSize.X, LPos.Y + LSize.Y), Point(posx, posy)) then begin
        LResult:=IntersectRect(LRect, Rect(LPos.X, LPos.Y, LPos.X + LSize.X, LPos.Y + LSize.Y), Rect(posx, posy, posx + TargetSize.X, posy + TargetSize.Y));
        if LResult then begin
//        if ((posx >= Items[i].Position.X) and (posx <= Items[i].Position.X + Size.X)) and
//           ((posy >= Items[i].Position.Y) and (posy <= Items[i].Position.Y + Size.Y)) then begin
          Result:=True;
          Break;
        end;
      end;
    end;

  var
    last_enter: DWORD;
    expired: Boolean;
  begin
    x:=TargetPosition.X;
    y:=TargetPosition.Y;
//    if Orientation = sbHorizontal then begin
//      x:=TargetPosition.X;
//      y:=TargetPosition.Y;
//    end
//    else begin
//      x:=TargetPosition.X;
//      y:=TargetPosition.Y;
//    end;

    last_enter:=GetTickCount;
    repeat
      try
        adjustPosition;
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
        if a > b then begin
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
      finally
        expired:=(GetTickDiff(last_enter, GetTickCount) >= 5000);
      end;
    until (first_empty > -1) or expired;

    if expired then
      Exit;

    if Orientation = sbHorizontal then begin
      TargetPosition.X:=first_empty;
      TargetPosition.Y:=y;
    end
    else begin
      TargetPosition.X:=x;
      TargetPosition.Y:=first_empty;
    end;
  end;

  function cellsToSize(const offset, cels, spacer: Integer): Integer;
  begin
    Result:=offset + 48 * cels + spacer * cels;
  end;

var
  idx, before: Integer;
  PrecedingControl: TTileControl;
  ParentRect: TRect;
  Position, Size1, Size2, TempPosition: TPoint;
  go_once, go_twice: Boolean;
begin
  if (Owner <> Nil) and not (csLoading in Owner.ComponentState) then begin
    Position:=EmptyPoint; // Point(-1, -1);
    Size1:=Point(0, 0);
    Size2:=Point(0, 0);
    PrecedingControl:=Nil;

    ParentRect:=Owner.GetClientRect;
    Owner.AdjustClientRect(ParentRect);
    InflateRect(ParentRect, -Owner.IndentHorz, -Owner.IndentVert);

    idx:=IndexOfTileControl(ATileControl);
    if idx > -1 then begin
      before:=idx - 1;
      if before > -1 then begin
        PrecedingControl:=TTileControl(Items[before].TileControl);
//        Position:=Control.BoundsRect.TopLeft;
        Position:=Items[before].Position;
      end;
      if (PrecedingControl <> Nil) then begin
        //Owner.CalculateControlSize(PrecedingControl, ParentRect, Size1);
        //Owner.CalculateControlSize(ATileControl, ParentRect, Size2);
        Size1:=PrecedingControl.SizeInPoints;
        Size2:=ATileControl.SizeInPoints;
      end
      else begin
        Size1:=Point(0, 0);
        //Owner.CalculateControlSize(ATileControl, ParentRect, Size2);
        Size2:=ATileControl.SizeInPoints;
      end;

      if Owner.Orientation = sbVertical then begin
        if cellsToSize(Owner.IndentHorz, Position.X + Size1.X + Size2.X, Owner.Spacer) > ParentRect.Right then begin
          // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
          TempPosition:=Point(Position.X + Size1.X + Size2.X, Position.Y);
//          go_once:=True;
//          go_twice:=True;
          while True do begin
            findEmptySlot(sbHorizontal, ParentRect, TempPosition, Size2);
            if cellsToSize(Owner.IndentHorz, TempPosition.X + Size2.X, Owner.Spacer) > ParentRect.Right then begin
              // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
              if (Owner.ColCount >= Size2.X) and (TempPosition.X > 0) then begin
                TempPosition.X:=-1;
                Inc(TempPosition.Y);
              end
              else begin
                if TempPosition.X = 0 then begin
                  Break;
                end
                else begin
                  if (Owner.ColCount > 0) and (Owner.ColCount < Size2.X) then begin
                    TempPosition.X:=-1;
                    Inc(TempPosition.Y);
                  end
                  else begin
                    TempPosition.X:=0;
                    Break;
                  end;
                end;
              end;
//              findEmptySlot(sbHorizontal, ParentRect, TempPosition, Size2);
//              if not go_once then
//                go_twice:=False;
//              go_once:=False;
//              if TempPosition.X = 0 then
//                Break;
            end
            else
              Break;
          end;
          Position:=TempPosition;
        end
        else if before > -1 then begin
          // sprawdzic czy pozycja jest wolna
//          go_once:=True;
          while True do begin
            findEmptySlot(sbHorizontal, ParentRect, Position, Size2, True);
            // sprawdzic czy nie przekraczamy dopuszczalnych przestrzeni
            if cellsToSize(Owner.IndentHorz, Position.X + Size2.X, Owner.Spacer) > ParentRect.Right then begin
              // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
              if (Owner.ColCount >= Size2.X) and (Position.X > 0) then begin
                Position.X:=-1;
                Inc(Position.Y);
              end
              else begin
                if Position.X = 0 then begin
                  Break;
                end
                else begin
                  if (Owner.ColCount > 0) and (Owner.ColCount < Size2.X) then begin
                    Position.X:=-1;
                    Inc(Position.Y);
                  end
                  else begin
                    Position.X:=0;
                    Break;
                  end;
                end;
              end;
//              TempPosition:=Point(Position.X + Size2.X, Position.Y);
//              findEmptySlot(sbHorizontal, ParentRect, TempPosition, EmptyPoint);
//              Position:=TempPosition;
//              go_once:=False;
            end
            else
              Break;
          end;
        end;
      end
      else begin
        if cellsToSize(Owner.IndentVert, Position.Y + Size1.Y + Size2.Y, Owner.Spacer) > ParentRect.Bottom then begin
          // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
          TempPosition:=Point(Position.X, Position.Y + Size1.Y + Size2.Y);
          go_once:=True;
          go_twice:=True;
          while True do begin
            findEmptySlot(sbVertical, ParentRect, TempPosition, Size2);
            if (cellsToSize(Owner.IndentVert, TempPosition.Y + Size2.Y, Owner.Spacer) > ParentRect.Bottom) and go_twice then begin
              // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
              findEmptySlot(sbVertical, ParentRect, TempPosition, Size2);
              if not go_once then
                go_twice:=False;
              go_once:=False;
              if TempPosition.Y = 0 then
                Break;
            end
            else
              Break;
          end;
          Position:=TempPosition;
        end
        else if before > -1 then begin
          // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
//          findEmptySlot(sbVertical, ParentRect, Position, Size2, True);
          go_once:=True;
          while True do begin
            findEmptySlot(sbVertical, ParentRect, Position, Size2, True);
            // sprawdzic czy nie przekraczamy dopuszczalnych przestrzeni
            if (cellsToSize(Owner.IndentVert, Position.Y + Size2.Y, Owner.Spacer) > ParentRect.Bottom) and go_once then begin
              // szukaj pierwszej wolnej pozycji w kolejnym rzedzie
              TempPosition:=Point(Position.X, Position.Y + Size2.Y);
              findEmptySlot(sbVertical, ParentRect, TempPosition, EmptyPoint);
              Position:=TempPosition;
              go_once:=False;
            end
            else
              Break;
          end;
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

{ TTileDragObject }

constructor TTileDragObject.CreateWithHotSpot(Control: TWinControl; X, Y: Integer);
begin
  inherited Create(Control);
  FX:=X;
  FY:=Y;
end;

destructor TTileDragObject.Destroy;
begin
  FDragImages.Free;
  inherited;
end;

function TTileDragObject.GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor;
begin
  if Accepted then
    Result:=crDefault
  else
    Result:=inherited GetDragCursor(Accepted, X, Y);
end;

function TTileDragObject.GetDragImages: TDragImageList;
var
  Bmp: TBitmap;
  Idx: Integer;
begin
  if not Assigned(FDragImages) then
    FDragImages:=TDragImageList.Create(Nil);
  Result:=FDragImages;
  Result.Clear;
  //Make bitmap that is same size as control
  Bmp:=TBitmap.Create;
  try
    Bmp.Width:=Control.Width;
    Bmp.Height:=Control.Height;
    Bmp.Canvas.Lock;
    try
      //Draw control in bitmap
      TCustomTileControl(Control).PaintTo(Bmp.Canvas.Handle, 0, 0);
    finally
      Bmp.Canvas.UnLock;
    end;
    FDragImages.Width:=Control.Width;
    FDragImages.Height:=Control.Height;
    //Add bitmap to image list, making the grey pixels transparent
    Idx:=FDragImages.AddMasked(Bmp, TCustomTileControl(Control).Color);
    //Set the drag image and hot spot
    FDragImages.SetDragImage(Idx, FX, FY);
  finally
    Bmp.Free
  end
end;
{ TTilesBoxControl }

function TTilesBoxControl.AddTile(const Size: TTileSize = tsRegular): TTileControl;
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

procedure TTilesBoxControl.AdjustClientRect(var Rect: TRect);
begin
  Rect:=Bounds(-HorzScrollBar.Position,
               -VertScrollBar.Position,
               IfThen(Orientation = sbHorizontal, Max(HorzScrollBar.Range, ClientWidth), ClientWidth),
               IfThen(Orientation = sbVertical, Max(VertScrollBar.Range, ClientHeight), ClientHeight));
end;

procedure TTilesBoxControl.NormalizePointToRect(const Rect: TRect; var Point: TPoint);
begin
  if Point.X < Rect.Left then
    Point.X:=Rect.Left
  else if Point.X > Rect.Right then
    Point.X:=Rect.Right;
  //
  if Point.Y < Rect.Top then
    Point.Y:=Rect.Top
  else if Point.Y > Rect.Bottom then
    Point.Y:=Rect.Bottom;
end;

procedure TTilesBoxControl.AlignControls(AControl: TControl; var ARect: TRect);
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

function TTilesBoxControl.CalculateControlPos(const FromPoint: TPoint): TPoint;
var
  GridRect: TRect;
  ClientPoint: TPoint;
  dx, dy: Integer;
begin
  GridRect:=GetClientRect;
  AdjustClientRect(GridRect);
  InflateRect(GridRect, -IndentHorz, -IndentVert);
  ClientPoint:=FromPoint;
  NormalizePointToRect(GridRect, ClientPoint);
  //
  ClientPoint:=PointsAdd(ClientPoint, Point(-IndentHorz, -IndentVert));
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

{procedure TTilesBoxControl.CalculateControlSize(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint);
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
end;}

procedure TTilesBoxControl.CalculateControlBounds(const Index: Integer; out ControlSize: TPoint);
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

procedure TTilesBoxControl.CalculateControlBounds(const Control: TCustomTileControl; const TargetRect: TRect; out ControlSize: TPoint);
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

procedure TTilesBoxControl.CalcRowsCols;
var
  ClientRect: TRect;
begin
  ClientRect:=GetClientRect;
  if IsRectEmpty(ClientRect) then
    Exit;
  AdjustClientRect(ClientRect);
  InflateRect(ClientRect, -IndentHorz, -IndentVert);
  FColCount:=Abs(RectWidth(ClientRect)) div 48;
  while (FColCount > 0) and ((48 * FColCount + Spacer * FColCount) > Abs(RectWidth(ClientRect))) do
    Dec(FColCount);
  if FColCount = 0 then
    FColCount:=1;

  FRowCount:=Abs(RectHeight(ClientRect)) div 48;
  while (FRowCount > 0) and ((48 * FRowCount + Spacer * FRowCount) > Abs(RectHeight(ClientRect))) do
    Dec(FRowCount);
  if FRowCount = 0 then
    FRowCount:=1;
end;

procedure TTilesBoxControl.CalcScrollBar(const ScrollBar: TControlScrollBar);
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

var
  HorzScrollSize, VertScrollSize: Integer;
begin
  HorzScrollSize:=GetSystemMetrics(SM_CXHSCROLL) * 2;
  VertScrollSize:=GetSystemMetrics(SM_CXVSCROLL) * 2;
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

procedure TTilesBoxControl.Clear;
var
  Tile: TTileControl;
begin
  while GetControlsCount > 0 do begin
    Tile:=GetTileControl(0);
    RemoveTile(Tile);
  end;
end;

procedure TTilesBoxControl.ClearSelection(const Update: Boolean = False);
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

procedure TTilesBoxControl.SelectAll;
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

procedure TTilesBoxControl.CMControlListChanging(var Message: TCMControlListChanging);
begin
  if (Message.ControlListItem^.Parent = Self) and(Message.ControlListItem^.Control <> Nil) then begin
    if Message.Inserting and not (Message.ControlListItem^.Control is TCustomTileControl) and not (Message.ControlListItem^.Control is TShadowWindow) then
      raise Exception.CreateFmt(sBadControlClassType, [Message.ControlListItem^.Control.ClassName]);
  end;
  inherited;
end;

procedure TTilesBoxControl.CMControlListChange(var Message: TCMControlListChange);
begin
  inherited;
  if Message.Inserting and (Message.Control <> Nil) and (Message.Control is TCustomTileControl) then begin
    TCustomTileControl(Message.Control).Align:=alNone;
    TCustomTileControl(Message.Control).Anchors:=[];
    TCustomTileControl(Message.Control).OnClick:=ControlClick;
    TCustomTileControl(Message.Control).OnDblClick:=ControlDblClick;
    TCustomTileControl(Message.Control).OnPaint:=ControlPaint;
    TCustomTileControl(Message.Control).OnMouseDown:=ControlMouseDown;
    TCustomTileControl(Message.Control).OnMouseMove:=ControlMouseMove;
    TCustomTileControl(Message.Control).OnMouseUp:=ControlMouseUp;
    TCustomTileControl(Message.Control).OnMouseEnter:=ControlMouseEnter;
    TCustomTileControl(Message.Control).OnMouseLeave:=ControlMouseLeave;
    //
    if not (csLoading in Owner.ComponentState){ and not (csDesigning in Owner.ComponentState)} then
      FControlsCollection.AddTileControl(TCustomTileControl(Message.Control));
  end;
end;

procedure TTilesBoxControl.CMControlChange(var Message: TCMControlChange);
begin
  inherited;
  if not Message.Inserting and (Message.Control <> Nil) and (Message.Control is TCustomTileControl) and (Message.Control.Parent = Self) then begin
    TCustomTileControl(Message.Control).OnClick:=Nil;
    TCustomTileControl(Message.Control).OnDblClick:=Nil;
    TCustomTileControl(Message.Control).OnPaint:=Nil;
    TCustomTileControl(Message.Control).OnMouseDown:=Nil;
    TCustomTileControl(Message.Control).OnMouseMove:=Nil;
    TCustomTileControl(Message.Control).OnMouseUp:=Nil;
    TCustomTileControl(Message.Control).OnMouseEnter:=Nil;
    TCustomTileControl(Message.Control).OnMouseLeave:=Nil;
    FControlsCollection.RemoveTileControl(TCustomTileControl(Message.Control));
  end;
end;

procedure TTilesBoxControl.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
    RecreateWnd;
  inherited;
end;

procedure TTilesBoxControl.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  UpdateControls(True);
end;

procedure TTilesBoxControl.CNKeyDown(var Msg: TWMKey);
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

//function TTilesBoxControl.CompareStrings(const S1, S2: String): Integer;
//begin
//  Result:=AnsiCompareText(S1, S2);
//end;

procedure TTilesBoxControl.ControlClick(Sender: TObject);
begin
  MakeVisible(TTileControl(Sender).BoundsRect);

  if TabStop and not Focused then
    SetFocus;

//  ActiveControl:=TTileControl(Sender);
  TileControlIndex:=IndexOfTileControl(TTileControl(Sender));
  UpdateControls(True);
  DoClick(ActiveControl);
end;

procedure TTilesBoxControl.ControlDblClick(Sender: TObject);
begin
  MakeVisible(TTileControl(Sender).BoundsRect);

  if TabStop and not Focused then
    SetFocus;

//  ActiveControl:=TTileControl(Sender);
  TileControlIndex:=IndexOfTileControl(TTileControl(Sender));
  UpdateControls(True);
  DoDblClick(ActiveControl);
end;

procedure TTilesBoxControl.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  Tile:=TTileControl(Sender);

  if Tile = Nil then
    Exit;

  if Button = mbLeft then begin
    if FMultiselect then begin
      if ssCtrl in Shift then
        SetSelected(Tile)
      else begin
        if LastControlClicked = Tile then
          Exit;

        ClearSelection();
        SetSelected(Tile);
        LastControlClicked:=Tile;
      end;
    end
    else begin
      LastControlClicked:=Tile;
//      ClearSelection(True);
      Tile.Hovered:=False;
      Tile.Invalidate;
    end;
  end
  else if Button = mbRight then begin
    if not FMultiselect then begin
      MakeVisible(Tile.BoundsRect);

      if TabStop and not Focused then
        SetFocus;

      ActiveControl:=Tile;
      TileControlIndex:=IndexOfTileControl(ActiveControl);
      UpdateControls(True);

      if Assigned(Tile.PopupMenu) and Assigned(FOnPopup) then
        OnPopup(Self);
    end
    else begin
      if ssCtrl in Shift then
        SetSelected(Tile, False)
      else begin
        ClearSelection();
        SetSelected(Tile);
        LastControlClicked:=Tile;
      end;

      MakeVisible(Tile.BoundsRect);

      if TabStop and not Focused then
        SetFocus;

      ActiveControl:=Tile;
      TileControlIndex:=IndexOfTileControl(ActiveControl);
      UpdateControls(True);

      if FSelectedControls.Count > 1 then begin
        if Assigned(FOnPopupMulti) then
          OnPopupMulti(Self);

        PopupPoint:=Tile.ClientToScreen(Point(X, Y));

        if Assigned(MultiselectPopupMenu) then
          MultiselectPopupMenu.Popup(PopupPoint.X, PopupPoint.Y);
      end
      else if Assigned(Tile.PopupMenu) and Assigned(FOnPopup) then
        OnPopup(Self);
    end;
  end;
end;

procedure TTilesBoxControl.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TTilesBoxControl.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  Tile:=TTileControl(Sender);

  if Tile = Nil then
    Exit;

  if Button = mbLeft then begin
    if FMultiselect then begin
      if ssCtrl in Shift then
        SetSelected(Tile)
      else begin
        if LastControlClicked = Tile then
          Exit;

        ClearSelection();
        SetSelected(Tile);
        LastControlClicked:=Tile;
      end;
    end
    else if (LastControlClicked <> Nil) and (LastControlClicked = Tile) then begin
      LastControlClicked:=Nil;
//      ClearSelection(True);
      Tile.Hovered:=True;
      Tile.Invalidate;
    end;
  end
  else if Button = mbRight then begin
    if not FMultiselect then begin
      MakeVisible(Tile.BoundsRect);

      if TabStop and not Focused then
        SetFocus;

      ActiveControl:=Tile;
      TileControlIndex:=IndexOfTileControl(ActiveControl);
      UpdateControls(True);

      if Assigned(Tile.PopupMenu) and Assigned(FOnPopup) then
        OnPopup(Self);
    end
    else begin
      if ssCtrl in Shift then
        SetSelected(Tile, False)
      else begin
        ClearSelection();
        SetSelected(Tile);
        LastControlClicked:=Tile;
      end;

      MakeVisible(Tile.BoundsRect);

      if TabStop and not Focused then
        SetFocus;

      ActiveControl:=Tile;
      TileControlIndex:=IndexOfTileControl(ActiveControl);
      UpdateControls(True);

      if FSelectedControls.Count > 1 then begin
        if Assigned(FOnPopupMulti) then
          OnPopupMulti(Self);

        PopupPoint:=Tile.ClientToScreen(Point(X, Y));

        if Assigned(MultiselectPopupMenu) then
          MultiselectPopupMenu.Popup(PopupPoint.X, PopupPoint.Y);
      end
      else if Assigned(Tile.PopupMenu) and Assigned(FOnPopup) then
        OnPopup(Self);
    end;
  end;
end;

procedure TTilesBoxControl.ControlPaint(const Sender: TCustomTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect);
var
  Sel: TTileControlDrawState;
  StdPaint: Boolean;
//  cm: TCopyMode;
begin
  ControlPainting:=True;
  try
    Sel:=cdsNormal;

    if not FMultiselect then begin
      if (ActiveControl <> Nil) and (Sender = ActiveControl) then begin
        Sel:=cdsSelected;
        if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
          Sel:=cdsSelFocused;
      end
      else if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
        Sel:=cdsFocused;
    end
    else begin
      if FSelectedControls.IndexOf(TTileControl(Sender)) >= 0 then begin
        Sel:=cdsSelected;
        if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
          Sel:=cdsSelFocused;
      end
      else if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
        Sel:=cdsFocused;
    end;

    if not Assigned(FControlPaint) then begin
      if (Sel = cdsSelected) or (Sel = cdsSelFocused) then
        TargetCanvas.Brush.Color:=SelectedColor
      else
        TargetCanvas.Brush.Color:=TTileControl(Sender).Color;
      DrawControl(TTileControl(Sender), TargetCanvas, TargetRect, Sel);
      if (Sel = cdsFocused) or (Sel = cdsSelFocused) then begin
  //      cm:=TargetCanvas.CopyMode;
  //      try
  //        TargetCanvas.CopyMode:=cmMergePaint;
  //        TargetCanvas.Brush.Color:=SelectedColor;
          TargetCanvas.Brush.Style:=bsClear;
          TargetCanvas.Pen.Color:=SelectedColor;
          TargetCanvas.Pen.Mode:=pmMask;
          TargetCanvas.Pen.Style:=psInsideFrame;
          TargetCanvas.Pen.Width:=Max(TargetRect.Right - TargetRect.Left, TargetRect.Bottom - TargetRect.Top) div 2;
          TargetCanvas.Rectangle(TargetRect);
          //TargetCanvas.DrawFocusRect(TargetRect);
  //      finally
  //        TargetCanvas.CopyMode:=cm;
  //      end;
      end;
      if TTileControl(Sender).Hovered then begin
        TargetCanvas.Brush.Style:=bsClear;
        TargetCanvas.Pen.Color:=HoverColor;
        TargetCanvas.Pen.Mode:=pmMerge;
        TargetCanvas.Pen.Style:=psInsideFrame;
        TargetCanvas.Pen.Width:=2;
        TargetCanvas.Rectangle(TargetRect);
      end;
    end
    else begin
      StdPaint:=False;
      if Assigned(FControlPaintBkgnd) then
        OnControlPaintBkgnd(TTileControl(Sender), TargetCanvas, TargetRect, Sel, StdPaint);
      if StdPaint then begin
        DrawControl(TTileControl(Sender), TargetCanvas, TargetRect, Sel);
        if (Sel = cdsFocused) or (Sel = cdsSelFocused) then begin
    //      cm:=TargetCanvas.CopyMode;
    //      try
    //        TargetCanvas.CopyMode:=cmMergePaint;
            TargetCanvas.Brush.Style:=bsSolid;
            TargetCanvas.Pen.Color:=SelectedColor;
            TargetCanvas.Pen.Mode:=pmMerge;
            TargetCanvas.Pen.Style:=psSolid;
            TargetCanvas.Pen.Width:=1;
            TargetCanvas.FillRect(TargetRect);
            //TargetCanvas.DrawFocusRect(TargetRect);
    //      finally
    //        TargetCanvas.CopyMode:=cm;
    //      end;
        end;
        if TTileControl(Sender).Hovered then begin
          TargetCanvas.Brush.Style:=bsClear;
          TargetCanvas.Pen.Color:=HoverColor;
          TargetCanvas.Pen.Mode:=pmMerge;
          TargetCanvas.Pen.Style:=psInsideFrame;
          TargetCanvas.Pen.Width:=2;
          TargetCanvas.Rectangle(TargetRect);
        end;
      end
      else
        OnControlPaint(TTileControl(Sender), TargetCanvas, TargetRect, Sel);
    end;
  finally
    ControlPainting:=False;
  end;
end;

procedure TTilesBoxControl.ControlsAligned;

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

procedure TTilesBoxControl.ControlMouseEnter(Sender: TObject);
var
  Tile: TTileControl;
//  DrawState: TTileControlDrawState;
begin
  Tile:=TTileControl(Sender);

  if Tile = Nil then
    Exit;

//  DrawState:=GetControlDrawState(IndexOfTileControl(Tile));
//  case DrawState of
//    cdsNormal: DrawState:=cdsHovered;
//    cdsSelected: DrawState:=cdsSelectedHovered;
//    cdsFocused: DrawState:=cdsFocusedHovered;
//    cdsSelFocused: DrawState:=cdsSelFocusedHovered;
//  end;

  Tile.Hovered:=True;
end;

procedure TTilesBoxControl.ControlMouseLeave(Sender: TObject);
var
  Tile: TTileControl;
//  DrawState: TTileControlDrawState;
begin
  Tile:=TTileControl(Sender);

  if Tile = Nil then
    Exit;

//  DrawState:=GetControlDrawState(IndexOfTileControl(Tile));
//  case DrawState of
//    cdsHovered: DrawState:=cdsNormal;
//    cdsSelectedHovered: DrawState:=cdsSelected;
//    cdsFocusedHovered: DrawState:=cdsFocused;
//    cdsSelFocusedHovered: DrawState:=cdsSelFocused;
//  end;

  Tile.Hovered:=False;
end;

constructor TTilesBoxControl.Create(AOwner: TComponent);
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
  LastMovedIndex:=-1;

  VertScrollBar.Smooth:=True;
  VertScrollBar.Tracking:=True;
  HorzScrollBar.Smooth:=True;
  HorzScrollBar.Tracking:=True;
end;

procedure TTilesBoxControl.CreateParams(var Params: TCreateParams);
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

destructor TTilesBoxControl.Destroy;
begin
//  FUserObjects.Clear;
//  FUserObjects.Free;
  FSelectedControls.Clear;
  FSelectedControls.Free;
  FControlsCollection.Free;
  inherited Destroy;
end;

procedure TTilesBoxControl.DoClick(const Control: TTileControl);
begin
  if Assigned(FOnControlClick) then
    FOnControlClick(Self, Control, TileControlIndex);
end;

procedure TTilesBoxControl.DoDblClick(const Control: TTileControl);
begin
  if Assigned(FOnControlDblClick) then
    FOnControlDblClick(Self, Control, TileControlIndex);
end;

procedure TTilesBoxControl.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Tile: TCustomTileControl;
  idx, move_idx: Integer;
  drop_pt: TPoint;
  tile_rect: TRect;
  item: TTileControlItem;
begin
  Accept:=(Source is TTilesBoxControl) or (Source is TCustomTileControl) or (Source is TTileDragObject);
  if Accept and (State = dsDragMove) then begin
    drop_pt:=CalculateControlPos(Point(X, Y));
    move_idx:=ControlsCollection.IndexOfTileControlAt(drop_pt, tile_rect);
    Tile:=Nil;
    if TTileDragObject(Source).Control is TCustomTileControl then
      Tile:=TCustomTileControl(TTileDragObject(Source).Control);
    if move_idx > -1 then begin
      if (LastMovedIndex > -1) then begin
        if LastMovedIndex < move_idx then begin
          ControlsCollection.Delete(LastMovedIndex);
          item:=TTileControlItem(ControlsCollection.Insert(move_idx));
          item.TileControl:=Tile;
          LastMovedIndex:=move_idx;
          UpdateControls(True);
        end
        else if LastMovedIndex > move_idx then begin

        end;
      end
      else begin
        LastMovedIndex:=move_idx;
      end;
    end;

{    if TTileDragObject(Source).Control is TCustomTileControl then begin
      Tile:=TCustomTileControl(TTileDragObject(Source).Control);
      if Tile <> Nil then begin
        idx:=ControlsCollection.IndexOfTileControl(Tile);
//        if idx > -1 then begin
//          ControlsCollection.Items[idx].SetPosition(drop_pt.X, drop_pt.Y);
//          UpdateControls(True);
//        end;
      end;
    end;}
  end;
end;

procedure TTilesBoxControl.DragDrop(Source: TObject; X, Y: Integer);
var
  Tile: TCustomTileControl;
  idx: Integer;
  drop_pt: TPoint;
begin
  if Source is TTileDragObject then begin
    drop_pt:=CalculateControlPos(Point(X, Y));
    if TTileDragObject(Source).Control is TCustomTileControl then begin
      Tile:=TCustomTileControl(TTileDragObject(Source).Control);
      if Tile <> Nil then begin
        Tile.Visible:=True;
//        idx:=ControlsCollection.IndexOfTileControl(Tile);
//        if idx > -1 then begin
//          if PointsEqual(drop_pt, ControlsCollection.Items[idx].GetPosition) then begin
//            ControlsCollection.Items[idx].FUserPosition:=False;
//          end
//          else begin
//            if ControlsCollection.Items[idx].FUserPosition and ControlsCollection.Items[idx].TilePosition.AutoPositioning then
//              ControlsCollection.Items[idx].TilePosition.AutoPositioning:=False;
//          end;
//          ControlsCollection.Items[idx].SetPosition(drop_pt.X, drop_pt.Y);
//          UpdateControls(True);
//        end;
      end;
    end;
  end;

//  ShowMessage(Format('DragDrop %s at %d, %d', [TTileDragObject(Source).Control.Name, X, Y]));
end;

procedure TTilesBoxControl.DoStartDrag(var DragObject: TDragObject);
begin
//
end;

procedure TTilesBoxControl.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  SharedEndDrag(Target, X, Y);
end;

procedure TTilesBoxControl.SharedEndDrag(Target: TObject; X, Y: Integer);
begin
  //All draggable controls share this event handler
  FDragObject.Free;
  FDragObject:=Nil;
end;

procedure TTilesBoxControl.DrawControl(const TargetControl: TTileControl; const TargetCanvas: TCanvas; const TargetRect: TRect; const TargetState: TTileControlDrawState);
var
  CaptionText, Text1, Text2, Text3, Text4: String;
  H1, H2, H3, H4, text_width, text_height: Integer;
  MaxWidth, MaxHeight, IcoWidth, IcoHeight: Integer;
  text1_rect, text2_rect, text3_rect, text4_rect, text_rect: TRect;

  function HeightOfText(ACanvas: TCanvas; AText: String; var ARect: TRect; HAlignment: TAlignment; const VAlignment: TVerticalAlignment; WordWrap: Boolean; CanDraw: Boolean = False): Integer;
  const
    HAlignments: Array[TAlignment] of LongWord = (DT_LEFT, DT_RIGHT, DT_CENTER);
    VAlignments: array[TVerticalAlignment] of Longint = (DT_TOP, DT_BOTTOM, DT_VCENTER);
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
      if (IcoWidth > 0) and (IcoHeight > 0) then begin
        text_rect:=TargetControl.ClientRect;
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

function TTilesBoxControl.GetTileControl(Index: Integer): TTileControl;
begin
  if (Index < 0) or (Index >= GetControlsCount) then
    Exception.CreateFmt(SListIndexError, [Index]);
  Result:=TTileControl(Self.Controls[Index]);
end;

function TTilesBoxControl.GetControlDrawState(Index: Integer): TTileControlDrawState;
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
    if Self.IndexOfTileControl(Tile) >= 0 then begin
      Result:=cdsSelected;
      if Index = FControlIndex then
        Result:=cdsSelFocused;
    end
    else if Index = FControlIndex then
      Result:=cdsFocused;
  end;
end;

function TTilesBoxControl.GetControlsCount: Integer;
begin
  Result:=Self.ControlCount;
end;

function TTilesBoxControl.GetSelectedCount: Integer;
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

function TTilesBoxControl.IndexOfTileControl(const Control: TCustomTileControl): Integer;
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

procedure TTilesBoxControl.Loaded;
begin
  inherited;
  CalcRowsCols;
end;

function TTilesBoxControl.IndexOfPopup(const Sender: TObject): Integer;
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

procedure TTilesBoxControl.MakeVisible(const Bounds: TRect);
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

procedure TTilesBoxControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TabStop and CanFocus then
    SetFocus;
  inherited;
  if Button = mbLeft then
    ClearSelection(True);
end;

procedure TTilesBoxControl.PaintWindow(DC: HDC);
begin
  //  Do nothing
end;

function TTilesBoxControl.RemoveTile(var Tile: TTileControl): Boolean;
begin
  Result:=False;
  if (Tile <> Nil) and (Tile.Parent = Self) then begin
    Tile.Visible:=False;
    Tile.Free;
    Tile:=Nil;
    Result:=True;
  end;
end;

procedure TTilesBoxControl.Resize;
begin
  inherited Resize;
  CalcRowsCols;
  UpdateControls(True);
  CalcScrollBar(HorzScrollBar);
  CalcScrollBar(VertScrollBar);
  if Assigned(FOnResize) then
    FOnResize(Self);
end;

procedure TTilesBoxControl.SetBorderStyle(Value: TBorderStyle);
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

procedure TTilesBoxControl.SetTileControl(Index: Integer; const Control: TTileControl);
begin
  if (Index < 0) or (Index >= GetControlsCount) then
    Exception.CreateFmt(SListIndexError, [Index]);

//  Self.Components[Index]:=Value;
  UpdateControls(True);
end;

procedure TTilesBoxControl.SetControlDrawState(Index: Integer; const DrawState: TTileControlDrawState);
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

procedure TTilesBoxControl.SetControlIndex(const Value: Integer);
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

procedure TTilesBoxControl.SetControlsCollection(const Value: TTileControlsCollection);
begin
  FControlsCollection.Assign(Value);
end;

procedure TTilesBoxControl.SetGroupIndent(const Value: Word);
begin
  if FGroupIndent <> Value then begin
    FGroupIndent:=Value;
    DoUpdate:=True;
    Realign;
  end;
end;

procedure TTilesBoxControl.SetHoverColor(const Value: TColor);
begin
  if FHoverColor <> Value then begin
    FHoverColor:=Value;
    UpdateControls(True);
  end;
end;

procedure TTilesBoxControl.SetIndentHorz(const Value: Word);
begin
  if FIndentHorz <> Value then begin
    FIndentHorz:=Value;
    DoUpdate:=True;
    Realign;
  end;
end;

procedure TTilesBoxControl.SetIndentVert(const Value: Word);
begin
  if FIndentVert <> Value then begin
    FIndentVert:=Value;
    DoUpdate:=True;
    Realign;
  end;
end;

procedure TTilesBoxControl.SetSpacer(const Value: Word);
begin
  if FSpacer <> Value then begin
    FSpacer:=Value;
    UpdateControls(True);
  end;
end;

procedure TTilesBoxControl.SetOrientation(const Value: TScrollBarKind);
begin
  if FOrientation <> Value then begin
    FOrientation:=Value;
    UpdateControls(True);
  end;
end;

procedure TTilesBoxControl.SetSelectedColor(const Value: TColor);
begin
  if FSelectedColor <> Value then begin
    FSelectedColor:=Value;
    UpdateControls(True);
  end;
end;

procedure TTilesBoxControl.SetMultiselect(const Value: Boolean);
begin
  if FMultiselect <> Value then begin
    FMultiselect:=Value;
    UpdateControls(True);
  end;
end;

procedure TTilesBoxControl.SetSelected(const Control: TTileControl; const CanDeselect: Boolean = True);
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

procedure TTilesBoxControl.UpdateTiles;
begin
  if HandleAllocated and (GetControlsCount > 0) and HorzScrollBar.Visible and VertScrollBar.Visible then
    UpdateControls(True);
end;

procedure TTilesBoxControl.MoveControls(const FromIndex: Integer);
begin
  if (GetControlsCount > 0) then begin

    FControlsCollection.RebuildAlignment(FromIndex);
    FControlsCollection.AlignTileControls(Nil);
  end;
end;

procedure TTilesBoxControl.UpdateControl(const Index: Integer);
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

procedure TTilesBoxControl.UpdateControls(const Rebuild: Boolean);
var
  i: Integer;
//  ScrollPos: TPoint;
//  TileSize: TPoint;
//  ViewPos: TPoint;
  Tile: TTileControl;
//  HorzSpace, VertSpace: Integer;

  ControlRect: TRect;
  Position: TPoint;
  Size: TPoint;
  MaxHeight, MaxWidth: Integer;
//  GroupWidth, GroupHeight: Integer;
//  SizeX, SizeY: Integer;
begin
  if not Updating then begin
    Updating:=True;
    try
      if (GetControlsCount > 0) then begin
        if Rebuild then begin
          FControlsCollection.RebuildAlignment;
          FControlsCollection.AlignTileControls(Nil);

//          ScrollPos.X:=0 - HorzScrollBar.Position;
//          ScrollPos.Y:=0 - VertScrollBar.Position;
//          ViewPos:=Point(0, 0);


//          if Orientation = sbVertical then begin
//            if (SizeX > ClientWidth) and not HorzScrollBarVisible then
//              HorzScrollBar.Visible:=True;
//          end
//          else begin
//            if (SizeY > ClientHeight) and not VertScrollBarVisible then
//              VertScrollBar.Visible:=True;
//          end;

{          for i:=0 to GetControlsCount - 1 do begin
            HorzSpace:=ClientWidth;
            VertSpace:=ClientHeight;
            Tile:=GetTileControl(i);
            CalculateControlBounds(i, TileSize);
//            Tile.SetBounds(TilePos.X + ViewPos.X, TilePos.Y + ViewPos.Y, TileSize.X, TileSize.Y);
            Tile.Paint;
//            Application.ProcessMessages;

//            if Orientation = sbVertical then begin
//              if VertScrollBar.IsScrollBarVisible <> VertScrollBarVisible then begin
//                Updating:=False;
//                UpdateControls(Rebuild);
//                Break;
//              end;
//            end
//            else begin
//              if HorzScrollBar.IsScrollBarVisible <> HorzScrollBarVisible then begin
//                Updating:=False;
//                UpdateControls(Rebuild);
//                Break;
//              end;
//            end;

            if Orientation = sbVertical then begin
              Inc(ViewPos.X, TileSize.X);

//              if TilePos.X + TileSize.X > HorzSpace then begin
//                TilePos.X:=0;
//                Inc(TilePos.Y, TileSize.Y);
//              end;
            end
            else begin
              Inc(ViewPos.Y, TileSize.Y);

//              if TilePos.Y + TileSize.Y > VertSpace then begin
//                TilePos.Y:=0;
//                Inc(TilePos.X, TileSize.X);
//              end;
            end;

//            if Orientation = sbVertical then begin
//              FColCount:=1;
//
//              if TileSize.X > 0 then begin
//                FColCount:=HorzSpace div TileSize.X;
//                if FColCount = 0 then
//                  FColCount:=1;
//              end;
//
//              FRowCount:=GetControlsCount div FColCount;
//            end
//            else begin
//              FRowCount:=1;
//
//              if TileSize.Y > 0 then begin
//                FRowCount:=VertSpace div TileSize.Y;
//                if FRowCount = 0 then
//                  FRowCount:=1;
//              end;
//
//              FColCount:=GetControlsCount div FRowCount;
//            end;
          end;}
        end;

//        if ActiveControl <> Nil then begin
//          i:=IndexOfTileControl(ActiveControl);
//          TileControlIndex:=i;
//
//          if i >= 0 then
//            Tile:=GetTileControl(i)
//          else
//            Tile:=Nil;
//
//          ActiveControl:=Tile;
//        end
//        else
//          TileControlIndex:=-1;

//        if ActiveControl <> Nil then begin
//          MakeVisible(ActiveControl.BoundsRect);
//          ActiveControl.Invalidate;
//        end
//        else
//          TileControlIndex:=-1;

        Update;

//        if Assigned(FOnChange) then
//          OnChangeSelection(Self);
      end;
    finally
      Updating:=False;
    end;
  end;
end;

procedure TTilesBoxControl.WMEraseBkgnd(var Message: TWmEraseBkgnd);

  procedure DrawGrid;
  var
    Canvas: TCanvas;
    ClientRect: TRect;
    x, y, max_x, max_y: Integer;
  begin
    Canvas:=TControlCanvas.Create;
    TControlCanvas(Canvas).Control:=Self;
    try
      ClientRect:=GetClientRect;
      if IsRectEmpty(ClientRect) then
        Exit;
      AdjustClientRect(ClientRect);
      InflateRect(ClientRect, -IndentHorz, -IndentVert);
      max_x:=ClientRect.Right;
      max_y:=ClientRect.Bottom;

      Canvas.Brush.Color:=Color;
      Canvas.FillRect(GetClientRect);
      Canvas.Pen.Color:=clYellow;

      x:=ClientRect.Left;
      while  x < max_x do begin
        Canvas.MoveTo(x, ClientRect.Top);
        Canvas.LineTo(x, ClientRect.Bottom);
        Inc(x, 48);
        if x > max_x then
          Break;
        Canvas.MoveTo(x, ClientRect.Top);
        Canvas.LineTo(x, ClientRect.Bottom);
        Inc(x, Spacer);
      end;

      y:=ClientRect.Top;
      while  y < max_y do begin
        Canvas.MoveTo(ClientRect.Left, y);
        Canvas.LineTo(ClientRect.Right, y);
        Inc(y, 48);
        if y > max_y then
          Break;
        Canvas.MoveTo(ClientRect.Left, y);
        Canvas.LineTo(ClientRect.Right, y);
        Inc(y, Spacer);
      end;
    finally
      Canvas.Free;
    end;
  end;

begin
  if not ControlPainting then begin
    inherited;
    //DrawGrid;
  end
  else
    Message.Result:=1;
end;

procedure TTilesBoxControl.WMMouseWheel(var Msg: TMessage);
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

procedure TTilesBoxControl.WMNCHitTest(var Message: TWMNCHitTest);
begin
  DefaultHandler(Message);
end;

procedure TTilesBoxControl.WMPrintClient(var Message: TWMPrintClient);
//var
//  LControlState: TControlState;
begin
//  LControlState:=Self.ControlState;
//  Exclude(LControlState, csPrintClient);
//  Self.ControlState:=LControlState;
  Message.Result:=1;
  inherited;
end;

procedure TTilesBoxControl.WndProc(var Message: TMessage);
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
