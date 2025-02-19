import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';
import 'package:zatca_flutter/model/invoice_request.dart';

class FatooraInvoiceRequestApiResponse {
  final ResponseStatus status;
  final InvoiceRequest? invoiceRequest;
  final FatooraServiceResponse response;

  const FatooraInvoiceRequestApiResponse({required this.status, required this.invoiceRequest, required this.response});
}