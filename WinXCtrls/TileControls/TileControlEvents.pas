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
  private
    // FTileBox is TTileBox, but to avoid circular unit reference, we need to do it like that
    FTileBox: TWinControl;
    // FTileControl is TTileControl, but to avoid circular unit reference, we need to do it like that
    FTileControl: TControl;
  protected
    property TileBox: TWinControl read FTileBox;
    property Control: TControl read FTileControl;
  public
    constructor Create(const ATileBox: TWinControl; const AControl: TControl);
    destructor Destroy; override;
    //
    procedure ControlClick;
    procedure ControlDblClick;
    //
    procedure ControlMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseEnter;
    procedure ControlMouseLeave;
    procedure ControlMouseMove(Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    //
    procedure ControlPaint(TargetCanvas: TCanvas; TargetRect: TRect);
  end;

implementation

uses
  TileBox,
  TileControl;

type
  TTileBoxAccess = class(TTileBox);

{ TTileControlEvents }

constructor TTileControlEvents.Create(const ATileBox: TWinControl; const AControl: TControl);
begin
  FTileBox:=ATileBox;
  FTileControl:=AControl;
end;

destructor TTileControlEvents.Destroy;
begin
  FTileControl:=Nil;
  FTileBox:=Nil;
  inherited;
end;

procedure TTileControlEvents.ControlClick;
var
  Tile: TTileControl;
begin
  Tile:=TTileControl(Control);

  TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

  if TileBox.TabStop and not TileBox.Focused then
    TileBox.SetFocus;

//  ActiveControl:=TTileControl(Sender);
//  TileControlIndex:=IndexOfTileControl(TTileControl(Ctrl));
  TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
  TTileBoxAccess(TileBox).UpdateControls(True);
  TTileBoxAccess(TileBox).DoClick;
end;

procedure TTileControlEvents.ControlDblClick;
var
  Tile: TTileControl;
begin
  Tile:=TTileControl(Control);

  TTileBoxAccess(TileBox).MakeVisible(Tile.BoundsRect);

  if TileBox.TabStop and not TileBox.Focused then
    TileBox.SetFocus;

//  ActiveControl:=TTileControl(Sender);
  //TileControlIndex:=IndexOfTileControl(TTileControl(Sender));
  TTileBoxAccess(TileBox).TileControlIndex:=Tile.ControlsCollectionIndex;
  TTileBoxAccess(TileBox).UpdateControls(True);
  TTileBoxAccess(TileBox).DoDblClick;
end;

procedure TTileControlEvents.ControlMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  Tile:=TTileControl(Control);

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

      if Assigned(Tile.PopupMenu) and Assigned(TTileBoxAccess(TileBox).OnPopup) then
        TTileBoxAccess(TileBox).OnPopup(Self);
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
        if Assigned(TTileBoxAccess(TileBox).OnPopupMulti) then
          TTileBoxAccess(TileBox).OnPopupMulti(Self);

        PopupPoint:=Tile.ClientToScreen(Point(X, Y));

        if Assigned(TTileBoxAccess(TileBox).MultiselectPopupMenu) then
          TTileBoxAccess(TileBox).MultiselectPopupMenu.Popup(PopupPoint.X, PopupPoint.Y);
      end
      else if Assigned(Tile.PopupMenu) and Assigned(TTileBoxAccess(TileBox).OnPopup) then
        TTileBoxAccess(TileBox).OnPopup(Self);
    end;
  end;
end;

procedure TTileControlEvents.ControlMouseEnter;
var
  Tile: TTileControl;
//  DrawState: TTileControlDrawState;
begin
  Tile:=TTileControl(Control);

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

procedure TTileControlEvents.ControlMouseLeave;
var
  Tile: TTileControl;
//  DrawState: TTileControlDrawState;
begin
  Tile:=TTileControl(Control);

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

procedure TTileControlEvents.ControlMouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TTileControlEvents.ControlMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  Tile:=TTileControl(Control);

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

      if Assigned(Tile.PopupMenu) and Assigned(TTileBoxAccess(TileBox).OnPopup) then
        TTileBoxAccess(TileBox).OnPopup(Self);
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
        if Assigned(TTileBoxAccess(TileBox).OnPopupMulti) then
          TTileBoxAccess(TileBox).OnPopupMulti(Self);

        PopupPoint:=Tile.ClientToScreen(Point(X, Y));

        if Assigned(TTileBoxAccess(TileBox).MultiselectPopupMenu) then
          TTileBoxAccess(TileBox).MultiselectPopupMenu.Popup(PopupPoint.X, PopupPoint.Y);
      end
      else if Assigned(Tile.PopupMenu) and Assigned(TTileBoxAccess(TileBox).OnPopup) then
        TTileBoxAccess(TileBox).OnPopup(Self);
    end;
  end;
end;

procedure TTileControlEvents.ControlPaint(TargetCanvas: TCanvas; TargetRect: TRect);
var
  Sel: TTileControlDrawState;
  StdPaint: Boolean;
//  cm: TCopyMode;
begin
  TTileBoxAccess(TileBox).ControlPainting:=True;
  try
    Sel:=cdsNormal;

    if not FMultiselect then begin
      if (ActiveControl <> Nil) and (Sender = ActiveControl) then begin
        Sel:=cdsSelected;
        if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
        //if TTileControl(Sender).ControlsCollectionIndex = FControlIndex then
          Sel:=cdsSelFocused;
      end
      else if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
      //else if TTileControl(Sender).ControlsCollectionIndex = FControlIndex then
        Sel:=cdsFocused;
    end
    else begin
      if FSelectedControls.IndexOf(TTileControl(Sender)) >= 0 then begin
        Sel:=cdsSelected;
        if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
        //if TTileControl(Sender).ControlsCollectionIndex = FControlIndex then
          Sel:=cdsSelFocused;
      end
      else if IndexOfTileControl(TTileControl(Sender)) = FControlIndex then
      //else if TTileControl(Sender).ControlsCollectionIndex = FControlIndex then
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

end.
