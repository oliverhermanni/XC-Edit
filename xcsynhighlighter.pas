unit XCSynHighlighter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, Graphics;

type
  TXCSynHighlighter = class(TSynFacilSyn)
    private
      { private declarations }
    public
      { public declarations }
      constructor Create(AOwner: TComponent); overload;
//      destructor Destroy; overload;

  end;

const
  arrKeyWords : array[0..68] of string = (
    'abs', 'asm', 'atn',
    'cast', 'call', 'charat', 'const', 'cos', 'curpos',
    'data', 'dec', 'deek', 'dim', 'disableirq', 'doke',
    'enableirq', 'else', 'end', 'endif', 'endproc', 'endwhile',
    'ferr', 'for',
    'gosub', 'goto',
    'if', 'inc', 'incbin', 'include', 'inkey', 'input',
    'let', 'load', 'lshift',
    'memcpy', 'memset', 'memshift',
    'next',
    'on', 'origin',
    'peek', 'poke', 'pragma', 'print', 'proc',
    'repeat', 'return', 'rnd', 'rshift',
    'save', 'sgn', 'sin', 'sqr', 'strcmp', 'strcpy', 'strlen', 'strncpy', 'strpos', 'sys',
    'tan', 'textat', 'then', 'to',
    'until', 'usr',
    'val',
    'wait', 'watch', 'while'
  );


implementation


constructor TXCSynHighlighter.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited Create(AOwner);

  with self do begin
    ClearSpecials;
    CreateAttributes;
    ClearMethodTables;
    DefTokIdentif('[A-Za-z$%i]','[A-Za-z0-9]*');
//    DefTokContent('[0..9.]','[0-9xabcdefXABCDEF]*','', tkNumber);
    for i := 0 to Length(arrKeyWords)-1 do begin
      self.AddKeyword(arrKeyWords[i])
    end;
    tkKeyword.Foreground := clBlack;
    tkKeyword.Style := [fsBold];
    Rebuild;
  end
end;

end.

