unit xcsynedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, StdCtrls, SysUtils, Controls, SynEdit, SynEditTypes, INIFiles;

type
  TXCSynEdit = class(TSynEdit)
  private
    sFilename: string;
  public
    constructor Create(theComponent: TComponent); override;
    property Filename: string read sFilename write sFilename;
  end;


implementation

constructor TXCSynEdit.Create(theComponent: TComponent);
var Ini : TIniFile;
begin
  inherited Create(theComponent);
  Name := 'Editor';
  Align := alClient;
  Lines.Clear;
  Keystrokes.Delete(45);
  RightEdge := 0;
  Options := Options + [eoTabIndent];
  Options := Options - [eoSmartTabs];
  ScrollBars := ssAutoBoth;
  Ini := TIniFile.Create(GetAppConfigFile(false));
  with Ini do begin
    Font.Name := ReadString('Editor', 'Font', Font.Name);
    Font.Size := ReadInteger('Editor', 'Size', Font.Size);
    TabWidth := ReadInteger('Editor', 'TabWidth', TabWidth);
  end;
  Ini.Free;
end;

end.

