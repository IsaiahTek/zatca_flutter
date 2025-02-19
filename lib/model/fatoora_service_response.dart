import '../enums.dart';
import '../model/error_model.dart';
import '../model/info_model.dart';
import '../model/warning_model.dart';

class FatooraServiceResponse{
  ResponseStatus status;
  List<ErrorModel>? errors;
  List<WarningModel>? warnings;
  List<InfoModel>? infos;

  FatooraServiceResponse({
    required this.status,
    this.errors,
    this.infos,
    this.warnings
  });
}

class FatooraServiceCsrResponse{

  FatooraServiceResponse response;
  String csrOutputFileName;
  String keyOutputFileName;

  FatooraServiceCsrResponse({
    required this.csrOutputFileName,
    required this.keyOutputFileName,
    required this.response
  });

}