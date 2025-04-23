import '../enums.dart';
import 'invoice_result_base_model.dart';

/// A model representing the result of an invoice processing operation,
/// extending from [InvoiceResultBaseModel].
///
/// This model includes the status of the invoice result, the cleared invoice,
/// and inherits common fields such as the invoice hash, errors, and warnings.
class InvoiceResultModel extends InvoiceResultBaseModel {
  /// The status of the invoice result, which can represent success, failure,
  /// or other relevant states.
  final InvoiceResultStatus status;

  /// The cleared invoice, which is typically a reference to the processed invoice
  /// that has been cleared for reporting or further operations.
  final String clearedInvoice;

  /// Creates a new instance of [InvoiceResultModel].
  ///
  /// - [status]: The status of the invoice result, represented by an [InvoiceResultStatus].
  /// - [clearedInvoice]: The cleared invoice data.
  /// - [errors]: A list of [ErrorModel] instances representing any errors.
  /// - [invoiceHash]: The unique hash identifier for the invoice.
  /// - [warnings]: A list of [WarningModel] instances representing any warnings.
  const InvoiceResultModel({
    required this.status,
    required this.clearedInvoice,
    required super.errors,
    required super.invoiceHash,
    required super.warnings,
  });
}
