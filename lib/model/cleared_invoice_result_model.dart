import '../enums.dart';
import 'invoice_result_base_model.dart';

class ClearedInvoiceResultModel extends InvoiceResultBaseModel{
  final ClearedInvoiceResultStatus status;

  const ClearedInvoiceResultModel({
    required this.status,
    required super.errors,
    required super.invoiceHash,
    required super.warnings,
  });
}