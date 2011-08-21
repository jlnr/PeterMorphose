program PeterM;

uses
  Forms,
  Windows,
  UnitPeterM in 'UnitPeterM.pas' {FormPeterM},
  PMConst in 'PMConst.pas',
  PMObjects in 'PMObjects.pas',
  PMMaps in 'PMMaps.pas';

{$R *.RES}
{$R PML-Icon.RES}

begin
  Application.Initialize;
  Application.Title := 'Peter Morphose';
  Application.CreateForm(TFormPeterM, FormPeterM);
  Randomize;
  Application.Run;
end.
