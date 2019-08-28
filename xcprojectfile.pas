unit xcprojectfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, Dialogs, SysUtils, fpjson, jsonparser, LazFileUtils;

const __VERSION__ = '1.0';

  type TXCProjectFile = class
    private
    public
      procedure CreateProject(name, author, comment, folder, executable: string);
  end;

implementation

procedure TXCProjectFile.CreateProject(name, author, comment, folder, executable: string);
var
  jpo: TJSONObject;
  jfa: TJSONArray;
  stream: TFileStream;
  fsz: longint;
begin
  {*
  jpo := TJSONObject.Create;
  with jpo do begin
    Add('version', __VERSION__);
    Add('name', name);
    Add('author', author);
    Add('comment', comment);
    Add('folder', folder);
    Add('executable', executable + '.prg');
    Add('mainsource', executable + '.bas');
    jfa := TJSONArray.Create;
    jpo.Add('files', jfa);
  end;
  ForceDirectory(folder);
  stream := TFileStream.Create(folder + DirectorySeparator + name, fmCreate);
  try
    stream.Position := 0;
    stream.Write(, fsz);
  finally
    stream.free;
  end;
  ShowMessage(folder + DirectorySeparator + name);
  *}
end;

end.

