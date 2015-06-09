library dvoa;

uses
  SysUtils,
  Predictor in 'Predictor.pas',
  IoFmt in 'IoFmt.pas',
  AntGain in '..\DVoaClass\AntGain.pas',
  FrMaps in '..\DVoaClass\FrMaps.pas',
  IonoProf in '..\DVoaClass\IonoProf.pas',
  LayrParm in '..\DVoaClass\LayrParm.pas',
  MagFld in '..\DVoaClass\MagFld.pas',
  MufCalc in '..\DVoaClass\MufCalc.pas',
  NoiseMdl in '..\DVoaClass\NoiseMdl.pas',
  PathGeom in '..\DVoaClass\PathGeom.pas',
  Reflx in '..\DVoaClass\Reflx.pas',
  SinCos in '..\DVoaClass\SinCos.pas',
  Sun in '..\DVoaClass\Sun.pas',
  VoaCapEng in '..\DVoaClass\VoaCapEng.pas',
  VoaTypes in '..\DVoaClass\VoaTypes.pas',
  superobject in '3rdParty_Json\superobject.pas';

{$R *.res}

var
  OutStr: AnsiString;

type
  //error at user's side
  Exception400 = class(Exception);
  //error at engine's side
  Exception500 = class(Exception);


function Predict(ArgsStr: PAnsiChar): PAnsiChar; stdcall;
var
  Request: TVoaRequest;
  Reply: TVoaReply;
begin
  try
    case ArgsStr[0] of
      '<': Request := XmlToVoaRequest(ArgsStr);
      '{': Request := JsonToVoaRequest(ArgsStr);
      else Abort;
    end;
  except on E: Exception do
    raise Exception400.Create('Error parsing input parameters');
  end;

  try
    Reply := PrPr.Predict(Request);

    case Request.OutFormat of
      fmtXml: OutStr := VoaReplyToXml(Reply, Request);
      fmtJson: OutStr := VoaReplyToJson(Reply, Request);
      fmtCsv: OutStr := VoaReplyToCsv(Reply, Request);
      fmtVoa: OutStr := VoaReplyToVoaTxt(Reply, Request);
    end;
  except on E: Exception do
    raise Exception500.Create('Error computing prediction: ' + E.Message);
  end;

  Result := PAnsiChar(OutStr);
end;


exports
  Predict;


begin
end.

