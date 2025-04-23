import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';
import 'package:zatca_flutter/model/invoice_request.dart';

/// A model representing the API response received after submitting
/// or processing an invoice request via the Fatoora service.
///
/// This response includes the [status] of the request, the original
/// [invoiceRequest] if applicable, and the full [response] details from the service.
class FatooraInvoiceRequestApiResponse {
  /// The status indicating the result of the API request (e.g., success, failure).
  final ResponseStatus status;

  /// The original invoice request submitted to the API.
  ///
  /// This may be null if the request was not processed or reconstructed.
  final InvoiceRequest? invoiceRequest;

  /// The complete response from the Fatoora service, including metadata or errors.
  final FatooraServiceResponse response;

  /// Creates a new instance of [FatooraInvoiceRequestApiResponse].
  ///
  /// - [status]: The outcome of the request.
  /// - [invoiceRequest]: The invoice data that was submitted (if available).
  /// - [response]: The response received from the Fatoora service.
  const FatooraInvoiceRequestApiResponse({
    required this.status,
    required this.invoiceRequest,
    required this.response,
  });
}
