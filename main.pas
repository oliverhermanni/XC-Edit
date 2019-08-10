unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, Menus,
  ComCtrls, ExtCtrls, StdCtrls, SynEdit, INIFiles, options, attabs;

type

  { TFormMain }

  TFormMain = class(TForm)
    Editor: TSynEdit;
    tabsEditor: TATTabs;
    ImageList: TImageList;
    ImageListBookmark: TImageList;
    ListBox1: TListBox;
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
    N4: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    OpenDialog: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    SaveDialog: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar: TStatusBar;
    ToolBar: TToolBar;
    tbNew: TToolButton;
    tbOpen: TToolButton;
    tbSave: TToolButton;
    tbRedo: TToolButton;
    tbCopy: TToolButton;
    tbPaste: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    tbUndo: TToolButton;
    tbCut: TToolButton;
    procedure EditorChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure MenuEditCutClick(Sender: TObject);
    procedure MenuEditCutDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure MenuEditOptionsClick(Sender: TObject);
    procedure MenuEditRedoClick(Sender: TObject);
    procedure MenuEditUndoClick(Sender: TObject);
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
  private
    sFilename: string;
    procedure SetFilename(FName: string);
  public
    property Filename: string read sFilename write SetFilename;
    function SaveEditor(WithDialog: boolean): boolean;
    procedure ReadIniFile;
    procedure SaveIniFile;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.MenuFileNewClick(Sender: TObject);
var tab: TTabSheet;
    SaveDoc: LongInt;
    NewConfirmed: boolean;
    var i: integer;
begin
  i := tabsEditor.TabIndex+1;
  tabsEditor.AddTab(i, 'New file');
  tabsEditor.TabIndex:=i;
  {{
  NewConfirmed := true;
  if Editor.Modified then
  begin
    NewConfirmed := false;
    SaveDoc := Application.MessageBox('Do you want to save your latest changes?', 'Editor modified',  MB_ICONQUESTION + MB_YESNOCANCEL);
    case SaveDoc of
      ID_YES:
          NewConfirmed := SaveEditor(false);
      ID_NO:
          NewConfirmed := true;
      ID_CANCEL:
          NewConfirmed := false;
    end;
  end;
  if NewConfirmed then
  begin
    Editor.Lines.Clear;
    Editor.Modified := false;
  end;
  }}
end;

procedure TFormMain.MenuFileOpenClick(Sender: TObject);
var SaveDoc: LongInt;
    OpenConfirmed: boolean;
begin
  {{
  OpenConfirmed := true;
  if Editor.Modified then
  begin
    OpenConfirmed := false;
    SaveDoc := Application.MessageBox('Do you want to save your latest changes?', 'Editor modified',  MB_ICONQUESTION + MB_YESNOCANCEL);
    case SaveDoc of
      ID_YES:
          OpenConfirmed := SaveEditor(false);
      ID_NO:
          OpenConfirmed := true;
      ID_CANCEL:
          OpenConfirmed := false;
    end;
  end;
  if OpenConfirmed then
    if OpenDialog.Execute then
    begin
      Filename := OpenDialog.Filename;
      Editor.Lines.LoadFromFile(Filename);
    end;
    }}
end;

procedure TFormMain.MenuFileSaveAsClick(Sender: TObject);
begin
  SaveEditor(true);
end;

procedure TFormMain.MenuFileSaveClick(Sender: TObject);
begin
  SaveEditor(false);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var SaveDoc: LongInt;
begin
  {{
  CanClose := true;
  if Editor.Modified then
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
  }}
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  ReadIniFile;
end;

procedure TFormMain.MenuEditCutClick(Sender: TObject);
begin

end;

procedure TFormMain.MenuEditCutDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
begin

end;

procedure TFormMain.MenuEditOptionsClick(Sender: TObject);
begin
  FormOptions.Show;
end;

procedure TFormMain.EditorChange(Sender: TObject);
begin

end;

procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveIniFile;
end;

procedure TFormMain.MenuEditRedoClick(Sender: TObject);
begin
//  Editor.Redo;
end;

procedure TFormMain.MenuEditUndoClick(Sender: TObject);
begin
//  Editor.Undo;
end;

function TFormMain.SaveEditor(WithDialog: boolean): boolean;
begin
  {{
  if Filename = '' then WithDialog := true;
  if WithDialog then
  begin
    If SaveDialog.Execute = false then
      exit(false);
    Filename := SaveDialog.Filename;
  end;
  Editor.Lines.SaveToFile(Filename);
  Editor.Modified := false;
  result := true;
  }}
end;

procedure TFormMain.SetFilename(FName: string);
begin
  sFilename:=FName;
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

end.

