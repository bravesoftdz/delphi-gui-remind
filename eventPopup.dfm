object EventPopupForm: TEventPopupForm
  Left = 206
  Top = 159
  Width = 417
  Height = 158
  ActiveControl = OkButton
  Caption = 'EventPopupForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 400
    Height = 89
    ReadOnly = True
    TabOrder = 0
  end
  object OkButton: TButton
    Left = 328
    Top = 104
    Width = 80
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = OkButtonClick
  end
  object Edit: TEdit
    Left = 72
    Top = 104
    Width = 33
    Height = 21
    TabOrder = 2
    Text = '10'
  end
  object Checkbox: TCheckBox
    Left = 8
    Top = 106
    Width = 57
    Height = 17
    Caption = 'Snooze'
    TabOrder = 3
  end
  object ComboBox: TComboBox
    Left = 112
    Top = 104
    Width = 121
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = 'minutes'
    Items.Strings = (
      'minutes'
      'hours')
  end
  object EditButton: TButton
    Left = 240
    Top = 104
    Width = 80
    Height = 25
    Caption = 'Edit'
    TabOrder = 5
    OnClick = EditButtonClick
  end
end
