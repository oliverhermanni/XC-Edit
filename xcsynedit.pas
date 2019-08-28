unit xcsynedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, SynEdit, SynEditTypes;

type
  TXCSynEdit = class(TSynEdit)
  private
    sFilename: string;
  public
    constructor Create(theComponent: TComponent); override;
    property Filename: string read sFilename write sFilename;
  end;


implementation

constructor TXCSynEdit.Create(theComponent: TComponent);
begin
  inherited Create(theComponent);
  Name := 'Editor';
  Align := alClient;
  Lines.Clear;
  Keystrokes.Delete(45);
end;

end.

