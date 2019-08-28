unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, Menus,
  ComCtrls, ExtCtrls, StdCtrls, Buttons, xcsynedit, INIFiles, Process,
  LazFileUtils, SynHighlighterXML, options, JvRollOut, JvGroupHeader, RichMemo,
  SynFacilHighlighter, SynEditTypes, newproject, about;

type

  { TFormMain }

  TFormMain = class(TForm)
    FindDialog: TFindDialog;
    ImageList: TImageList;
    ImageListBookmark: TImageList;
    MenuFileNewProject: TMenuItem;
    MenuHelp: TMenuItem;
    MenuItem1: TMenuItem;
    MenuHelpAbout: TMenuItem;
    N7: TMenuItem;
    N6: TMenuItem;
    popupOutputSaveToFile: TMenuItem;
    popupOutputClear: TMenuItem;
    N5: TMenuItem;
    MenuProjectUseTestCompiler: TMenuItem;
    MenuProjectCompileAndRun: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    popupOutput: TPopupMenu;
    richOutput: TRichMemo;
    RolloutOutput: TJvRollOut;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuFileNewFile: TMenuItem;
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
    tbCompileAndRun: TToolButton;
    tbUseTestCompiler: TToolButton;
    ToolButton6: TToolButton;
    tbCompile: TToolButton;
    TreeView1: TTreeView;
    procedure FindDialogFind(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuEditFindClick(Sender: TObject);
    procedure MenuFileClick(Sender: TObject);
    procedure MenuFileCloseClick(Sender: TObject);
    procedure MenuEditCopyClick(Sender: TObject);
    procedure MenuEditCutClick(Sender: TObject);
    procedure MenuEditOptionsClick(Sender: TObject);
    procedure MenuEditPasteClick(Sender: TObject);
    procedure MenuEditRedoClick(Sender: TObject);
    procedure MenuEditUndoClick(Sender: TObject);
    procedure MenuFileNewFileClick(Sender: TObject);
    procedure MenuFileNewProjectClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure MenuHelpAboutClick(Sender: TObject);
    procedure MenuProjectCompileAndRunClick(Sender: TObject);
    procedure MenuProjectCompileClick(Sender: TObject);
    procedure MenuProjectUseTestCompilerClick(Sender: TObject);
    procedure pagesEditorChange(Sender: TObject);
    procedure pagesEditorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure popupOutputClearClick(Sender: TObject);
    procedure popupOutputSaveToFileClick(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
  private
  public
    function ActiveEditor: TXCSynEdit;
    function SaveEditor(WithDialog: boolean): boolean;
    procedure ReadIniFile;
    procedure SaveIniFile;
    procedure CreateNewTab;
    procedure CloseTab;
    function CompileCurrentFile: boolean;
    procedure RunInEmulator;
    procedure WriteToOutputField(txt: string);
  end;

var
  FormMain: TFormMain;
  hlt : TSynFacilSyn;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.MenuFileNewFileClick(Sender: TObject);
begin
 CreateNewTab;
end;

procedure TFormMain.MenuFileNewProjectClick(Sender: TObject);
begin
  FormNewProject.Show;
end;

procedure TFormMain.MenuFileOpenClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    if ActiveEditor.Text.Length > 0 then CreateNewTab;
    ActiveEditor.Lines.LoadFromFile(OpenDialog.Filename);
    pagesEditor.ActivePage.Caption := ExtractFileName(OpenDialog.Filename);
    ActiveEditor.Filename := OpenDialog.Filename;
    StatusBar.Panels[0].Text:= OpenDialog.Filename;
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

procedure TFormMain.MenuHelpAboutClick(Sender: TObject);
begin
  FormAbout.Show;
end;

procedure TFormMain.MenuProjectCompileAndRunClick(Sender: TObject);
begin
  if CompileCurrentFile then
    RunInEmulator
  else
    WriteToOutputField('Compile was not successful, could not run emulator.');
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
  StatusBar.Panels[0].Text:= ActiveEditor.Filename;
end;

procedure TFormMain.pagesEditorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbMiddle then CloseTab;
end;

procedure TFormMain.popupOutputClearClick(Sender: TObject);
begin
  richOutput.Lines.Clear;
end;

procedure TFormMain.popupOutputSaveToFileClick(Sender: TObject);
begin
  SaveDialog.Filter:= 'Text (*.txt)|*.txt|All files (*.*)|*.*';
  If SaveDialog.Execute then begin
    richOutput.Lines.SaveToFile(SaveDialog.Filename);
  end;
end;

procedure TFormMain.SynEdit1StatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
var
  CurrentFName : string;
begin
  If ActiveEditor.Filename = '' then
    CurrentFName := 'Empty'
  else
    CurrentFName := ActiveEditor.Filename;
  if ActiveEditor.Modified then
    pagesEditor.ActivePage.Caption := ExtractFileName(CurrentFName) + ' (*)'
  else
    pagesEditor.ActivePage.Caption := ExtractFileName(CurrentFName);
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

procedure TFormMain.FindDialogFind(Sender: TObject);
var k: integer;
begin
  with Sender as TFindDialog do begin
    k := Pos(FindText, ActiveEditor.Lines.Text);
    if k > 0 then begin
      ActiveEditor.Selstart := k;
      ActiveEditor.SelEnd := k + Length(FindText)
    end else
      beep();
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  ReadIniFile;
  hlt := TSynFacilSyn.Create(Self);
  hlt.LoadFromFile(ExtractFilePath(Application.ExeName) + DirectorySeparator + 'synxcbasic.xml');
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  CreateNewTab;
end;

procedure TFormMain.MenuEditFindClick(Sender: TObject);
begin
  FindDialog.Execute;
end;

procedure TFormMain.MenuFileClick(Sender: TObject);
begin

end;

procedure TFormMain.MenuFileCloseClick(Sender: TObject);
begin
  CloseTab
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
begin
  if ActiveEditor.Filename = '' then WithDialog := true;
  if WithDialog then
  begin
    SaveDialog.Filter:= 'XC=BASIC source (*.bas)|*.bas|All files (*.*)|*.*';
    If SaveDialog.Execute = false then exit(false);
    ActiveEditor.Filename := SaveDialog.Filename;
    pagesEditor.ActivePage.Caption:= ExtractFilename(SaveDialog.Filename);
  end;
  if ActiveEditor.Filename <> '' then begin
    ActiveEditor.Lines.SaveToFile(ActiveEditor.Filename);
    ActiveEditor.Modified := false;
    StatusBar.Panels[0].Text:= ActiveEditor.Filename;
    WriteToOutputField('Saved as ' + ActiveEditor.Filename);
    result := true;
  end;
end;

procedure TFormMain.ReadIniFile;
var Ini : TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  with FormMain do begin
    if Ini.ReadBool('FORM', 'Maximized', true) = true then
      WindowState := wsMaximized
    else begin
      Top := Ini.ReadInteger('FORM', 'Top', 0);
      Left := Ini.ReadInteger('FORM', 'Left', 0);
      Width := Ini.ReadInteger('FORM', 'Width', 640);
      Height := Ini.ReadInteger('FORM', 'Height', 480);
    end;
  end;
  Ini.Free;
end;

procedure TFormMain.SaveIniFile;
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  with Ini do begin
    if FormMain.WindowState = wsMaximized then
      WriteBool('FORM', 'Maximized', FormMain.WindowState = wsMaximized)
    else begin
      WriteInteger('FORM', 'Top', FormMain.Top);
      WriteInteger('FORM', 'Left', FormMain.Left);
      WriteInteger('FORM', 'Width', FormMain.Width);
      WriteInteger('FORM', 'Height', FormMain.Height);
    end;
  end;
end;

function TFormMain.ActiveEditor:TXCSynEdit;
begin
 result := TXCSynEdit(pagesEditor.ActivePage.FindComponent('Editor'));
end;

procedure TFormMain.CreateNewTab;
var tab: TTabSheet;
    Editor: TXCSynEdit;
begin
  tab := pagesEditor.AddTabSheet;
  with tab do begin
    Caption := 'Empty';
  end;
  Editor := TXCSynEdit.Create(tab);
  with Editor do begin
    Highlighter := hlt;
    Parent := tab;
    OnStatusChange := @SynEdit1StatusChange;
  end;
  pagesEditor.ActivePage := tab;
  ActiveEditor.SetFocus;
end;

function TFormMain.CompileCurrentFile:boolean;
var Run: TProcess;
    Ini : TIniFile;
    AStringList : TStringList;
    Compiler, SourceToCompile, DestFilename: String;
    compilerInfo, errorInfo: string;
begin
  // No filename defined
  if SaveEditor(ActiveEditor.Filename = '') = false then
  begin
    WriteToOutputField('Compiling aborted. Current file was not saved...');
    exit;
  end;
  AStringList := TStringList.Create;
  Ini := TIniFile.Create(GetAppConfigFile(false));
  if MenuProjectUseTestCompiler.Checked then
    Compiler := Ini.ReadString('XCBASIC', 'TestCompiler','')
  else
    Compiler := Ini.ReadString('XCBASIC', 'MainCompiler','');

  // No Compiler defined
  If Compiler = '' then
  begin
    WriteToOutputField('Please select at least one compiler in the options dialog!');
    exit;
  end;

  SourceToCompile := ActiveEditor.Filename;
  DestFilename := ExtractFileNameWithoutExt(SourceToCompile) + '.prg';
  if FileExistsUTF8(DestFilename) then DeleteFile(DestFilename);
  richOutput.Lines.Clear;
  WriteToOutputField('*** Compile process started ***');
  Run := TProcess.Create(nil);
  with Run do begin
    CurrentDirectory:= ExtractFilePath(Compiler);
    Executable := Compiler;
    Parameters.Add(SourceToCompile);
    Parameters.Add(DestFilename);
    WriteToOutputField('Compiling to: ' + DestFilename);
    Options := Run.Options + [poUsePipes];
    Execute;
  end;
  AStringList.LoadFromStream(Run.Output);
  compilerInfo := AStringList.Text;
  WriteToOutputField(compilerInfo);
  AStringList.LoadFromStream(Run.Stderr);
  errorInfo := AStringList.Text;
  WriteToOutputField(errorInfo);
  Ini.Free;
  Run.Free;
  result := FileExistsUTF8(DestFilename);
end;

procedure TFormMain.RunInEmulator;
var Run: TProcess;
    Ini : TIniFile;
    Emulator, DestFilename: String;
begin
  Ini := TIniFile.Create(GetAppConfigFile(false));
  Emulator := Ini.ReadString('Emulator', 'Location','');
  If Emulator = '' then
  begin
    WriteToOutputField('Please setup Emulator first!');
    exit;
  end;
  DestFilename := ExtractFileNameWithoutExt(ActiveEditor.Filename) + '.prg';

  WriteToOutputField('Booting emulator...');
  Run := TProcess.Create(nil);
  with Run do begin
    CurrentDirectory:= ExtractFilePath(DestFilename);
    Executable := Emulator;
    Parameters.Add(DestFilename);
    Options := Run.Options + [poUsePipes];
    Execute;
  end;
  Ini.Free;
  Run.Free;
end;

procedure TFormMain.WriteToOutputField(txt: string);
begin
  richOutput.Lines.Add(txt);
end;

procedure TFormMain.CloseTab;
var tab: TTabSheet;
    CanClose: Boolean;
    msgReply: LongInt;
begin
  tab := pagesEditor.ActivePage;
  CanClose := true;
  if Assigned(tab) and (pagesEditor.Pagecount > 1) then begin
    if ActiveEditor.Modified then begin
      msgReply := Application.MessageBox('Do you want to save your latest changes?', 'Editor modified',  MB_ICONQUESTION + MB_YESNO);
      case msgReply of
        ID_YES:
          CanClose := false;
        ID_NO:
            CanClose := true;
      end;
    end;
    if CanClose then tab.Free;
  end;
end;

end.
