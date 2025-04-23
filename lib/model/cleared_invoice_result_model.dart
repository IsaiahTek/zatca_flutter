import '../enums.dart';
import 'invoice_result_base_model.dart';

/// A model representing the result of a cleared invoice.
///
/// Extends [InvoiceResultBaseModel] to include information specific
/// to cleared invoices, such as their final [status].
class ClearedInvoiceResultModel extends InvoiceResultBaseModel {
  /// The final status of the cleared invoice.
  ///
  /// This status indicates the outcome of the invoice clearing process,
  /// such as whether it was accepted, rejected, or had issues.
  final ClearedInvoiceResultStatus status;

  /// Creates a new instance of [ClearedInvoiceResultModel].
  ///
  /// All parameters are required and are passed to the base model or
  /// assigned directly to this class.
  ///
  /// - [status]: The result status of the invoice.
  /// - [errors]: Any errors encountered during processing.
  /// - [invoiceHash]: The unique hash of the invoice.
  /// - [warnings]: Any warnings associated with the invoice.
  const ClearedInvoiceResultModel({
    required this.status,
    required super.errors,
    required super.invoiceHash,
    required super.warnings,
  });
}
