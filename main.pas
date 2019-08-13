unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, Menus,
  ComCtrls, ExtCtrls, StdCtrls, SynEdit, INIFiles, Process, LazFileUtils,
  SynHighlighterXML, options, JvRollOut, RichMemo, SynFacilHighlighter;

type

  { TFormMain }

  TFormMain = class(TForm)
    ImageList: TImageList;
    ImageListBookmark: TImageList;
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
    MenuEditClose: TMenuItem;
    MenuProjectRun: TMenuItem;
    MenuProject: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    OpenDialog: TOpenDialog;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    pagesEditor: TPageControl;
    SaveDialog: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar: TStatusBar;
    TabOutput: TTabSheet;
    tabErrorWarnings: TTabSheet;
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
    ToolButton6: TToolButton;
    tbRun: TToolButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuEditCutDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure MenuEditOptionsClick(Sender: TObject);
    procedure MenuEditRedoClick(Sender: TObject);
    procedure MenuEditUndoClick(Sender: TObject);
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure MenuProjectClick(Sender: TObject);
    procedure MenuProjectRunClick(Sender: TObject);
    procedure pagesEditorChange(Sender: TObject);
    procedure tabsEditorTabClick(Sender: TObject);
    procedure tbRunClick(Sender: TObject);
  private
  public
    FilenameIdx: Longint;
    StrFilenames: array[0..99999] of string;
    function ActiveEditor: TSynEdit;
    function SaveEditor(WithDialog: boolean): boolean;
    procedure ReadIniFile;
    procedure SaveIniFile;
    procedure CreateNewTab;
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
    if ActiveEditor.Modified then CreateNewTab;
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

procedure TFormMain.MenuProjectClick(Sender: TObject);
begin

end;

procedure TFormMain.MenuProjectRunClick(Sender: TObject);
var Run: TProcess;
    Ini : TIniFile;
    AStringList : TStringList;
    Compiler, SourceToCompile, DestFilename: String;
begin
  AStringList := TStringList.Create;
  Ini := TIniFile.Create(GetAppConfigFile(false));
  Compiler := Ini.ReadString('XCBASIC', 'MainCompiler','');
//  Compiler := 'C:\Windows\System32\calc.exe';
  SourceToCompile := StrFilenames[ActiveEditor.Tag];
  DestFilename := ExtractFileNameWithoutExt(SourceToCompile) + '.prg';
  richOutput.Lines.Add('*** Compile process started ***');
  Run := TProcess.Create(nil);
  Run.CurrentDirectory:= ExtractFilePath(Compiler);
  Run.Executable := Compiler;
  Run.Parameters.Add(SourceToCompile);
  Run.Parameters.Add(DestFilename);
  Run.Options := Run.Options + [poWaitOnExit, poUsePipes];
  Run.Execute;
  AStringList.LoadFromStream(Run.Output);
  richOutput.Lines.AddStrings(AStringList);
  AStringList.LoadFromStream(Run.Stderr);
  richOutput.Lines.AddStrings(AStringList);
  Run.Free;
end;

procedure TFormMain.pagesEditorChange(Sender: TObject);
begin
  StatusBar.Panels[0].Text:= StrFilenames[ActiveEditor.Tag];
end;

procedure TFormMain.tabsEditorTabClick(Sender: TObject);
begin

end;

procedure TFormMain.tbRunClick(Sender: TObject);
begin

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

procedure TFormMain.MenuEditCutDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
begin
  MenuEditCut.Enabled:= ActiveEditor.SelAvail;
end;

procedure TFormMain.MenuEditOptionsClick(Sender: TObject);
begin
  FormOptions.Show;
end;

procedure TFormMain.MenuEditRedoClick(Sender: TObject);
begin
//  ActiveEditor.Redo
end;

procedure TFormMain.MenuEditUndoClick(Sender: TObject);
begin
// ActiveEditor.Undo
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
    Align := alClient;
    Lines.Clear;
    Font.Name:= 'Courier New';
    Parent := tab;
    Name := 'Editor';
    Tag := FilenameIdx;
    Highlighter := hlt;
  end;
  pagesEditor.ActivePage := tab;
  ActiveEditor.SetFocus;
end;

end.
