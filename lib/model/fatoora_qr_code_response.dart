import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';

class FatooraQrCodeResponse {
  final ResponseStatus status;
  final FatooraServiceResponse response;
  final String? qrCode;

  const FatooraQrCodeResponse({
    required this.qrCode,
    required this.response,
    required this.status
  });
}