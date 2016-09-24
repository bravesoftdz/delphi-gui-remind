unit checker_deprecated;

interface
uses
  Classes,
  Windows,
  DateUtils,
  SysUtils;

type
  TChecker = Class(TThread)
  private
  protected
    procedure Execute; override;
  end;

implementation
uses main, event;

procedure TChecker.Execute;
var
  i : integer;
  event : TRemindEvent;
begin
  // TODO : this aint thread safe either
  while not MainFormClosing do begin
    // loops events
    for i:=0 to MainForm.List.Items.Count-1 do begin
      // TODO : OUCH : THREAD SAFETY, deleting these events while this loops is baaaaaad!
      // TODO : I should try that multi-read synchronizer here
      try
        event := TRemindEvent(MainForm.List.Items[i].Data);
        if event = nil then continue;
        if event.triggered then begin
          Synchronize(event.NextOccur);
          Synchronize(event.TakeAction);
        end;
      except
        on e:Exception do
          // TODO : absolutely nothing, a thread sync error just occurred.
      end;
      if MainFormClosing then break;
      sleep(400);
    end;
  end;
end;

end.
