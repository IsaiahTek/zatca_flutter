import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';

/// A model representing the response received after generating or requesting
/// a QR code for a Fatoora-compliant invoice.
///
/// This includes the operation [status], detailed [response] from the service,
/// and the generated [qrCode] if the operation was successful.
class FatooraQrCodeResponse {
  /// The status of the QR code generation request (e.g., success, failure).
  final ResponseStatus status;

  /// The full response from the Fatoora service, containing additional
  /// metadata, messages, or error details.
  final FatooraServiceResponse response;

  /// The generated QR code string, typically base64-encoded.
  ///
  /// This may be null if the QR code generation failed.
  final String? qrCode;

  /// Creates a new instance of [FatooraQrCodeResponse].
  ///
  /// - [status]: Indicates the result of the QR code generation request.
  /// - [response]: Contains service metadata and messages.
  /// - [qrCode]: The generated QR code string, if available.
  const FatooraQrCodeResponse({
    required this.qrCode,
    required this.response,
    required this.status,
  });

  // Map<String, dynamic> toJson(){
  //   return {"qrCode": qrCode, "status": status, "response" : response.toJson()};
  // }
}
