import '../enums.dart';
import '../model/error_model.dart';
import '../model/info_model.dart';
import '../model/warning_model.dart';

/// A general-purpose response model from the Fatoora service.
///
/// This class aggregates response metadata including status, errors,
/// warnings, and informational messages.
class FatooraServiceResponse {
  /// Indicates the result of the operation (e.g., success, failure).
  ResponseStatus status;

  /// A list of errors that occurred during the operation, if any.
  List<ErrorModel>? errors;

  /// A list of warnings related to the request or operation, if any.
  List<WarningModel>? warnings;

  /// Informational messages returned with the response, if any.
  List<InfoModel>? infos;

  /// Creates a new instance of [FatooraServiceResponse].
  ///
  /// - [status]: The status of the response.
  /// - [errors]: A list of [ErrorModel] instances (optional).
  /// - [warnings]: A list of [WarningModel] instances (optional).
  /// - [infos]: A list of [InfoModel] instances (optional).
  FatooraServiceResponse({
    required this.status,
    this.errors,
    this.infos,
    this.warnings,
  });
}

/// A specialized response model for CSR (Certificate Signing Request)
/// operations through the Fatoora service.
///
/// It includes a generic response object and the output file names
/// for the generated CSR and private key files.
class FatooraServiceCsrResponse {
  /// The service response object containing the operation status,
  /// errors, warnings, or infos.
  FatooraServiceResponse response;

  /// The output file name where the CSR was saved or generated.
  String csrOutputFileName;

  /// The output file name where the private key was saved or generated.
  String keyOutputFileName;

  /// Creates a new instance of [FatooraServiceCsrResponse].
  ///
  /// - [csrOutputFileName]: The file name for the CSR output.
  /// - [keyOutputFileName]: The file name for the key output.
  /// - [response]: The associated [FatooraServiceResponse] object.
  FatooraServiceCsrResponse({
    required this.csrOutputFileName,
    required this.keyOutputFileName,
    required this.response,
  });
}
