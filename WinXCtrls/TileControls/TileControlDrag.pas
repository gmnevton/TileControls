unit TileControlDrag;

interface

uses
  SysUtils,
  Classes,
  Controls,
  Types;

type
  TTileDragObject = class(TDragControlObject)
  private
    FDragImages: TDragImageList;
    FControlRect: TRect;
    FTopLeftOffset: TPoint;
    FSpotX, FSpotY: Integer;
  protected
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override;
    function GetDragImages: TDragImageList; override;
  public
    constructor CreateWithHotSpot(Control: TControl; X, Y: Integer);
    destructor Destroy; override;
    //
    property ControlRect: TRect read FControlRect;
    property TopLeftOffset: TPoint read FTopLeftOffset;
  end;

implementation

uses
  Graphics,
  TileControl;

type
  TCustomTileControlAccess = class(TCustomTileControl);

{ TTileDragObject }

constructor TTileDragObject.CreateWithHotSpot(Control: TControl; X, Y: Integer);
begin
  inherited Create(Control);
  FControlRect:=Control.ClientRect;
  FTopLeftOffset:=Point(X, Y);
  FSpotX:=X;
  FSpotY:=Y;
end;

destructor TTileDragObject.Destroy;
begin
  if FDragImages <> Nil then
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
      TCustomTileControlAccess(Control).PaintTo(Bmp.Canvas.Handle, 0, 0);
    finally
      Bmp.Canvas.UnLock;
    end;
    FDragImages.Width:=Control.Width;
    FDragImages.Height:=Control.Height;
    //Add bitmap to image list, making the grey pixels transparent
    Idx:=FDragImages.AddMasked(Bmp, TCustomTileControlAccess(Control).Color);
    //Set the drag image and hot spot
    FDragImages.SetDragImage(Idx, FSpotX, FSpotY);
  finally
    Bmp.Free
  end
end;

end.
