import '../enums.dart';
import '../model/error_model.dart';
import '../model/info_model.dart';
import '../model/warning_model.dart';

class FatooraCliResponse{
  ResponseStatus status;
  List<ErrorModel>? errors;
  List<WarningModel>? warnings;
  List<InfoModel>? infos;

  FatooraCliResponse({
    required this.status,
    this.errors,
    this.infos,
    this.warnings
  });
}

class FatooraCliCsrResponse{

  FatooraCliResponse response;
  String csrOutputFileName;
  String keyOutputFileName;

  FatooraCliCsrResponse({
    required this.csrOutputFileName,
    required this.keyOutputFileName,
    required this.response
  });

}