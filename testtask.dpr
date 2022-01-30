program testtask;

uses
  System.SysUtils, Classes, SyncObjs;

var
  value : array[1..2] of integer;
  n : integer;
  resultfile : TextFile;

type
  NewThread = class(TThread)
  private
    threadname : string;
    threadn : integer; // номер потока
  protected
    procedure Execute; override;
    procedure pasteIntoFile;
  public
    constructor Create(StartSuspended : boolean; threadname : string; threadn : integer);
  end;


constructor NewThread.Create(StartSuspended : boolean; threadname : string; threadn : integer);
begin
  FreeOnTerminate := true;
  inherited Create(StartSuspended);
  self.threadname := threadname;
  self.threadn := threadn;
end;

procedure NewThread.pasteIntoFile;
var
  anotherthread : integer;
begin
  if self.threadn = 1 then
    anotherthread := 2
  else
    anotherthread := 1;
  repeat
    if value[self.threadn] < value[anotherthread] then begin
      append(resultfile);
      write(resultfile, inttostr(value[self.threadn]) + ' ');
      close(resultfile);
    end;
  until value[self.threadn] < value[anotherthread];

end;

procedure NewThread.Execute;
var
  j : integer;
  flag : boolean;
  f : TextFile;
begin
  AssignFile(f, self.threadname + '.txt');
  rewrite(f);
  flag := true;
  if self.threadn = 1 then begin
    write(f, '2 ');
    append(resultfile);
    write(resultfile, '2 ');
    close(resultfile);
  end;

  repeat
    for j := 2 to value[self.threadn]-1 do begin
      if value[self.threadn] mod j = 0 then begin
        flag := false;
        break;
      end;
    end;
    if flag then begin
      write(f, inttostr(value[self.threadn]) + ' ');
      self.pasteIntoFile;
    end;
    value[self.threadn] := value[self.threadn] + 4; // шаг в 4 позволяет не проверять четные числа
    flag := true;
  until Terminated or (value[self.threadn] >= n);
  closefile(f);
end;

var
  Thread1, Thread2 : NewThread;
begin
  n := 1000000;
  value[1] := 3;
  value[2] := 5;
  AssignFile(resultfile, 'Result.txt');
  rewrite(resultfile);
  closefile(resultfile);
  Thread1 := NewThread.Create(false, 'Thread1', 1);
  Thread2 := NewThread.Create(false, 'Thread2', 2);
  readln;
end.
