unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, fileinfo, LCLIntf;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LabelVersion: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }

procedure TFormAbout.Button1Click(Sender: TObject);
begin
  Close
end;

procedure TFormAbout.FormShow(Sender: TObject);
var
  FileVerInfo: TFileVersionInfo;
begin
  FileVerInfo:=TFileVersionInfo.Create(nil);
  FileVerInfo.ReadFileInfo;
  LabelVersion.Caption := FileVerInfo.VersionStrings.Values['FileVersion'];
end;

procedure TFormAbout.Label5Click(Sender: TObject);
begin
  OpenURL('https://xc-basic.net/doku.php');
end;

end.

