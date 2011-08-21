program PeterME;

uses
  Forms,
  UnitPME in 'UnitPME.pas' {FormPeterME};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Peter Morphose Editor';
  Application.CreateForm(TFormPeterME, FormPeterME);
  Application.Run;
end.
