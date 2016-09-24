unit main;

// TODO : nextoccur not updating list items, new methodology should be implemented.
// TODO : open/save as support
// TODO : verify exit with popup
// TODO : listview dynamic sizing, & general form layout/sizing
// TODO : day outline's not updating with events
// TODO : snooze seems to be incorrectly completing events, yes thats a big logic problem...
//        if it isnt completed before 1st take action, it will be triggered every heartbeat
//        a snoozed flag (which would not be persistent and default to false) might be needed
//        inversely snoozed flag could be ActionHasBeenTaken flag
//        also, after edits i guess it would be reset

interface

uses
  Windows,
  eventPopup,
  eventEdit,
  event,
  vSystem,
  LibXMLParser,
  Forms,
  SysUtils,
  DateUtils,
  Types,
  cal_main,
  CoolTrayIcon,
  Graphics,
  syncobjs,
  Classes, Menus,
  Controls, StdCtrls, ComCtrls, ExtCtrls, ImgList;

type
  TMainForm = class(TForm)
    ListMenu: TPopupMenu;
    miListMenuNew: TMenuItem;
    miListMenuEdit: TMenuItem;
    miListMenuDelete: TMenuItem;
    N1: TMenuItem;
    miListMenuComplete: TMenuItem;
    MainFormMenu: TMainMenu;
    miFile: TMenuItem;
    miFileMinimize: TMenuItem;
    miFileExit: TMenuItem;
    N2: TMenuItem;
    miEvent: TMenuItem;
    miEventNew: TMenuItem;
    miEventEdit: TMenuItem;
    miEventDelete: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSaveAs: TMenuItem;
    TrayIcon: TCoolTrayIcon;
    TrayIconMenu: TPopupMenu;
    miTrayIconShowWindow: TMenuItem;
    N3: TMenuItem;
    miTrayIconExit: TMenuItem;
    miTrayIconMinimize: TMenuItem;
    List: TListView;
    Memo: TMemo;
    PSCCalendar1: TPSCCalendar;
    StatusBar1: TStatusBar;
    ImageList: TImageList;
    N4: TMenuItem;
    RollBack1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationHint(Sender: TObject);
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);
    procedure TrayIconClick(Sender: TObject);
    procedure zFileMinimizeExecute(Sender: TObject);
    procedure zFileExitExecute(Sender: TObject);
    procedure zEventNewExecute(Sender: TObject);
    procedure zEventEditExecute(Sender: TObject); overload;
    procedure zEventDeleteExecute(Sender: TObject);
    procedure zTrayShowWindowExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure PSCCalendar1DrawDayOutline(Sender: TObject; const ADate: TDateTime; X, Y: Integer; const ARect: TRect; var AParams: TPSCDrawDayOutlineParams);
    procedure PSCCalendar1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure RollBack1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadEvents();
    procedure SaveEvents();
    function  LoadEvent( Event:TRemindEvent ): integer;
    procedure NewEvent( Event:TRemindEvent );
    procedure EditEvent( editedEvent:TRemindEvent );
    procedure DeleteEvent( i:integer );
    procedure EventPopup( event:TRemindEvent );
    procedure zEventEditExecute(Sender: TObject; event: TRemindEvent ); overload;
  end;

  TFunkyForm = class(TScrollingWinControl)
  private
    FActiveControl: TWinControl;
    FFocusedControl: TWinControl;
    FBorderIcons: TBorderIcons;
    FBorderStyle: TFormBorderStyle;
    FSizeChanging: Boolean;
    FWindowState: TWindowState;
  end;

var
  MainForm: TMainForm;
  MainFormClosing:boolean;
  xml:TXmlParser;
  xmlfilename:string;
  previousMouseMoveDate:TDateTime;
  eventSync : TMultiReadExclusiveWriteSynchronizer;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainFormClosing := false;
  eventSync := TMultiReadExclusiveWriteSynchronizer.Create();
  xmlfilename := 'remind.xml';
  Application.OnHint := ApplicationHint;
  Application.OnIdle := ApplicationIdle;
  TrayIcon.Icon := Application.Icon;
  miTrayIconMinimize.Enabled := false;
  PSCCalendar1.StartDate := Now();
  LoadEvents();
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainFormClosing := true;
  SaveEvents(); // just for fun, not exactly required
//-  checkerThread.WaitFor();
  eventSync.free();
end;

procedure TMainForm.ApplicationHint(Sender: TObject);
begin
  StatusBar1.SimpleText := ' ' + Application.Hint;
end;

procedure TMainForm.ApplicationIdle(Sender: TObject; var Done: Boolean);
var
  i : integer;
  event : TRemindEvent;
  somethingtriggered : boolean; // 2005-08 : making listitem resort when event nextoccur called
  originalsorttype : TSortType;
begin
  Done := false;
  somethingtriggered := false; // 2005-08
  // loops events
  for i:=0 to MainForm.List.Items.Count-1 do begin
    event := TRemindEvent(MainForm.List.Items[i].Data);
    if event = nil then continue;
    if event.triggered then begin
      somethingtriggered := true;
      event.TakeAction;
      event.NextOccur;
      MainForm.List.Items[i].SubItems[1] := FormatDateTime(ShortDateFormat,event.date);
      MainForm.List.Items[i].SubItems[2] := FormatDateTime(ShortTimeFormat,event.time);
    end;
    if MainFormClosing then break;
  end;
  // 2005-08: resort list attempt
  if somethingtriggered then begin
    originalsorttype := MainForm.List.SortType;
    MainForm.List.SortType := stNone;
    MainForm.List.SortType := originalsorttype;
  end;
  sleep(20);
end;

procedure TMainForm.zFileExitExecute(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.zEventNewExecute(Sender: TObject);
var
  eventEditForm : TEventEditForm;
begin
  eventEditForm := TEventEditForm.Create(self);
  try
    eventEditForm.ShowModal;
  finally
    eventEditForm.Free;
  end;
end;

procedure TMainForm.zEventEditExecute(Sender: TObject);
var
  eventEditForm : TEventEditForm;
begin
  if List.ItemFocused <> nil then begin
    eventEditForm := TEventEditForm.Create(self);
    try
      eventEditForm.injectEvent( TRemindEvent(List.ItemFocused.Data) );
      eventEditForm.ShowModal;
    finally
      eventEditForm.Free;
    end;
  end;
end;

procedure TMainForm.zEventEditExecute(Sender: TObject; event: TRemindEvent );
var
  eventEditForm : TEventEditForm;
begin
  if List.ItemFocused <> nil then begin
    eventEditForm := TEventEditForm.Create(self);
    try
      eventEditForm.injectEvent( event );
      eventEditForm.ShowModal;
    finally
      eventEditForm.Free;
    end;
  end;
end;

procedure TMainForm.zEventDeleteExecute(Sender: TObject);
begin
  if List.ItemFocused <> nil then begin
    DeleteEvent(List.ItemFocused.Index);
  end;
end;

// TODO : Delete Selected? delete's all selected items? not just the focus'ed one
//  List.Selected.Delete;

procedure TMainForm.TrayIconClick(Sender: TObject);
begin
  if MainForm.Showing then
    zFileMinimizeExecute(self)
  else
    zTrayShowWindowExecute(self);
end;

procedure TMainForm.zFileMinimizeExecute(Sender: TObject);
begin
  miTrayIconShowWindow.Enabled := true;
  miTrayIconMinimize.Enabled := false;
  TrayIcon.HideMainForm;
end;

procedure TMainForm.zTrayShowWindowExecute(Sender: TObject);
begin
  miTrayIconShowWindow.Enabled := false;
  miTrayIconMinimize.Enabled := true;
  TrayIcon.ShowMainForm;
end;

// LoadEvent doesn't focus the ListItem, and doesn't save the events, NewEvent does!
// returns the index of the loaded event
function TMainForm.LoadEvent( Event:TRemindEvent ): integer;
var
  currentItem : TListItem;
begin
  if Event = nil then begin
    result := -1;
    exit;
  end;
  currentItem := List.Items.Add();
  if event.completed then begin
    currentItem.ImageIndex := 0;
  end else begin
    currentItem.ImageIndex := -1;
  end;
  currentItem.SubItems.Add(event.name);
  currentItem.SubItems.Add(FormatDateTime(ShortDateFormat,event.date));
  currentItem.SubItems.Add(FormatDateTime(ShortTimeFormat,event.time));
  currentItem.SubItems.Add(Event.Occur);

  currentItem.Data := Event;
  result := currentItem.Index;
  Memo.Lines.Text := event.notes;

end;

// NewEvent, Loads the Event (above), selects/focuses the ListItem for it, repaints calendar, and Saves Events
procedure TMainForm.NewEvent( Event:TRemindEvent );
var
  newIndex : integer;
begin
  if Event = nil then exit;
  newIndex := LoadEvent(Event);
  List.ItemFocused := List.Items[newIndex];
  List.Selected := List.Items[newIndex];
  SaveEvents();
//  PSCCalendar1.Invalidate;
//  PSCCalendar1.Refresh;
  PSCCalendar1.Repaint;//-
//  PSCCalendar1.Realign;
//  PSCCalendar1.Canvas.Refresh;
end;

procedure TMainForm.EditEvent( editedEvent:TRemindEvent );
begin
  if editedEvent = nil then exit;
  // delete current event
  DeleteEvent(List.ItemFocused.Index);
  // add new event
  NewEvent(editedEvent);
  PSCCalendar1.Repaint;//-
end;

procedure TMainForm.DeleteEvent( i:integer );
begin
  Memo.Clear;
  TRemindEvent(List.Items[i].Data).Free;
  List.Items[i].Delete;
  List.Selected := List.ItemFocused;
  SaveEvents();
//-  PSCCalendar1.Repaint;//- TODO : super slow on large events list... uncomment or not?
end;

procedure TMainForm.LoadEvents();
var
  event : TRemindEvent;
  F : TextFile;
  i : integer;
  sillyNotes : string;
begin
  // free all ListItems Data Event pointers...
  for i:=0 to List.Items.Count-1 do begin
    TRemindEvent(List.Items[i].Data).Free;
  end;
  List.Clear;

  if (not vFileExists(xmlfilename)) or (vGetFileSize(xmlfilename)=0) then begin
    // create a dummy file...
    AssignFile(F,xmlfilename);
    Rewrite(F);
//    WriteLn(F,'<?xml version="1.0"?>');
    WriteLn(F,'<remind version="1.0.0">');
    WriteLn(F,'</remind>');
    CloseFile(F);
  end;

  try
    xml := TXMLParser.Create();
    xml.LoadFromFile(xmlfilename);
    xml.StartScan;
    while xml.Scan do begin
      case xml.CurPartType of
        ptStartTag :
        begin
          if xml.curname='event' then begin
            if event <> nil then begin
              event := TRemindEvent.Create();
              with event do begin
                try
                  date  := StrToDate( xml.CurAttr.Value('date') );
                except
                  on e : Exception do
                    date := Now();
                end;
                try
                  time  := StrToTime( xml.CurAttr.Value('time') );
                except
                  on e : Exception do
                    time := Now();
                end;
                occur := xml.CurAttr.Value('occur');
                try
                  completed := StrToBool( xml.CurAttr.Value('completed') );
                except
                  on e : Exception do
                    completed := false;
                end;
              end;
            end;
          end;
        end;
        ptContent :
        begin
          if xml.curname='notes' then begin
            if event <> nil then begin
              //event.Notes := xml.CurContent;
              // silly stuff required to keep whitespace in CurContent
              sillyNotes := '';
              SetStringSF(sillyNotes,xml.CurStart,xml.CurFinal);
              event.Notes := sillyNotes;
            end;
          end;
        end;
        ptEndTag :
        begin
          if xml.curname='event' then begin
            if event <> nil then begin
              LoadEvent(event);
              //TODO : VERIFY : Because the created event is owned by List, we don't free.
              //event.free;
            end;
          end;
        end;
      end;
    end;
    xml.free; // TODO : this should be in a finally somewhere someday ;p
  except
    on e : Exception do begin
      Application.MessageBox('Renaming invalid xml and creating new...','Invalid XML');
      RenameFile(xmlfilename,xmlfilename+'.invalid.'+FormatDateTime('yyyymmdd-hhnnss',Now));
      LoadEvents();
    end;
  end;
end;

procedure TMainForm.SaveEvents();
var
  F : TextFile;
  i : integer;
  event : TRemindEvent;
begin
{ eg.
<?xml version="1.0" encoding="UTF-8"?>
<remind version="1.0.0">
  <event date="9/16/2002" time="1:00 PM" occur="weekly">
    <notes>Soccer</notes>
  </event>
</remind>
}
// TODO : replace special chars of course... maybe a function for this? html encode them
// TODO : must also remember to decode them on loadevents
  DeleteFile(xmlfilename+'.bak');
  RenameFile(xmlfilename,xmlfilename+'.bak');
  AssignFile(F,xmlfilename);
  Rewrite(F);
  WriteLn(F,'<remind version="1.0.0">');
  // loop events
  for i:=0 to List.Items.Count-1 do begin
    event := TRemindEvent(List.Items[i].Data);
    WriteLn(F,'  <event date="'+FormatDateTime(ShortDateFormat,event.date)+'" time="'+FormatDateTime(ShortTimeFormat,event.time)+'" occur="'+event.occur+'" completed="'+BoolToStr(event.completed,true)+'">');
    WriteLn(F,'    <notes>'+event.notes+'</notes>');
    WriteLn(F,'  </event>');
  end;
  WriteLn(F,'</remind>');
  CloseFile(F);
end;

procedure TMainForm.ListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  // selected
  if Selected then begin
    // updates NotesMemo with this items notes
    Memo.Lines.Text := TRemindEvent(Item.Data).notes;
  // unselected
  end else begin

  end;
end;

procedure TMainForm.PSCCalendar1DrawDayOutline(Sender: TObject; const ADate: TDateTime; X, Y: Integer; const ARect: TRect; var AParams: TPSCDrawDayOutlineParams);
var
  i : integer;
  Today : TDateTime;
begin
  // loop all events, checking if this is the same date
  Today := Now();
  for i:=0 to List.Items.Count-1 do begin
    if (ADate = TRemindEvent(List.Items[i].Data).Date) and (not IsSameDay(ADate,Today)) then begin
      AParams:=AParams-[dopSetTodayColor]+[dopShowToday];
      PSCCalendar1.Canvas.Brush.Color:=clHighlight;    end;
  end;
end;

procedure TMainForm.PSCCalendar1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  dateUnder : TDateTime;
  i : integer;
begin
  PSCCalendar1.GetHitTest( Point(x,y), dateUnder);
  // if date same as previous mousemovedate, exit, else clear statusbar
  if dateUnder = previousMouseMoveDate then begin
    exit;
  end else begin
    previousMouseMoveDate := dateUnder;
    StatusBar1.SimpleText := '';
  end;
  // loop all events, checking if this date has a event
  for i:=0 to List.Items.Count-1 do begin
    if dateUnder = TRemindEvent(List.Items[i].Data).Date then begin
      StatusBar1.SimpleText := TRemindEvent(List.Items[i].Data).Name;
      break;
    end;
  end;
end;

procedure TMainForm.ListCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Event1, Event2: TRemindEvent;
begin
  Event1 := TRemindEvent(Item1.Data);
  Event2 := TRemindEvent(Item2.Data);
  // check date
  Compare := CompareDate( Event1.Date, Event2.Date );
  // if same date, check time
  if Compare = 0 then begin
    Compare := CompareTime( Event1.Time, Event2.Time );
  end;
end;

procedure TMainForm.EventPopup( event:TRemindEvent );
var
  popupForm : TEventPopupForm;
  FState : TWindowState;
begin
  //2007-03-16: making self, not nil
  //popupForm := TEventPopupForm.Create(nil); // TODO : nil or self?
  popupForm := TEventPopupForm.Create(self);
  popupForm.event := event;

  FState := TFunkyForm(popupForm).FWindowState;
  TFunkyForm(popupForm).FWindowState := TWindowState(128);
  popupForm.Visible := TRUE;
//  SetWindowPos(popupForm.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetWindowPos(popupForm.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  TFunkyForm(popupForm).FWindowState := FState;
end;

procedure TMainForm.RollBack1Click(Sender: TObject);
var
  i : integer;
  event : TRemindEvent;
begin
  // loops events
  for i:=0 to MainForm.List.Items.Count-1 do begin
    event := TRemindEvent(MainForm.List.Items[i].Data);
    event.RollBack();
  end;
end;

end.
