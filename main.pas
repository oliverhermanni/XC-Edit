unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, Menus,
  ComCtrls, ExtCtrls, StdCtrls, CheckLst, Buttons, SynEdit, INIFiles, Process,
  LazFileUtils, SynHighlighterXML, options, JvRollOut, RichMemo,
  SynFacilHighlighter, SynEditTypes;

type

  { TFormMain }

  TFormMain = class(TForm)
    ImageList: TImageList;
    ImageListBookmark: TImageList;
    N5: TMenuItem;
    MenuProjectUseTestCompiler: TMenuItem;
    MenuProjectCompileAndRun: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    richOutput: TRichMemo;
    RolloutOutput: TJvRollOut;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuFileNew: TMenuItem;
    MenuFileOpen: TMenuItem;
    MenuFileSave: TMenuItem;
    MenuFileSaveAs: TMenuItem;
    MenuFileExit: TMenuItem;
    MenuEdit: TMenuItem;
    MenuEditUndo: TMenuItem;
    MenuEditRedo: TMenuItem;
    MenuEditCut: TMenuItem;
    MenuEditCopy: TMenuItem;
    MenuEditPaste: TMenuItem;
    MenuEditFind: TMenuItem;
    MenuEditReplace: TMenuItem;
    MenuEditOptions: TMenuItem;
    MenuFileClose: TMenuItem;
    MenuProjectCompile: TMenuItem;
    MenuProject: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    OpenDialog: TOpenDialog;
    PageControl2: TPageControl;
    pagesEditor: TPageControl;
    SaveDialog: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar: TStatusBar;
    TabOutput: TTabSheet;
    tabErrorWarnings: TTabSheet;
    tabProject: TTabSheet;
    ToolBar: TToolBar;
    tbNew: TToolButton;
    tbOpen: TToolButton;
    tbSave: TToolButton;
    tbRedo: TToolButton;
    tbCopy: TToolButton;
    tbPaste: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    tbUndo: TToolButton;
    tbCut: TToolButton;
    tbFind: TToolButton;
    tbReplace: TToolButton;
    ToolButton4: TToolButton;
    tbUseTestCompiler: TToolButton;
    ToolButton6: TToolButton;
    tbRun: TToolButton;
    TreeView1: TTreeView;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuFileCloseClick(Sender: TObject);
    procedure MenuEditCopyClick(Sender: TObject);
    procedure MenuEditCutClick(Sender: TObject);
    procedure MenuEditOptionsClick(Sender: TObject);
    procedure MenuEditPasteClick(Sender: TObject);
    procedure MenuEditRedoClick(Sender: TObject);
    procedure MenuEditUndoClick(Sender: TObject);
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure MenuProjectCompileAndRunClick(Sender: TObject);
    procedure MenuProjectCompileClick(Sender: TObject);
    procedure MenuProjectUseTestCompilerClick(Sender: TObject);
    procedure pagesEditorChange(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
  private
  public
    FilenameIdx: Longint;
    StrFilenames: array[0..99999] of string;
    function ActiveEditor: TSynEdit;
    function SaveEditor(WithDialog: boolean): boolean;
    procedure ReadIniFile;
    procedure SaveIniFile;
    procedure CreateNewTab;
    procedure CompileCurrentFile;
    procedure RunInEmulator;
    procedure WriteToOutputField(txt: string);
  end;

var
  FormMain: TFormMain;
  hlt : TSynFacilSyn;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.MenuFileNewClick(Sender: TObject);
begin
 CreateNewTab;
end;

procedure TFormMain.MenuFileOpenClick(Sender: TObject);
var Filename: string;
begin
  if OpenDialog.Execute then
  begin
    if ActiveEditor.Text.Length > 0 then CreateNewTab;
    Filename := OpenDialog.Filename;
    ActiveEditor.Lines.LoadFromFile(Filename);
    pagesEditor.ActivePage.Caption := ExtractFileName(Filename);
    StrFilenames[ActiveEditor.Tag] := Filename;
    StatusBar.Panels[0].Text:= StrFilenames[ActiveEditor.Tag];
  end;
end;

procedure TFormMain.MenuFileSaveAsClick(Sender: TObject);
begin
  SaveEditor(true);
end;

procedure TFormMain.MenuFileSaveClick(Sender: TObject);
begin
  SaveEditor(false);
end;

procedure TFormMain.MenuProjectCompileAndRunClick(Sender: TObject);
begin
  CompileCurrentFile;
  RunInEmulator;
end;

procedure TFormMain.MenuProjectCompileClick(Sender: TObject);
begin
  CompileCurrentFile;
end;

procedure TFormMain.MenuProjectUseTestCompilerClick(Sender: TObject);
begin
  MenuProjectUseTestCompiler.Checked := not MenuProjectUseTestCompiler.Checked;
  tbUseTestCompiler.Down := MenuProjectUseTestCompiler.Checked;
  with richOutput do
  begin
    if MenuProjectUseTestCompiler.Checked then begin
        WriteToOutputField('SWITCHED TO TEST COMPILER!');
        WriteToOutputField('');
    end else begin
      WriteToOutputField('SWITCHED TO MAIN COMPILER!');
      WriteToOutputField('');
    end;
  end;
end;

procedure TFormMain.pagesEditorChange(Sender: TObject);
begin
  StatusBar.Panels[0].Text:= StrFilenames[ActiveEditor.Tag];
end;

procedure TFormMain.SynEdit1StatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  MenuEditCut.Enabled:= ActiveEditor.SelAvail;
  MenuEditCopy.Enabled := ActiveEditor.SelAvail;
  MenuEditPaste.Enabled := ActiveEditor.CanPaste;
  MenuEditUndo.Enabled := ActiveEditor.CanUndo;
  MenuEditRedo.Enabled := ActiveEditor.CanRedo;

  tbCut.Enabled := ActiveEditor.SelAvail;
  tbCopy.Enabled := ActiveEditor.SelAvail;
  tbPaste.Enabled := ActiveEditor.CanPaste;
  tbUndo.Enabled := ActiveEditor.CanUndo;
  tbRedo.Enabled := ActiveEditor.CanRedo;
end;


procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var SaveDoc: LongInt;
begin
  CanClose := true;
  if ActiveEditor.Modified then
  begin
    CanClose := false;
    SaveDoc := Application.MessageBox('Do you want to save your latest changes?', 'Editor modified',  MB_ICONQUESTION + MB_YESNO);
    case SaveDoc of
      ID_YES:
          CanClose := SaveEditor(false);
      ID_NO:
          CanClose := true;
    end;
  end;
    SaveIniFile;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FilenameIdx:=-1;
  ReadIniFile;
  hlt := TSynFacilSyn.Create(Self);
  hlt.LoadFromFile(ExtractFilePath(Application.ExeName) + DirectorySeparator + 'synxcbasic.xml');
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  CreateNewTab;
end;

procedure TFormMain.MenuFileCloseClick(Sender: TObject);
var tab: TTabSheet;
    CanClose: Boolean;
    CloseTab: LongInt;
begin
  tab := pagesEditor.ActivePage;
  CanClose := true;
  if Assigned(tab) and (pagesEditor.Pagecount > 1) then begin
    if ActiveEditor.Modified then begin
      CloseTab := Application.MessageBox('Do you want to save your latest changes?', 'Editor modified',  MB_ICONQUESTION + MB_YESNO);
      case CloseTab of
        ID_YES:
          CanClose := false;
        ID_NO:
            CanClose := true;
      end;

    end;
    if CanClose then tab.Free;
  end;
end;

procedure TFormMain.MenuEditCopyClick(Sender: TObject);
begin
  ActiveEditor.CopyToClipboard;
end;

procedure TFormMain.MenuEditCutClick(Sender: TObject);
begin
  ActiveEditor.CutToClipboard;
end;

procedure TFormMain.MenuEditOptionsClick(Sender: TObject);
begin
  FormOptions.Show;
end;

procedure TFormMain.MenuEditPasteClick(Sender: TObject);
begin
  ActiveEditor.PasteFromClipboard;
end;

procedure TFormMain.MenuEditRedoClick(Sender: TObject);
begin
  ActiveEditor.Redo
end;

procedure TFormMain.MenuEditUndoClick(Sender: TObject);
begin
 ActiveEditor.Undo
end;

function TFormMain.SaveEditor(WithDialog: boolean): boolean;
var Filename : string;
begin
  Filename := StrFilenames[ActiveEditor.Tag];
  if Filename = '' then WithDialog := true;
  if WithDialog then
  begin
    If SaveDialog.Execute = false then exit(false);
    StrFilenames[ActiveEditor.Tag] := SaveDialog.Filename;
    pagesEditor.ActivePage.Caption:= ExtractFilename(SaveDialog.Filename);
  end;
  ActiveEditor.Lines.SaveToFile(Filename);
  ActiveEditor.Modified := false;
  result := true;
  StatusBar.Panels[0].Text:= StrFilenames[ActiveEditor.Tag];
end;

procedure TFormMain.ReadIniFile;
var Ini : TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  with FormMain do begin
    Top := Ini.ReadInteger('FORM', 'Top', 0);
    Left := Ini.ReadInteger('FORM', 'Left', 0);
    Width := Ini.ReadInteger('FORM', 'Width', 640);
    Height := Ini.ReadInteger('FORM', 'Height', 480);
    if Ini.ReadBool('FORM', 'Maximized', true) = true then
      WindowState := wsMaximized
    else
      WindowState := wsNormal;
  end;
  Ini.Free;
end;

procedure TFormMain.SaveIniFile;
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  with Ini do begin
    WriteInteger('FORM', 'Top', FormMain.Top);
    WriteInteger('FORM', 'Left', FormMain.Left);
    WriteInteger('FORM', 'Width', FormMain.Width);
    WriteInteger('FORM', 'Height', FormMain.Height);
    WriteBool('FORM', 'Maximized', FormMain.WindowState = wsMaximized);
  end;
end;

function TFormMain.ActiveEditor:TSynEdit;
begin
 result := TSynEdit(pagesEditor.ActivePage.FindComponent('Editor'));
end;

procedure TFormMain.CreateNewTab;
var tab: TTabSheet;
    Editor: TSynEdit;
begin
  Inc(FilenameIdx);
  tab := pagesEditor.AddTabSheet;
  with tab do begin
    Caption := 'Empty';
  end;
  Editor := TSynEdit.Create(tab);
  with Editor do begin
    Name := 'Editor';
    Align := alClient;
    Lines.Clear;
    Font.Name:= 'Courier New';
    Parent := tab;
    Tag := FilenameIdx;
    Highlighter := hlt;
    Editor.OnStatusChange := @SynEdit1StatusChange;
  end;
  pagesEditor.ActivePage := tab;
  ActiveEditor.SetFocus;
end;

procedure TFormMain.CompileCurrentFile;
var Run: TProcess;
    Ini : TIniFile;
    AStringList : TStringList;
    Compiler, SourceToCompile, DestFilename: String;
begin
  AStringList := TStringList.Create;
  Ini := TIniFile.Create(GetAppConfigFile(false));
  if MenuProjectUseTestCompiler.Checked then
    Compiler := Ini.ReadString('XCBASIC', 'TestCompiler','')
  else
    Compiler := Ini.ReadString('XCBASIC', 'MainCompiler','');
  If Compiler = '' then
  begin
    WriteToOutputField('Please select at least one compiler in the options dialog!');
    exit;
  end;
  SourceToCompile := StrFilenames[ActiveEditor.Tag];
  DestFilename := ExtractFileNameWithoutExt(SourceToCompile) + '.prg';
  WriteToOutputField('*** Compile process started ***');
  Run := TProcess.Create(nil);
  with Run do begin
    CurrentDirectory:= ExtractFilePath(Compiler);
    Executable := Compiler;
    Parameters.Add(SourceToCompile);
    Parameters.Add(DestFilename);
    Options := Run.Options + [poWaitOnExit, poUsePipes];
    Execute;
  end;
  AStringList.LoadFromStream(Run.Output);
  WriteToOutputField(AStringList.Text);
  AStringList.LoadFromStream(Run.Stderr);
  WriteToOutputField(AStringList.Text);
  Ini.Free;
  Run.Free;
end;

procedure TFormMain.RunInEmulator;
var Run: TProcess;
    Ini : TIniFile;
    AStringList : TStringList;
    Emulator, DestFilename: String;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  AStringList := TStringList.Create;
  Emulator := Ini.ReadString('Emulator', 'Location','');
  If Emulator = '' then
  begin
    WriteToOutputField('Please setup Emulator first!');
    exit;
  end;
  DestFilename := ExtractFileNameWithoutExt(StrFilenames[ActiveEditor.Tag]) + '.prg';

  WriteToOutputField('Booting emulator...');
  Run := TProcess.Create(nil);
  with Run do begin
    CurrentDirectory:= ExtractFilePath(DestFilename);
    Executable := Emulator;
    Parameters.Add(DestFilename);
    Options := Run.Options + [poWaitOnExit, poUsePipes];
    Execute;
  end;
  Ini.Free;
  Run.Free;
end;

procedure TFormMain.WriteToOutputField(txt: string);
begin
  richOutput.Lines.Add(txt);
end;

end.
