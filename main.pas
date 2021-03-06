unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, Menus,
  ComCtrls, ExtCtrls, StdCtrls, Buttons, xcsynedit, INIFiles, Process, CommCtrl,
  LazFileUtils, SynHighlighterXML, options, JvRollOut, RichMemo,
  SynFacilHighlighter, SynEditTypes, about, LCLIntf, Types, XCSynHighlighter;

type

  { TFormMain }

  TFormMain = class(TForm)
    FindDialog: TFindDialog;
    ImageList: TImageList;
    ImageListBookmark: TImageList;
    MenuHelp: TMenuItem;
    MenuHelpXCBasic: TMenuItem;
    MenuHelpAbout: TMenuItem;
    MenuFileNew: TMenuItem;
    MenuHelpHomepage: TMenuItem;
    popupOutputCopy: TMenuItem;
    N8: TMenuItem;
    MenuProject: TMenuItem;
    N7: TMenuItem;
    N6: TMenuItem;
    popupOutputSaveToFile: TMenuItem;
    popupOutputClear: TMenuItem;
    N5: TMenuItem;
    MenuProjectUseTestCompiler: TMenuItem;
    MenuProjectCompileAndRun: TMenuItem;
    popupOutput: TPopupMenu;
    ReplaceDialog: TReplaceDialog;
    richOutput: TRichMemo;
    RolloutOutput: TJvRollOut;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
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
    MenuBuild: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    OpenDialog: TOpenDialog;
    PageControl2: TPageControl;
    pagesEditor: TPageControl;
    SaveDialog: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar: TStatusBar;
    TabOutput: TTabSheet;
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
    procedure FindDialogFind(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuEditFindClick(Sender: TObject);
    procedure MenuEditReplaceClick(Sender: TObject);
    procedure MenuFileCloseClick(Sender: TObject);
    procedure MenuEditCopyClick(Sender: TObject);
    procedure MenuEditCutClick(Sender: TObject);
    procedure MenuEditOptionsClick(Sender: TObject);
    procedure MenuEditPasteClick(Sender: TObject);
    procedure MenuEditRedoClick(Sender: TObject);
    procedure MenuEditUndoClick(Sender: TObject);
    procedure MenuFileExitClick(Sender: TObject);
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure MenuHelpAboutClick(Sender: TObject);
    procedure MenuHelpHomepageClick(Sender: TObject);
    procedure MenuHelpXCBasicClick(Sender: TObject);
    procedure MenuProjectCompileAndRunClick(Sender: TObject);
    procedure MenuProjectCompileClick(Sender: TObject);
    procedure MenuProjectUseTestCompilerClick(Sender: TObject);
    procedure pagesEditorChange(Sender: TObject);
    procedure pagesEditorGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure pagesEditorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure popupOutputClearClick(Sender: TObject);
    procedure popupOutputCopyClick(Sender: TObject);
    procedure popupOutputSaveToFileClick(Sender: TObject);
    procedure ReplaceDialogFind(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
    procedure richOutputSelectionChange(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
  private
  public
    var ProcessEmulator: TProcess;
    var CloseEmulator: Boolean;
    function ActiveEditor: TXCSynEdit;
    function SaveEditor(WithDialog: boolean): boolean;
    procedure ReadIniFile;
    procedure SaveIniFile;
    procedure CreateNewTab;
    procedure CloseTab(idx: integer = -1);
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

procedure TFormMain.MenuFileOpenClick(Sender: TObject);
var
  i : integer;
  FName : string;
begin
  if OpenDialog.Execute then
  begin
    for i := 0 to OpenDialog.Files.Count - 1 do begin
      if ActiveEditor.Text.Length > 0 then CreateNewTab;
      FName := OpenDialog.Files[i];
      ActiveEditor.Lines.LoadFromFile(FName);
      pagesEditor.ActivePage.Caption := ExtractFileName(FName);
      ActiveEditor.Filename := FName;
    end;
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
  FormAbout.ShowModal;
end;

procedure TFormMain.MenuHelpHomepageClick(Sender: TObject);
begin
      OpenURL('https://hamrath.itch.io/xcedit');
end;

procedure TFormMain.MenuHelpXCBasicClick(Sender: TObject);
begin
    OpenURL('https://xc-basic.net/doku.php');
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

procedure TFormMain.pagesEditorGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin

end;

procedure TFormMain.pagesEditorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tabindex: Integer;
begin
  if Button = mbMiddle then begin
    tabindex := pagesEditor.IndexOfTabAt(X, Y);
    if tabindex > -1 then begin
      CloseTab(tabindex);
    end;
  end;
end;

procedure TFormMain.popupOutputClearClick(Sender: TObject);
begin
  richOutput.Lines.Clear;
end;

procedure TFormMain.popupOutputCopyClick(Sender: TObject);
begin
  richOutput.CopyToClipboard;
end;

procedure TFormMain.popupOutputSaveToFileClick(Sender: TObject);
begin
  SaveDialog.Filter:= 'Text (*.txt)|*.txt|All files (*.*)|*.*';
  If SaveDialog.Execute then begin
    richOutput.Lines.SaveToFile(SaveDialog.Filename);
  end;
end;

procedure TFormMain.ReplaceDialogFind(Sender: TObject);
var
  SearchOptions: TSynSearchOptions;
begin
  with Sender as TReplaceDialog do begin
    SearchOptions := [];
    if frMatchCase in Options then
      Include(SearchOptions, ssoMatchCase);
    if frWholeWord in Options then
      Include(SearchOptions, ssoWholeWord);
    if frDown in Options then
    else
      Include(SearchOptions, ssoBackwards);
    if frEntireScope in Options then
      Include(SearchOptions, ssoEntireScope);
    ActiveEditor.SearchReplace(FindText, ReplaceText, SearchOptions);
  end;
end;

procedure TFormMain.ReplaceDialogReplace(Sender: TObject);
var
  SearchOptions: TSynSearchOptions;
begin
  with Sender as TReplaceDialog do begin
    SearchOptions := [];
    if frMatchCase in Options then
      Include(SearchOptions, ssoMatchCase);
    if frWholeWord in Options then
      Include(SearchOptions, ssoWholeWord);
    if frDown in Options then
    else
      Include(SearchOptions, ssoBackwards);
    if frReplace in Options then
      Include(SearchOptions, ssoReplace);
    if frReplaceAll in Options then
      Include(SearchOptions, ssoReplaceAll);
    if frEntireScope in Options then
      Include(SearchOptions, ssoEntireScope);
    ActiveEditor.SearchReplace(FindText, ReplaceText, SearchOptions);
  end;
end;

procedure TFormMain.richOutputSelectionChange(Sender: TObject);
begin
  popupOutputCopy.Enabled:= richOutput.SelLength > 0;
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
var
  SaveDoc: LongInt;
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
var
  SearchOptions: TSynSearchOptions;
begin
  with Sender as TFindDialog do begin
    SearchOptions := [];
    if frMatchCase in Options then
      Include(SearchOptions, ssoMatchCase);
    if frWholeWord in Options then
      Include(SearchOptions, ssoWholeWord);
    if frDown in Options then
    else
      Include(SearchOptions, ssoBackwards);
    ActiveEditor.SearchReplace(FindText, '', SearchOptions);
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

procedure TFormMain.MenuEditReplaceClick(Sender: TObject);
begin
  ReplaceDialog.Execute
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
  FormOptions.ActiveEditor := ActiveEditor;
  FormOptions.ShowModal;
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

procedure TFormMain.MenuFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MenuFileNewClick(Sender: TObject);
begin
  CreateNewTab;
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
var
  Ini : TIniFile;
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
  CloseEmulator:= Ini.ReadBool('Emulator', 'CloseEmulator', true);
  Ini.Free;
end;

procedure TFormMain.SaveIniFile;
var
  Ini: TIniFile;
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
var
  tab: TTabSheet;
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
var
  Run: TProcess;
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
var
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

  if Assigned(ProcessEmulator) and CloseEmulator then begin
    ProcessEmulator.Terminate(0);
    WriteToOutputField('Stopped emulator process...');
  end;
  ProcessEmulator := TProcess.Create(nil);

  with ProcessEmulator do begin
    CurrentDirectory:= ExtractFilePath(DestFilename);
    Executable := Emulator;
    Parameters.Add(DestFilename);
    Options := Options + [poUsePipes];
    WriteToOutputField('Booting emulator...');
    Execute;
  end;
  Ini.Free;
end;

procedure TFormMain.WriteToOutputField(txt: string);
begin
  richOutput.Lines.Add(txt);
end;

procedure TFormMain.CloseTab(idx: integer = -1);
var
  tab: TTabSheet;
  CanClose: Boolean;
  msgReply: LongInt;
begin
  if idx > -1 then begin
    pagesEditor.ActivePage := pagesEditor.Pages[idx];
  end;
  tab := pagesEditor.ActivePage;

  CanClose := true;
  if Assigned(tab) then begin
    if ActiveEditor.Modified then begin
      msgReply := Application.MessageBox('Do you want to save your latest changes?', 'Editor modified',  MB_ICONQUESTION + MB_YESNO);
      case msgReply of
        ID_YES:
          CanClose := false;
        ID_NO:
            CanClose := true;
      end;
    end;
    if CanClose then begin
      if pagesEditor.PageCount = 1 then CreateNewTab;
      tab.Free;
    end;
  end;
end;

end.
