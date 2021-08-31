unit TileUtils;

interface

uses
  Windows,
  Types;

function PointsAdd(const A, B: TPoint): TPoint; inline;
function PointsDec(const A, B: TPoint): TPoint; inline;
function PointsAbs(const P: TPoint): TPoint; inline;

function GetTickDiff(const AOldTickCount, ANewTickCount: LongWord): LongWord; inline;

procedure DrawTransparentBitmap(DC: HDC; hBmp: HBITMAP; xStart: Integer; yStart: Integer; cTransparentColor: COLORREF);

implementation

function PointsAdd(const A, B: TPoint): TPoint;
begin
  Result:=Point(A.X + B.X, A.Y + B.Y);
end;

function PointsDec(const A, B: TPoint): TPoint;
begin
  Result:=Point(A.X - B.X, A.Y - B.Y);
end;

function PointsAbs(const P: TPoint): TPoint;
begin
  Result.X:=Abs(P.X);
  Result.Y:=Abs(P.Y);
end;

function GetTickDiff(const AOldTickCount, ANewTickCount: LongWord): LongWord;
begin
  {This is just in case the TickCount rolled back to zero}
  if ANewTickCount >= AOldTickCount then begin
    Result := ANewTickCount - AOldTickCount;
  end else begin
    Result := High(LongWord) - AOldTickCount + ANewTickCount;
  end;
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

end.
