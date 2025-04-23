import 'package:xml/xml.dart';

/// Represents the billing reference for an invoice, typically used in tax-related documents.
///
/// This class models the reference information for an invoice, which includes the invoice number
/// and the issue date. This information is often required when referencing an invoice in subsequent
/// transactions or documents.
///
/// It includes the following properties:
/// - [invoiceNumber]: The unique identifier for the invoice.
/// - [invoiceIssueDate]: The date when the invoice was issued.
class BillingReference {
  /// The unique identifier for the invoice.
  final int invoiceNumber;

  /// The date when the invoice was issued.
  final DateTime invoiceIssueDate;

  /// Constructs a [BillingReference] instance with the specified [invoiceNumber] and [invoiceIssueDate].
  ///
  /// [invoiceNumber] is the unique identifier for the invoice.
  /// [invoiceIssueDate] is the date when the invoice was issued.
  BillingReference(
      {required this.invoiceIssueDate, required this.invoiceNumber});

  /// Converts the [BillingReference] instance to an XML representation using the [XmlBuilder].
  ///
  /// This method constructs the XML structure for the billing reference, which includes the invoice
  /// number and the issue date formatted according to ISO 8601.
  ///
  /// Example:
  /// ```dart
  /// XmlBuilder builder = XmlBuilder();
  /// billingReference.toXml(builder);
  /// ```
  void toXml(XmlBuilder builder) {
    builder.element('cac:BillingReference', nest: () {
      // Invoice document reference element
      builder.element('cac:InvoiceDocumentReference', nest: () {
        // Invoice ID element containing the invoice number and issue date
        builder.element('cbc:ID',
            nest:
                'Invoice Number: $invoiceNumber; Invoice Issue Date: ${invoiceIssueDate.toIso8601String().split('T')[0]}');
      });
    });
  }
}
