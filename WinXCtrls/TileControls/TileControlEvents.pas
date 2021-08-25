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
    FOwner: TWinControl;
  protected
    property Owner: TWinControl read FOwner;
  public
    constructor Create(const AOwner: TWinControl);
    destructor Destroy; override;
    //
    procedure ControlClick(Ctrl: TControl);
    procedure ControlDblClick(Ctrl: TControl);
    //
    procedure ControlMouseDown(Ctrl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseEnter(Ctrl: TControl);
    procedure ControlMouseLeave(Ctrl: TControl);
    procedure ControlMouseMove(Ctrl: TControl; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Ctrl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    //
    procedure ControlPaint(Ctrl: TControl; TargetCanvas: TCanvas; TargetRect: TRect);
  end;

implementation

uses
  TileBox,
  TileControl;

type
  TTileBoxAccess = class(TTileBox);

{ TTileControlEvents }

constructor TTileControlEvents.Create(const AOwner: TWinControl);
begin
  FOwner:=AOwner;
end;

destructor TTileControlEvents.Destroy;
begin
  FOwner:=Nil;
  inherited;
end;

procedure TTileControlEvents.ControlClick(Ctrl: TControl);
var
  Tile: TTileControl;
begin
  Tile:=TTileControl(Ctrl);

  if Tile = Nil then
    Exit;

  TTileBoxAccess(Owner).MakeVisible(Tile.BoundsRect);

  if Owner.TabStop and not Owner.Focused then
    Owner.SetFocus;

//  ActiveControl:=TTileControl(Sender);
//  TileControlIndex:=IndexOfTileControl(TTileControl(Ctrl));
  TTileBoxAccess(Owner).TileControlIndex:=Tile.ControlsCollectionIndex;
  TTileBoxAccess(Owner).UpdateControls(True);
  TTileBoxAccess(Owner).DoClick;
end;

procedure TTileControlEvents.ControlDblClick(Ctrl: TControl);
var
  Tile: TTileControl;
begin
  Tile:=TTileControl(Ctrl);

  if Tile = Nil then
    Exit;

  TTileBoxAccess(Owner).MakeVisible(Tile.BoundsRect);

  if Owner.TabStop and not Owner.Focused then
    Owner.SetFocus;

//  ActiveControl:=TTileControl(Sender);
  //TileControlIndex:=IndexOfTileControl(TTileControl(Sender));
  TTileBoxAccess(Owner).TileControlIndex:=Tile.ControlsCollectionIndex;
  TTileBoxAccess(Owner).UpdateControls(True);
  TTileBoxAccess(Owner).DoDblClick;
end;

procedure TTileControlEvents.ControlMouseDown(Ctrl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  Tile:=TTileControl(Ctrl);

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
      //TileControlIndex:=TTileControl(ActiveControl).ControlsCollectionIndex;
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
      //TileControlIndex:=TTileControl(ActiveControl).ControlsCollectionIndex;
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

procedure TTileControlEvents.ControlMouseEnter(Ctrl: TControl);
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

procedure TTileControlEvents.ControlMouseLeave(Ctrl: TControl);
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

procedure TTileControlEvents.ControlMouseMove(Ctrl: TControl; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TTileControlEvents.ControlMouseUp(Ctrl: TControl; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tile: TTileControl;
  PopupPoint: TPoint;
begin
  Tile:=TTileControl(Sender);

  if (Tile = Nil) or Tile.InDragMode then
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
      //TileControlIndex:=TTileControl(ActiveControl).ControlsCollectionIndex;
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
      //TileControlIndex:=TTileControl(ActiveControl).ControlsCollectionIndex;
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

procedure TTileControlEvents.ControlPaint(Ctrl: TControl; TargetCanvas: TCanvas; TargetRect: TRect);
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
