import '../enums.dart';
import 'invoice_result_base_model.dart';

class InvoiceResultModel extends InvoiceResultBaseModel {
  final InvoiceResultStatus status;
  final String clearedInvoice;

  const InvoiceResultModel({
    required this.status,
    required this.clearedInvoice,
    required super.errors,
    required super.invoiceHash,
    required super.warnings,
  });
}
