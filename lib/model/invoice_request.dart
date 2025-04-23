/// A model representing an invoice request with essential information
/// used to uniquely identify and manage an invoice within the system.
///
/// This class includes the invoice hash, the invoice data, and a unique
/// identifier (UUID) for tracking the request.
class InvoiceRequest {
  /// The unique hash representing the invoice, often used for validation or
  /// verification purposes.
  final String invoiceHash;

  /// The actual invoice data, typically in a structured format (e.g., JSON, XML).
  final String invoice;

  /// A universally unique identifier (UUID) assigned to the invoice request,
  /// used to uniquely identify this particular request.
  final String uuid;

  /// Creates a new instance of [InvoiceRequest].
  ///
  /// - [invoiceHash]: The unique hash for the invoice.
  /// - [invoice]: The invoice data itself.
  /// - [uuid]: The unique identifier for this invoice request.
  const InvoiceRequest({
    required this.invoice,
    required this.invoiceHash,
    required this.uuid,
  });

  /// Creates an instance of [InvoiceRequest] from a map of key-value pairs.
  ///
  /// This is typically used for deserializing data.
  ///
  /// - [map]: A map containing keys "invoice", "invoiceHash", and "uuid".
  static InvoiceRequest fromMap(Map<String, dynamic> map) {
    return InvoiceRequest(
      invoice: map["invoice"],
      invoiceHash: map["invoiceHash"],
      uuid: map["uuid"],
    );
  }

  /// Converts the [InvoiceRequest] instance to a map of key-value pairs.
  ///
  /// This is typically used for serializing data.
  ///
  /// Returns a map with keys "invoiceHash", "invoice", and "uuid".
  Map<String, dynamic> toMap() {
    return {
      "invoiceHash": invoiceHash,
      "invoice": invoice,
      "uuid": uuid,
    };
  }

  /// Returns a string representation of the [InvoiceRequest] for debugging.
  ///
  /// The output includes the [invoiceHash], [invoice], and [uuid].
  @override
  String toString() {
    return 'InvoiceRequest => "invoiceHash": $invoiceHash, "invoice": $invoice, "uuid": $uuid';
  }
}
