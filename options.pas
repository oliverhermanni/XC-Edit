unit options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, ComCtrls, INIFiles;

type

  { TFormOptions }

  TFormOptions = class(TForm)
    ButtonCancel: TButton;
    ButtonOk: TButton;
    EditEmulatorParams: TEdit;
    fneEmulatorLocation: TFileNameEdit;
    fneMainCompiler: TFileNameEdit;
    fneTestCompiler: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListBoxTabs: TListBox;
    PageControl: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBoxTabsClick(Sender: TObject);
  private

  public
    procedure ReadIniFile;
    procedure SaveIniFile;
  end;

var
  FormOptions: TFormOptions;

implementation

{$R *.lfm}

{ TFormOptions }

procedure TFormOptions.FormShow(Sender: TObject);
var t: integer;
begin
  ListBoxTabs.Items.Clear;
  for t := 0 to PageControl.PageCount-1 do
  begin
    ListBoxTabs.AddItem(PageControl.Pages[t].Caption, PageControl.Pages[t]);
  end;
  ListBoxTabs.ItemIndex:=0;
  PageControl.PageIndex:=0;
  PageControl.ShowTabs := false;
  ReadIniFile;
end;

procedure TFormOptions.ButtonCancelClick(Sender: TObject);
begin
  FormOptions.Close;
end;

procedure TFormOptions.ButtonOkClick(Sender: TObject);
begin
  SaveIniFile;
  FormOptions.Close;
end;

procedure TFormOptions.ListBoxTabsClick(Sender: TObject);
begin
  PageControl.PageIndex:= ListBoxTabs.ItemIndex;
end;

procedure TFormOptions.ReadIniFile;
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  with FormOptions do begin
    // Compiler settings
    fneMainCompiler.FileName:= Ini.ReadString('XCBASIC', 'MainCompiler', '');
    fneTestCompiler.FileName:= Ini.ReadString('XCBASIC', 'TestCompiler', '');
    // Emulator settings
    fneEmulatorLocation.Filename:= Ini.ReadString('Emulator', 'Location', '');
    EditEmulatorParams.Text:= Ini.ReadString('Emulator','Params', '%prg');
  end;
end;

procedure TFormOptions.SaveIniFile;
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  With Ini do begin
    // Compiler settings
    WriteString('XCBASIC', 'MainCompiler', FormOptions.fneMainCompiler.FileName);
    WriteString('XCBASIC', 'TestCompiler', FormOptions.fneTestCompiler.FileName);
    // Emulator settings
    WriteString('Emulator', 'Location', FormOptions.fneEmulatorLocation.Filename);
    WriteString('Emulator', 'Params', FormOptions.EditEmulatorParams.Text);
  end;
end;

end.

