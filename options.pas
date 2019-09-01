unit options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, ComCtrls, Buttons, Spin, INIFiles, xcsynedit;

type

  { TFormOptions }

  TFormOptions = class(TForm)
    ButtonCancel: TButton;
    ButtonOk: TButton;
    EditFont: TEdit;
    EditEmulatorParams: TEdit;
    fneEmulatorLocation: TFileNameEdit;
    fneMainCompiler: TFileNameEdit;
    fneTestCompiler: TFileNameEdit;
    FontDialog1: TFontDialog;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ListBoxTabs: TListBox;
    PageControl: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    btnEditFontSettings: TSpeedButton;
    editTabWidth: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ListBoxTabsClick(Sender: TObject);
    procedure btnEditFontSettingsClick(Sender: TObject);
  private

  public
    procedure ReadIniFile;
    procedure SaveIniFile;
    const ActiveEditor: TXCSynEdit = nil;
    var FontDialogOpened: Boolean;
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
  FontDialogOpened:= false;
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

procedure TFormOptions.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  ActiveEditor.TabWidth := editTabWidth.Value;
end;

procedure TFormOptions.ListBoxTabsClick(Sender: TObject);
begin
  PageControl.PageIndex:= ListBoxTabs.ItemIndex;
end;

procedure TFormOptions.btnEditFontSettingsClick(Sender: TObject);
begin
  With FontDialog1 do begin
    Font := ActiveEditor.Font;
  end;
  if FontDialog1.Execute = true then begin
    FontDialogOpened:= true;
    EditFont.Text := FontDialog1.Font.Name + ', ' + IntToStr(FontDialog1.Font.Size) + 'pt';
    SaveIniFile;
    ActiveEditor.Font.Name := FontDialog1.Font.Name;
    ActiveEditor.Font.Size := FontDialog1.Font.Size;
  end;
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
    EditFont.Text := Ini.ReadString('Editor', 'Font', ActiveEditor.Font.Name)
      + ', '
      + IntToStr(Ini.ReadInteger('Editor', 'Font', ActiveEditor.Font.Size)) + 'pt';
    editTabWidth.Value:= Ini.ReadInteger('Editor', 'TabWidth', ActiveEditor.TabWidth);
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
    if FontDialogOpened = true then begin
      WriteString('Editor', 'Font', FontDialog1.Font.Name);
      WriteInteger('Editor', 'Size', FontDialog1.Font.Size);
    end
    else begin
      WriteString('Editor', 'Font', ActiveEditor.Font.Name);
      WriteInteger('Editor', 'Size', ActiveEditor.Font.Size);
    end;
    WriteInteger('Editor', 'TabWidth', editTabWidth.Value);
  end;
end;

end.

