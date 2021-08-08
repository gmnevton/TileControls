program TilesDemo;

uses
  madExcept,
  madLinkDisAsm,
  madListModules,
  Forms,
  uTilesDemoMain in 'uTilesDemoMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
