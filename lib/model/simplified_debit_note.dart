// Simplified Debit Note Model to hold the necessary data
class SimplifiedDebitNote {
  final String invoiceNumber;
  final String issueDate;
  final String issueTime;
  final String supplierTaxId;
  final String supplierName;
  final String customerTaxId;
  final String customerName;
  final String documentCurrency;
  final String taxCurrency;
  final String referenceInvoiceNumber;
  final String referenceInvoiceDate;
  final String uuid;

  SimplifiedDebitNote({
    required this.invoiceNumber,
    required this.issueDate,
    required this.issueTime,
    required this.supplierTaxId,
    required this.supplierName,
    required this.customerTaxId,
    required this.customerName,
    required this.documentCurrency,
    required this.taxCurrency,
    required this.referenceInvoiceNumber,
    required this.referenceInvoiceDate,
    required this.uuid,
  });
}
