unit DataAware.TDBTrackBar;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, Vcl.DBCtrls, Data.DB, Winapi.Messages;

type
  TDBTrackBar = class(TTrackBar)
  private
    FDataLink: TFieldDataLink;
    function GetDataField: string;
    procedure SetDataField(Value: string);
    function GetDataSource: TDataSource;
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CNHScroll(var Message: TWMHScroll); message CN_HSCROLL;
    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    procedure DataChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);
    procedure ActiveChange(Sender: TObject);
  public
    procedure SetPosition(const pos: Integer);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Data Controls', [TDBTrackBar]);
end;

{ TDBTrackBar }

procedure TDBTrackBar.ActiveChange(Sender: TObject);
begin
  Enabled := FDataLink.Active and (FDataLink.Field <> nil) and
    not FDataLink.Field.ReadOnly;
end;

procedure TDBTrackBar.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TDBTrackBar.CNHScroll(var Message: TWMHScroll);
begin
  FDataLink.Edit;
  inherited;
  FDataLink.Modified;
end;

procedure TDBTrackBar.CNVScroll(var Message: TWMVScroll);
begin
  FDataLink.Edit;
  inherited;
  FDataLink.Modified;
end;

constructor TDBTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FDataLink.OnActiveChange := ActiveChange;
  Enabled := False;
end;

procedure TDBTrackBar.DataChange(Sender: TObject);
begin
  if FDataLink.Field is TNumericField then
    Position := FDataLink.Field.AsInteger
  else
    Position := Min;
end;

destructor TDBTrackBar.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited;
end;

function TDBTrackBar.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDBTrackBar.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TDBTrackBar.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TDBTrackBar.SetDataField(Value: string);
begin
  try
    FDataLink.FieldName := Value;
  finally
    Enabled := FDataLink.Active and (FDataLink.Field <> nil) and
      not FDataLink.Field.ReadOnly;
  end;
end;

procedure TDBTrackBar.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  Enabled := FDataLink.Active and (FDataLink.Field <> nil) and
    not FDataLink.Field.ReadOnly;
end;

procedure TDBTrackBar.SetPosition(const pos: Integer);
begin
  FDataLink.Edit;
  Position := pos;
  FDataLink.Modified;
end;

procedure TDBTrackBar.UpdateData(Sender: TObject);
begin
  if FDataLink.Field is TNumericField then
    FDataLink.Field.AsInteger := Position;
end;

end.

