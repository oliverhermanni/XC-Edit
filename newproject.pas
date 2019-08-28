unit newproject;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ExtCtrls, xcprojectfile;

type

  { TFormNewProject }

  TFormNewProject = class(TForm)
    ButtonCancel: TButton;
    ButtonOk: TButton;
    EditProjectLocation: TDirectoryEdit;
    EditExecutable: TEdit;
    EditAuthor: TEdit;
    EditProjectName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MemoComment: TMemo;
    Panel1: TPanel;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
  private

  public

  end;

var
  FormNewProject: TFormNewProject;

implementation

{$R *.lfm}

{ TFormNewProject }

procedure TFormNewProject.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormNewProject.ButtonOkClick(Sender: TObject);
var
  xcp: TXCProjectFile;
begin
  xcp := TXCProjectFile.Create;
  xcp.CreateProject(
    EditProjectName.Text,
    EditAuthor.Text,
    MemoComment.Lines.Text,
    EditProjectLocation.Text,
    EditExecutable.Text
  );
  Close;
end;

end.

