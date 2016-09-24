unit eventPopup;

interface

uses
  Windows,
  event,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEventPopupForm = class(TForm)
    Memo: TMemo;
    OkButton: TButton;
    Edit: TEdit;
    Checkbox: TCheckBox;
    ComboBox: TComboBox;
    EditButton: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OkButtonClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
  private
    { Private declarations }
    FEvent : TRemindEvent;
  public
    { Public declarations }
    function  GetEvent():TRemindEvent;
    procedure SetEvent( value:TRemindEvent );
    property  Event:TRemindEvent read GetEvent write SetEvent;
  end;

  TSnoozeThread = class(TThread)
  public
    event : TRemindEvent;
    sleepFor : integer;
  protected
    procedure Execute; override;
  end;

var
  EventPopupForm: TEventPopupForm;

implementation

uses main;

{$R *.dfm}

procedure TEventPopupForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  snoozeThread : TSnoozeThread;
  sleepForValue : integer;
  idx : integer;
begin
  Action := caFree;
  if Checkbox.Checked then begin
    // start a snooze thread
    snoozeThread := TSnoozeThread.Create(true);
    snoozeThread.event := event;
    try
      sleepForValue := strtoint(Edit.Text);
    except
      on e: EConvertError do
        sleepForValue := 10;
    end;
    idx := ComboBox.ItemIndex;
    //if idx... nm, see ItemIndex property in design-time editor
    //codesite.send('idx',idx);
    if Combobox.Items[idx] = 'minutes' then begin
      snoozeThread.sleepFor := sleepForValue*1000*60;
    end else if Combobox.Items[idx] = 'hours' then begin
      snoozeThread.sleepFor := sleepForValue*1000*60*60;
    end;
    snoozeThread.resume();
  end;
end;

function TEventPopupForm.GetEvent():TRemindEvent;
begin
  result := FEvent;
end;

procedure TEventPopupForm.SetEvent( value:TRemindEvent );
begin
  FEvent := value;
  Memo.Lines.text := value.Notes;
  self.caption := FormatDateTime(ShortDateFormat,event.date) + ' ' + FormatDateTime(ShortTimeFormat,event.time);
end;

procedure TSnoozeThread.Execute;
begin
  sleep(sleepFor);
  Synchronize(event.TakeAction);
end;

procedure TEventPopupForm.OkButtonClick(Sender: TObject);
begin
  self.close();
end;

procedure TEventPopupForm.EditButtonClick(Sender: TObject);
begin
  TMainForm(self.Owner).zEventEditExecute(self,Event);
end;

end.
