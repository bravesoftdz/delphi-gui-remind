object EventEditForm: TEventEditForm
  Left = 363
  Top = 244
  Width = 481
  Height = 269
  BorderIcons = [biSystemMenu]
  Caption = 'Edit Event'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 8
    Top = 8
    Width = 28
    Height = 13
    Caption = 'Notes'
  end
  object Label6: TLabel
    Left = 8
    Top = 160
    Width = 23
    Height = 13
    Caption = 'Date'
  end
  object Label7: TLabel
    Left = 200
    Top = 160
    Width = 23
    Height = 13
    Caption = 'Time'
  end
  object Label8: TLabel
    Left = 296
    Top = 160
    Width = 29
    Height = 13
    Caption = 'Occur'
  end
  object TimeEdit: TDateTimePicker
    Left = 200
    Top = 176
    Width = 89
    Height = 21
    BevelInner = bvNone
    BevelOuter = bvNone
    Date = 0.057638888888888900
    Time = 0.057638888888888900
    Kind = dtkTime
    TabOrder = 2
  end
  object DateEdit: TDateTimePicker
    Left = 8
    Top = 176
    Width = 186
    Height = 21
    BevelInner = bvNone
    BevelOuter = bvNone
    Date = 0.103880127302546000
    Time = 0.103880127302546000
    DateFormat = dfLong
    TabOrder = 1
  end
  object OccurEdit: TComboBox
    Left = 296
    Top = 176
    Width = 169
    Height = 21
    BevelInner = bvNone
    BevelOuter = bvNone
    ItemHeight = 13
    TabOrder = 3
    Text = 'once'
    Items.Strings = (
      'once'
      'daily'
      'weekly'
      'monthly'
      'every 3 months'
      'every 6 months'
      'yearly')
  end
  object NotesMemo: TMemo
    Left = 8
    Top = 24
    Width = 457
    Height = 129
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object OkButton: TButton
    Left = 304
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 392
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = CancelButtonClick
  end
end
