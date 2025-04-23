import '../enums.dart';
import '../model/fatoora_service_response.dart';

/// A model representing the response received after generating or retrieving
/// the hash value of a Fatoora invoice.
///
/// This includes the operation's [status], the detailed [response],
/// and the resulting [hashValue] if successful.
class FatooraInvoiceHashResponse {
  /// The status of the response indicating success, failure, or other outcomes.
  final ResponseStatus status;

  /// The full response object from the Fatoora service, which may contain
  /// additional metadata or error details.
  final FatooraServiceResponse response;

  /// The computed or returned hash value of the invoice, if available.
  ///
  /// This value is typically used for validation or digital signing.
  final String? hashValue;

  /// Creates a new instance of [FatooraInvoiceHashResponse].
  ///
  /// - [status]: The result status of the operation.
  /// - [response]: The full response from the Fatoora service.
  /// - [hashValue]: The resulting invoice hash, if applicable.
  const FatooraInvoiceHashResponse({
    required this.hashValue,
    required this.response,
    required this.status,
  });
}
