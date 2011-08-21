{ Edited by Julian Raschke }

unit FileType;

interface
uses
  Registry, Windows, ShlObj, SysUtils, Dialogs;

type TFileType = class
  private
    FFileExtension: string;
    FFileIcon: string;
    FFileDescription: string;
    FOpenWith: string;
    FOpenActionDescription: string;
    FOpenAction: string;
    FOpenParams: string;
    procedure SetFileExtension(const Value: string);

    function AllValuesSet: Boolean;
  public
    function Register: Boolean;
    function UnRegister: Boolean;

    property FileExtension: string read FFileExtension write SetFileExtension;
    property FileIcon: string read FFileIcon write FFileIcon;
    property FileDescription: string read FFileDescription write FFileDescription;
    property OpenAction: string read FOpenAction write FOpenAction;
    property OpenActionDescription: string read FOpenActionDescription write FOpenActionDescription;
    property OpenWith: string read FOpenWith write FOpenWith;
    property OpenParams: string read FOpenParams write FOpenParams;
end;

implementation

{ TFileType }
// *****************************************************************************
function TFileType.AllValuesSet: Boolean;
begin
  if FFileExtension = '' then
    raise Exception.Create('TFileType.FileExtension has not been set');

  if FFileDescription = '' then
    FFileDescription := Copy(FFileExtension, 2, Length(FFileExtension)) + ' File';

  if FOpenWith = '' then
    raise Exception.Create('TFileType.OpenWith has not been set');

  if FOpenAction = '' then
    FOpenAction := 'Open';

  if FOpenActionDescription = '' then
    FOpenActionDescription := '&' + FOpenAction;

  if FOpenParams = '' then
    FOpenParams := '%1';

  Result := True;
end;
// *****************************************************************************
function TFileType.Register: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;

  if not AllValuesSet then
    Exit;

  Reg := TRegistry.Create;

  try
    // Set the root key to HKEY_CLASSES_ROOT
    Reg.RootKey := HKEY_CLASSES_ROOT;

    // Now open the key, with the possibility to create
    // the key if it doesn't exist.
    Reg.OpenKey(FFileExtension, True);

    // Write my file type to it.
    // This adds HKEY_CLASSES_ROOT\.abc\(Default) = 'Project1.FileType'
    Reg.WriteString('', FFileDescription);
    Reg.CloseKey;

    // Now create an association for that file type
    Reg.OpenKey(FFileDescription, True);

    // This adds HKEY_CLASSES_ROOT\Project1.FileType\(Default)
    //   = 'Project1 File'
    // This is what you see in the file type description for
    // the a file's properties.
    Reg.WriteString('', FFileDescription);
    Reg.CloseKey;

    // Now write the default icon for my file type
    // This adds HKEY_CLASSES_ROOT\Project1.FileType\DefaultIcon
    //  \(Default) = 'Application Dir\Project1.exe,0'
    Reg.OpenKey(FFileDescription + '\DefaultIcon', True);
    Reg.WriteString('', FFileIcon);
    Reg.CloseKey;

    // Now write the open action in explorer
    Reg.OpenKey(FFileDescription + '\Shell\' + FOpenAction, True);
    Reg.WriteString('', FOpenActionDescription);
    Reg.CloseKey;

    // Write what application to open it with
    // This adds HKEY_CLASSES_ROOT\Project1.FileType\Shell\Open\Command
    // Your application must scan the command line parameters
    // to see what file was passed to it.
    Reg.OpenKey(FFileDescription + '\Shell\' + FOpenAction + '\Command', True);
    Reg.WriteString('', '"' + FOpenWith + '" "' + FOpenParams + '"');
    Reg.CloseKey;

    // Finally, we want the Windows Explorer to realize we added
    // our file type by using the SHChangeNotify API.
    SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
  finally
    Reg.Free;
  end;

  Result := True;
end;
// *****************************************************************************
procedure TFileType.SetFileExtension(const Value: string);
begin
  if not (Value[1] = '.') then
    FFileExtension := '.' + Value
  else
    FFileExtension := Value;
end;
// *****************************************************************************
function TFileType.UnRegister: Boolean;
var
  reg: TRegistry;
  sClassName: string;
begin
  reg := TRegistry.Create;

  if FFileExtension = '' then
    raise Exception.Create('TFileType.FileExtension property has not been set');

  try
    reg.RootKey := HKEY_CLASSES_ROOT;

    if not reg.KeyExists(FFileExtension) then
    begin
      Result := True;
      Exit;
    end;

    reg.OpenKey(FFileExtension, True);
    sClassName := reg.ReadString('');
    reg.CloseKey;
    reg.DeleteKey(FFileExtension);

    if not reg.KeyExists(sClassName) then
    begin
      Result := True;
      Exit;
    end;

    reg.DeleteKey(sClassName);
  finally
    reg.Free;
  end;

  Result := True;
end;
// *****************************************************************************
end.
