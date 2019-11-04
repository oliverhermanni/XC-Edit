unit xcprojectfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, Dialogs, SysUtils, LazFileUtils, ComCtrls,
  laz2_DOM, laz2_XMLRead, laz2_XMLWrite;

const __VERSION__ = '1.0';

  type TXCProjectFile = class
    private
      var sFName: string;
    public
      constructor Create; overload;
      property FName: string read sFName write sFName;
      var Project: TXMLDocument;
      procedure CreateProject(name, author, comment, folder, executable: string);
      procedure CreateNode(RootNode: TDOMNode; elementname, value: string; CDATA: boolean = false);
      procedure FillTreeView(TreeView: TTreeView);
  end;

implementation

constructor TXCProjectFile.Create;
begin
  self.Project := TXMLDocument.Create;
end;

procedure TXCProjectFile.CreateProject(name, author, comment, folder, executable: string);
var
  RootNode, ParentNode, ValueNode, FilesNode, FileValueNode: TDOMNode;
begin
  // Create document
  RootNode := Project.CreateElement('Project');
  Project.AppendChild(RootNode);
  RootNode:= Project.DocumentElement;
  // Version of current project (not required for now)
  CreateNode(RootNode, 'Version', __VERSION__);
  // Name of Project
  CreateNode(RootNode, 'Name', name, true);
  // author
  CreateNode(RootNode, 'Author', author, true);
  // comment
  CreateNode(RootNode, 'Comment', comment, true);
  // folder
  CreateNode(RootNode, 'Folder', folder, true);
  // executable
  CreateNode(RootNode, 'Executable', executable + '.prg');

  // mainsource
  CreateNode(RootNode, 'Executable', executable + '.bas');

  ParentNode:= Project.CreateElement('Files');
  FilesNode := Project.CreateElement('File');
  // filename
  CreateNode(FilesNode, 'Filename', executable + '.bas');
  CreateNode(FilesNode, 'Folder', folder, true);
  CreateNode(FilesNode, 'IncludeInBuild', '1');
  CreateNode(FilesNode, 'FileOpen', '1');

  ParentNode.AppendChild(FilesNode);
  RootNode.AppendChild(ParentNode);

  FName := folder + DirectorySeparator + name + '.xcprj';
  writeXMLFile(Project, FName);
end;

procedure TXCProjectFile.CreateNode(RootNode: TDOMNode; elementname, value: string; CDATA: boolean = false);
var
  ParentNode, ValueNode: TDOMNode;
begin
  ParentNode:= Project.CreateElement(elementname);
  if CDATA = true then begin
    ValueNode:= Project.CreateCDATASection(value);
  end else begin
    ValueNode:= Project.CreateTextNode(value);
  end;

  ParentNode.AppendChild(ValueNode);
  RootNode.AppendChild(ParentNode);
end;

procedure TXCProjectFile.FillTreeView(TreeView: TTreeView);
var
  FilesNode, F: TDOMNode;
  TreeNode: TTreeNode;
begin
  ReadXMLFile(Project, FName);
  FilesNode:= Project.FindNode('Files');

  for F in FilesNode do begin
      TreeView.Items.AddChild(nil, 'x');
  end;
end;

end.

