import 'error_model.dart';
import 'warning_model.dart';

abstract class InvoiceResultBaseModel {
  final String invoiceHash;
  // final status;
  final List<ErrorModel> errors;
  final List<WarningModel> warnings;

  const InvoiceResultBaseModel({
    required this.invoiceHash,
    required this.errors,
    // required this.status,
    required this.warnings
  });

}