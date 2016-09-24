unit eventEdit;

interface

uses
  Forms,
  SysUtils,
  event,
  Classes, Controls, ComCtrls, StdCtrls;

type
  TEventEditForm = class(TForm)
    TimeEdit: TDateTimePicker;
    DateEdit: TDateTimePicker;
    OccurEdit: TComboBox;
    NotesMemo: TMemo;
    OkButton: TButton;
    CancelButton: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    editing : boolean;
  public
    procedure injectEvent(event:TRemindEvent);
    { public shit }
  end;

var
  EventEditForm: TEventEditForm;

implementation
uses
  main;

{$R *.dfm}

procedure TEventEditForm.FormCreate(Sender: TObject);
begin
  editing := false;
  DateEdit.Date := Now();
  TimeEdit.Time := Now();
end;

procedure TEventEditForm.injectEvent(event:TRemindEvent);
var
  OccurIndex : integer;
begin
  editing := true;
  with event do begin

    NotesMemo.Lines.Text := Notes;
    DateEdit.Date := Date;
    TimeEdit.Time := Time;

    OccurIndex := OccurEdit.Items.IndexOf(Occur);
    if OccurIndex = -1 then OccurIndex := 0;
    OccurEdit.ItemIndex := OccurIndex;

  end;
end;

procedure TEventEditForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TEventEditForm.OkButtonClick(Sender: TObject);
var
  event:TRemindEvent;
  MainForm:TMainForm;
begin
  event := TRemindEvent.Create();
  with event do begin
    Notes := NotesMemo.Lines.Text;
    Date := DateEdit.Date;
    Time := TimeEdit.Time;
    Occur := OccurEdit.Items[OccurEdit.ItemIndex];
    // 2005-05-17 : super annoying blank occur bug
    if Occur='' then begin
      Occur:='once';
    end;
    Completed := false;
  end;

  MainForm := TMainForm(Owner);

  MainForm.SaveEvents();
  if editing then begin
    MainForm.EditEvent(event);
  end else begin
    MainForm.NewEvent(event);
  end;
  Close;
end;

end.
