unit event;

interface
uses
  Windows,
  Classes,
  Controls,
  SysUtils,
  DateUtils;

type

  // TODO : pointer back to the ListItem this event is the .Data of?
  //        yes when new events as controllers methodology is fully realized
  TRemindEvent = class(TObject)
  private
    FNotes : string;
    FDate  : TDate;
    FTime  : TTime;
    FOccur : string;
    FCompleted : boolean;
  public
    function  GetNotes():string;
    procedure SetNotes( value:string );
    property  Notes:string read GetNotes write SetNotes;

    function  GetName():string;
    procedure SetName( value:string );
    property  Name:string read GetName write SetName;

    function  GetDate():TDate;
    procedure SetDate( value:TDate );
    property  Date:TDate read GetDate write SetDate;

    function  GetTime():TTime;
    procedure SetTime( value:TTime );
    property  Time:TTime read GetTime write SetTime;

    function  GetOccur():string;
    procedure SetOccur( value:string );
    property  Occur:string read GetOccur write SetOccur;

    function  GetCompleted():boolean;
    procedure SetCompleted( value:boolean );
    property  Completed:boolean read GetCompleted write SetCompleted;

    function  Triggered():boolean;
    procedure RollBack();
    procedure NextOccur();
    procedure TakeAction();
  end;

implementation
uses
  main;

function TRemindEvent.GetNotes():string;
begin
  result := StringReplace(FNotes,#13#10,#10,[rfReplaceAll]);
end;

procedure TRemindEvent.SetNotes( value:string );
begin
  FNotes := value;
end;

function TRemindEvent.GetName():string;
var
  sl : TStringList;
begin
  sl := TStringList.Create();
  sl.Text := Notes;
  if sl.Count > 0 then begin
    result := sl[0];
  end else begin
    result := '';
  end;
  sl.Free;
end;

procedure TRemindEvent.SetName( value:string );
var
  sl : TStringList;
begin
  sl := TStringList.Create();
  sl.Text := Notes;
  sl[0] := value;
  sl.Free;
end;

function  TRemindEvent.GetDate():TDate;
begin
  result := FDate;
end;

procedure TRemindEvent.SetDate( value:TDate );
begin
  FDate := value;
end;

function  TRemindEvent.GetTime():TTime;
begin
  result := FTime;
end;

procedure TRemindEvent.SetTime( value:TTime );
begin
  FTime := value;
end;

function  TRemindEvent.GetOccur():string;
begin
  result := FOccur;
end;

procedure TRemindEvent.SetOccur( value:string );
begin
  FOccur := value;
end;

function  TRemindEvent.GetCompleted():boolean;
begin
  result := FCompleted;
end;

procedure TRemindEvent.SetCompleted( value:boolean );
begin
  FCompleted := value;
end;

function TRemindEvent.Triggered():boolean;
begin
  result := false;
  if not completed then begin
    // 2005-08-14 : fixed another ancient bug where event would not trigger until time met even if date had already passed
    // event date has passed {1}
    if CompareDate(Now(),date)=1 then begin
      result := true;
    end;
    // event date is today {0}
    if CompareDate(Now(),date)=0 then begin
      // and time has passed {1} or is now {0}
      if CompareTime(Now(),time) >=0 then begin
        result := true;
      end;
    end;
  end;
end;

// TODO : how are these date's updated in the ListView?
// RollBack rolls back events so they all are triggered on their most recent possible date
// this is useful when you change your system clock for say... debugging some other app,
// then you get 30 remind popups and the events have all changed, oops!
procedure TRemindEvent.RollBack();
begin
  if Occur = 'once' then begin
    completed := false;
  end else if Occur = 'daily' then begin
    // while greater than now dec
    while CompareDate(Date,Now())>0 do begin
      Date := IncDay(-Date);
    end;
    // then if is today (always on daily) and time is more than now, dec one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())>0 then begin
        Date := IncDay(-Date);
      end;
    end;
    // Now skip one...
    Date := IncDay(Date);
  end else if Occur = 'weekly' then begin
    // while more than date dec
    while CompareDate(Date,Now())>0 do begin
      Date := IncWeek(-Date);
    end;
    // then if is today and time is more than now, dec one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())>0 then begin
        Date := IncWeek(-Date);
      end;
    end;
    // Now skip one...
    Date := IncWeek(Date);
  end else if Occur = 'monthly' then begin
    // while more than date dec
    while CompareDate(Date,Now())>0 do begin
      Date := IncMonth(-Date);
    end;
    // then if is today and time is more than now, dec one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())>0 then begin
        Date := IncMonth(-Date);
      end;
    end;
    // Now skip one...
    Date := IncMonth(Date);
  end else if Occur = 'every 3 months' then begin
    // while more than date dec
    while CompareDate(Date,Now())>0 do begin
      Date := IncMonth(-Date,3);
    end;
    // then if is today and time is more than now, dec one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())>0 then begin
        Date := IncMonth(-Date,3);
      end;
    end;
    // Now skip one...
    Date := IncMonth(Date,3);
  end else if Occur = 'every 6 months' then begin
    // while more than date dec
    while CompareDate(Date,Now())>0 do begin
      Date := IncMonth(-Date,6);
    end;
    // then if is today and time is more than now, dec one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())>0 then begin
        Date := IncMonth(-Date,6);
      end;
    end;
    // Now skip one...
    Date := IncMonth(Date,6);
  end else if Occur = 'yearly' then begin
    // while more than date dec
    while CompareDate(Date,Now())>0 do begin
      Date := IncYear(-Date);
    end;
    // then if is today and time is more than now, dec one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())>0 then begin
        Date := IncYear(-Date);
      end;
    end;
    // Now skip one...
    Date := IncYear(Date);
  end;
  // TODO : should this be here? It must be currently, but I am in between methodologies
  // in the future I think all of my saves will be done in here...
  MainForm.SaveEvents();
end;

// TODO : how are these date's updated in the ListView?
procedure TRemindEvent.NextOccur();
begin
  if Occur = 'once' then begin
    completed := true;
  end else if Occur = 'daily' then begin
    // while less than date inc
    while CompareDate(Date,Now())<0 do begin
      Date := IncDay(Date);
    end;
    // then if is today (always on daily) and time is less than now, inc one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())<0 then begin
        Date := IncDay(Date);
      end;
    end;
  end else if Occur = 'weekly' then begin
    // while less than date inc
    while CompareDate(Date,Now())<0 do begin
      Date := IncWeek(Date);
    end;
    // then if is today and time is less than now, inc one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())<0 then begin
        Date := IncWeek(Date);
      end;
    end;
  end else if Occur = 'monthly' then begin
    // while less than date inc
    while CompareDate(Date,Now())<0 do begin
      Date := IncMonth(Date);
    end;
    // then if is today and time is less than now, inc one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())<0 then begin
        Date := IncMonth(Date);
      end;
    end;
  end else if Occur = 'every 3 months' then begin
    // while less than date inc
    while CompareDate(Date,Now())<0 do begin
      Date := IncMonth(Date,3);
    end;
    // then if is today and time is less than now, inc one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())<0 then begin
        Date := IncMonth(Date,3);
      end;
    end;
  end else if Occur = 'every 6 months' then begin
    // while less than date inc
    while CompareDate(Date,Now())<0 do begin
      Date := IncMonth(Date,6);
    end;
    // then if is today and time is less than now, inc one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())<0 then begin
        Date := IncMonth(Date,6);
      end;
    end;
  end else if Occur = 'yearly' then begin
    // while less than date inc
    while CompareDate(Date,Now())<0 do begin
      Date := IncYear(Date);
    end;
    // then if is today and time is less than now, inc one more
    if CompareDate(Date,Now())=0 then begin
      if CompareTime(Date,Now())<0 then begin
        Date := IncYear(Date);
      end;
    end;
  end;
  // TODO : should this be here? It must be currently, but I am in between methodologies
  // in the future I think all of my saves will be done in here...
  MainForm.SaveEvents();
end;

procedure TRemindEvent.TakeAction();
begin
  if self = nil then exit; // takes care of snoozed events that were later deleted
  // TODO : other actions instead of just this popup
  MainForm.EventPopup(self);
end;

end.
