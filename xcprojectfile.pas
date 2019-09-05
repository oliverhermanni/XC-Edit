unit xcprojectfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, Dialogs, SysUtils, LazFileUtils, laz2_DOM, laz2_XMLRead, laz2_XMLWrite;

const __VERSION__ = '1.0';

  type TXCProjectFile = class
    private
      var sFName: string;
    public
      property FName: string read sFName write sFName;
      procedure CreateProject(name, author, comment, folder, executable: string);
      procedure CreateNode(Doc: TXMLDocument; RootNode: TDOMNode; elementname, value: string; CDATA: boolean = false);
  end;

implementation

procedure TXCProjectFile.CreateProject(name, author, comment, folder, executable: string);
var
  Doc: TXMLDocument;
  RootNode, ParentNode, ValueNode, FilesNode, FileValueNode: TDOMNode;
begin
  try
    Doc := TXMLDocument.Create;
    // Create document
    RootNode := Doc.CreateElement('Project');
    Doc.AppendChild(RootNode);
    RootNode:= Doc.DocumentElement;
    // Version of current project (not required for now)
    CreateNode(Doc, RootNode, 'Version', __VERSION__);
    // Name of Project
    CreateNode(Doc, RootNode, 'Name', name, true);
    // author
    CreateNode(Doc, RootNode, 'Author', author, true);
    // comment
    CreateNode(Doc, RootNode, 'Comment', comment, true);
    // folder
    CreateNode(Doc, RootNode, 'Folder', folder, true);
    // executable
    CreateNode(Doc, RootNode, 'Executable', executable + '.prg');

    // mainsource
    CreateNode(Doc, RootNode, 'Executable', executable + '.bas');

    ParentNode:= Doc.CreateElement('Files');
    FilesNode := Doc.CreateElement('File');
    // filename
    CreateNode(Doc, FilesNode, 'Filename', executable + '.bas');
    CreateNode(Doc, FilesNode, 'Folder', folder, true);
    CreateNode(Doc, FilesNode, 'IncludeInBuild', '1');
    CreateNode(Doc, FilesNode, 'FileOpen', '1');

    ParentNode.AppendChild(FilesNode);
    RootNode.AppendChild(ParentNode);

    FName := folder + DirectorySeparator + name + '.xcprj';
    writeXMLFile(Doc, FName);
  finally
    Doc.Free;
  end;
end;

procedure TXCProjectFile.CreateNode(Doc: TXMLDocument; RootNode: TDOMNode; elementname, value: string; CDATA: boolean = false);
var
  ParentNode, ValueNode: TDOMNode;
begin
  ParentNode:= Doc.CreateElement(elementname);
  if CDATA = true then begin
    ValueNode:= Doc.CreateCDATASection(value);
  end else begin
    ValueNode:= Doc.CreateTextNode(value);
  end;

  ParentNode.AppendChild(ValueNode);
  RootNode.AppendChild(ParentNode);
end;

end.

