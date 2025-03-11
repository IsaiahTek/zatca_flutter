import '../enums.dart';
import '../model/fatoora_service_response.dart';

class FatooraInvoiceHashResponse {
  final ResponseStatus status;
  final FatooraServiceResponse response;
  final String? hashValue;

  const FatooraInvoiceHashResponse(
      {required this.hashValue, required this.response, required this.status});
}
