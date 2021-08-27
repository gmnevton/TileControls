unit TileControlEvents;

interface

uses
  SysUtils,
  Classes,
  Types,
  Controls,
  Graphics;

type
  TTileControlEvents = class
  public
    procedure ControlClick(const ATileBox: TWinControl; const ATileControl: TControl);
    procedure ControlDblClick(const ATileBox: TWinControl; const ATileControl: TControl);
    //
    procedure ControlMouseDown(const ATileBox: TWinControl; const ATileControl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseEnter(const ATileBox: TWinControl; const ATileControl: TControl);
    procedure ControlMouseLeave(const ATileBox: TWinControl; const ATileControl: TControl);
    procedure ControlMouseMove(const ATileBox: TWinControl; const ATileControl: TControl; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(const ATileBox: TWinControl; const ATileControl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    //
    procedure ControlPaint(const ATileBox: TWinControl; const ATileControl: TControl; TargetCanvas: TCanvas; TargetRect: TRect);
  end;

function ControlEvents: TTileControlEvents;

implementation

uses
  Contnrs,
  Math,
  TileBox,
  TileControl;

type
  TTileBoxAccess = class(TTileBox);

var
  GControlEvents: TTileControlEvents;

function ControlEvents: TTileControlEvents;
begin
  if GControlEvents = Nil then
    GControlEvents:=TTileControlEvents.Create;
  Result:=GControlEvents;
end;


{ TTileControlEvents }

procedure TTileControlEvents.ControlClick(const ATileBox: TWinControl; const ATileControl: TControl);
var
  TileBox: TTileBox;
  Tile: TTileControl;
begin
  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

  TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

  if TileBox.TabStop and not TileBox.Focused then
    TileBox.SetFocus;

  TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
  TTileBoxAccess(TileBox).UpdateControls(True);
  TTileBoxAccess(TileBox).DoClick;
end;

procedure TTileControlEvents.ControlDblClick(const ATileBox: TWinControl; const ATileControl: TControl);
var
  TileBox: TTileBox;
  Tile: TTileControl;
begin
  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

  TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

  if TileBox.TabStop and not TileBox.Focused then
    TileBox.SetFocus;

  TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
  TTileBoxAccess(TileBox).UpdateControls(True);
  TTileBoxAccess(TileBox).DoDblClick;
end;

procedure TTileControlEvents.ControlMouseDown(const ATileBox: TWinControl; const ATileControl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TileBox: TTileBox;
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

  if Button = mbLeft then begin
    if TTileBoxAccess(TileBox).Multiselect then begin
      if ssCtrl in Shift then
        TTileBoxAccess(TileBox).SetSelected(Tile)
      else begin
        if TTileBoxAccess(TileBox).LastControlClicked = Tile then
          Exit;

        TTileBoxAccess(TileBox).ClearSelection();
        TTileBoxAccess(TileBox).SetSelected(Tile);
        TTileBoxAccess(TileBox).LastControlClicked:=Tile;
      end;
    end
    else begin
      TTileBoxAccess(TileBox).LastControlClicked:=Tile;
//      TTileBoxAccess(TileBox).ClearSelection(True);
      Tile.Hovered:=False;
      Tile.Invalidate;
    end;
  end
  else if Button = mbRight then begin
    if not TTileBoxAccess(TileBox).Multiselect then begin
      TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

      if TileBox.TabStop and not TileBox.Focused then
        TileBox.SetFocus;

      TTileBoxAccess(TileBox).ActiveControl:=Tile;
      //TileControlIndex:=IndexOfTileControl(ActiveControl);
      TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
      TTileBoxAccess(TileBox).UpdateControls(True);

      if Tile.PopupMenu <> Nil then
        TTileBoxAccess(TileBox).DoPopup(Self);
    end
    else begin
      if ssCtrl in Shift then
        TTileBoxAccess(TileBox).SetSelected(Tile, False)
      else begin
        TTileBoxAccess(TileBox).ClearSelection();
        TTileBoxAccess(TileBox).SetSelected(Tile);
        TTileBoxAccess(TileBox).LastControlClicked:=Tile;
      end;

      TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

      if TileBox.TabStop and not TileBox.Focused then
        TileBox.SetFocus;

      TTileBoxAccess(TileBox).ActiveControl:=Tile;
      //TileControlIndex:=IndexOfTileControl(ActiveControl);
      TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
      TTileBoxAccess(TileBox).UpdateControls(True);

      if TTileBoxAccess(TileBox).SelectedCount > 1 then begin
        TTileBoxAccess(TileBox).DoPopupMulti(Self);

        PopupPoint:=Tile.ClientToScreen(Point(X, Y));

        if (TTileBoxAccess(TileBox).MultiselectPopupMenu <> Nil) then
          TTileBoxAccess(TileBox).MultiselectPopupMenu.Popup(PopupPoint.X, PopupPoint.Y);
      end
      else if Tile.PopupMenu <> Nil then
        TTileBoxAccess(TileBox).DoPopup(Self);
    end;
  end;
end;

procedure TTileControlEvents.ControlMouseEnter(const ATileBox: TWinControl; const ATileControl: TControl);
var
//  TileBox: TTileBox;
  Tile: TTileControl;
//  DrawState: TTileControlDrawState;
begin
//  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

//  DrawState:=GetControlDrawState(IndexOfTileControl(Tile));
//  case DrawState of
//    cdsNormal: DrawState:=cdsHovered;
//    cdsSelected: DrawState:=cdsSelectedHovered;
//    cdsFocused: DrawState:=cdsFocusedHovered;
//    cdsSelFocused: DrawState:=cdsSelFocusedHovered;
//  end;

  Tile.Hovered:=True;
end;

procedure TTileControlEvents.ControlMouseLeave(const ATileBox: TWinControl; const ATileControl: TControl);
var
//  TileBox: TTileBox;
  Tile: TTileControl;
//  DrawState: TTileControlDrawState;
begin
//  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

//  DrawState:=GetControlDrawState(IndexOfTileControl(Tile));
//  case DrawState of
//    cdsHovered: DrawState:=cdsNormal;
//    cdsSelectedHovered: DrawState:=cdsSelected;
//    cdsFocusedHovered: DrawState:=cdsFocused;
//    cdsSelFocusedHovered: DrawState:=cdsSelFocused;
//  end;

  Tile.Hovered:=False;
end;

procedure TTileControlEvents.ControlMouseMove(const ATileBox: TWinControl; const ATileControl: TControl; Shift: TShiftState; X, Y: Integer);
//var
//  TileBox: TTileBox;
//  Tile: TTileControl;
begin

end;

procedure TTileControlEvents.ControlMouseUp(const ATileBox: TWinControl; const ATileControl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TileBox: TTileBox;
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

  if (Tile = Nil) or Tile.InDragMode then
    Exit;

  if Button = mbLeft then begin
    if TTileBoxAccess(TileBox).Multiselect then begin
      if ssCtrl in Shift then
        TTileBoxAccess(TileBox).SetSelected(Tile)
      else begin
        if TTileBoxAccess(TileBox).LastControlClicked = Tile then
          Exit;

        TTileBoxAccess(TileBox).ClearSelection();
        TTileBoxAccess(TileBox).SetSelected(Tile);
        TTileBoxAccess(TileBox).LastControlClicked:=Tile;
      end;
    end
    else if (TTileBoxAccess(TileBox).LastControlClicked <> Nil) and (TTileBoxAccess(TileBox).LastControlClicked = Tile) then begin
      TTileBoxAccess(TileBox).LastControlClicked:=Nil;
//      ClearSelection(True);
      Tile.Hovered:=True;
      Tile.Invalidate;
    end;
  end
  else if Button = mbRight then begin
    if not TTileBoxAccess(TileBox).Multiselect then begin
      TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

      if TileBox.TabStop and not TileBox.Focused then
        TileBox.SetFocus;

      TTileBoxAccess(TileBox).ActiveControl:=Tile;
      //TileControlIndex:=IndexOfTileControl(ActiveControl);
      TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
      TTileBoxAccess(TileBox).UpdateControls(True);

      if Tile.PopupMenu <> Nil then
        TTileBoxAccess(TileBox).DoPopup(Self);
    end
    else begin
      if ssCtrl in Shift then
        TTileBoxAccess(TileBox).SetSelected(Tile, False)
      else begin
        TTileBoxAccess(TileBox).ClearSelection();
        TTileBoxAccess(TileBox).SetSelected(Tile);
        TTileBoxAccess(TileBox).LastControlClicked:=Tile;
      end;

      TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

      if TileBox.TabStop and not TileBox.Focused then
        TileBox.SetFocus;

      TTileBoxAccess(TileBox).ActiveControl:=Tile;
      //TileControlIndex:=IndexOfTileControl(ActiveControl);
      TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
      TTileBoxAccess(TileBox).UpdateControls(True);

      if TTileBoxAccess(TileBox).SelectedCount > 1 then begin
        TTileBoxAccess(TileBox).DoPopupMulti(Self);

        PopupPoint:=Tile.ClientToScreen(Point(X, Y));

        if TTileBoxAccess(TileBox).MultiselectPopupMenu <> Nil then
          TTileBoxAccess(TileBox).MultiselectPopupMenu.Popup(PopupPoint.X, PopupPoint.Y);
      end
      else if Tile.PopupMenu <> Nil then
        TTileBoxAccess(TileBox).DoPopup(Self);
    end;
  end;
end;

procedure TTileControlEvents.ControlPaint(const ATileBox: TWinControl; const ATileControl: TControl; TargetCanvas: TCanvas; TargetRect: TRect);
var
  TileBox: TTileBox;
  Tile: TTileControl;
  Sel: TTileControlDrawState;
  StdPaint: Boolean;
//  cm: TCopyMode;
begin
  TileBox:=TTileBox(ATileBox);
  Tile:=TTileControl(ATileControl);

  TTileBoxAccess(TileBox).ControlPainting:=True;
  try
    Sel:=cdsNormal;

    if not TTileBoxAccess(TileBox).Multiselect then begin
      if (TTileBoxAccess(TileBox).ActiveControl <> Nil) and (ATileControl = TTileBoxAccess(TileBox).ActiveControl) then begin
        Sel:=cdsSelected;
        //if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
        if Tile.ControlsCollectionIndex = TTileBoxAccess(TileBox).TileControlIndex then
          Sel:=cdsSelFocused;
      end
      //else if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
      else if Tile.ControlsCollectionIndex = TTileBoxAccess(TileBox).TileControlIndex then
        Sel:=cdsFocused;
    end
    else begin
      if TTileBoxAccess(TileBox).IndexOfSelected(Tile) >= 0 then begin
        Sel:=cdsSelected;
        //if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
        if Tile.ControlsCollectionIndex = TTileBoxAccess(TileBox).TileControlIndex then
          Sel:=cdsSelFocused;
      end
      //else if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
      else if Tile.ControlsCollectionIndex = TTileBoxAccess(TileBox).TileControlIndex then
        Sel:=cdsFocused;
    end;

    if not Assigned(TTileBoxAccess(TileBox).OnControlPaint) then begin
      if (Sel = cdsSelected) or (Sel = cdsSelFocused) then
        TargetCanvas.Brush.Color:=TTileBoxAccess(TileBox).SelectedColor
      else
        TargetCanvas.Brush.Color:=Tile.Color;
      TTileBoxAccess(TileBox).DrawControl(Tile, TargetCanvas, TargetRect, Sel);
      if (Sel = cdsFocused) or (Sel = cdsSelFocused) then begin
  //      cm:=TargetCanvas.CopyMode;
  //      try
  //        TargetCanvas.CopyMode:=cmMergePaint;
  //        TargetCanvas.Brush.Color:=SelectedColor;
          TargetCanvas.Brush.Style:=bsClear;
          TargetCanvas.Pen.Color:=TTileBoxAccess(TileBox).SelectedColor;
          TargetCanvas.Pen.Mode:=pmMask;
          TargetCanvas.Pen.Style:=psInsideFrame;
          TargetCanvas.Pen.Width:=Max(TargetRect.Right - TargetRect.Left, TargetRect.Bottom - TargetRect.Top) div 2;
          TargetCanvas.Rectangle(TargetRect);
          //TargetCanvas.DrawFocusRect(TargetRect);
  //      finally
  //        TargetCanvas.CopyMode:=cm;
  //      end;
      end;
      if Tile.Hovered then begin
        TargetCanvas.Brush.Style:=bsClear;
        TargetCanvas.Pen.Color:=TTileBoxAccess(TileBox).HoverColor;
        TargetCanvas.Pen.Mode:=pmMerge;
        TargetCanvas.Pen.Style:=psInsideFrame;
        TargetCanvas.Pen.Width:=2;
        TargetCanvas.Rectangle(TargetRect);
      end;
    end
    else begin
      StdPaint:=False;
      TTileBoxAccess(TileBox).DoControlPaintBkgnd(Tile, TargetCanvas, TargetRect, Sel, StdPaint);
      if StdPaint then begin
        TTileBoxAccess(TileBox).DrawControl(Tile, TargetCanvas, TargetRect, Sel);
        if (Sel = cdsFocused) or (Sel = cdsSelFocused) then begin
    //      cm:=TargetCanvas.CopyMode;
    //      try
    //        TargetCanvas.CopyMode:=cmMergePaint;
            TargetCanvas.Brush.Style:=bsSolid;
            TargetCanvas.Pen.Color:=TTileBoxAccess(TileBox).SelectedColor;
            TargetCanvas.Pen.Mode:=pmMerge;
            TargetCanvas.Pen.Style:=psSolid;
            TargetCanvas.Pen.Width:=1;
            TargetCanvas.FillRect(TargetRect);
            //TargetCanvas.DrawFocusRect(TargetRect);
    //      finally
    //        TargetCanvas.CopyMode:=cm;
    //      end;
        end;
        if Tile.Hovered then begin
          TargetCanvas.Brush.Style:=bsClear;
          TargetCanvas.Pen.Color:=TTileBoxAccess(TileBox).HoverColor;
          TargetCanvas.Pen.Mode:=pmMerge;
          TargetCanvas.Pen.Style:=psInsideFrame;
          TargetCanvas.Pen.Width:=2;
          TargetCanvas.Rectangle(TargetRect);
        end;
      end
      else
        TTileBoxAccess(TileBox).DoControlPaint(Tile, TargetCanvas, TargetRect, Sel);
    end;
  finally
    TTileBoxAccess(TileBox).ControlPainting:=False;
  end;
end;

initialization
  GControlEvents:=Nil;

finalization
  if GControlEvents <> Nil then
    FreeAndNil(GControlEvents);

end.
