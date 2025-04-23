import 'error_model.dart';
import 'warning_model.dart';

/// A base model representing the common result structure for invoices.
///
/// This class is used as a base for more specific invoice result models,
/// providing essential fields such as the invoice hash, error list, and
/// warning list. This model is meant to be extended for handling different
/// types of invoice responses.
abstract class InvoiceResultBaseModel {
  /// The unique hash identifier for the invoice.
  ///
  /// This hash is typically used for validation, verification, or tracking
  /// the invoice within the system.
  final String invoiceHash;

  // /// The status of the invoice result (commented out for future use).
  // final status;

  /// A list of errors encountered during the invoice processing.
  ///
  /// Each error provides specific information about what went wrong,
  /// often represented by an [ErrorModel].
  final List<ErrorModel> errors;

  /// A list of warnings that may be present during the invoice processing.
  ///
  /// Warnings are typically less critical than errors but may still require
  /// attention or further action, represented by a [WarningModel].
  final List<WarningModel> warnings;

  /// Creates a new instance of [InvoiceResultBaseModel].
  ///
  /// - [invoiceHash]: The unique hash identifier for the invoice.
  /// - [errors]: A list of [ErrorModel] instances detailing any errors.
  /// - [warnings]: A list of [WarningModel] instances detailing any warnings.
  const InvoiceResultBaseModel({
    required this.invoiceHash,
    required this.errors,
    // required this.status, // Uncomment and define status when needed.
    required this.warnings,
  });
}
