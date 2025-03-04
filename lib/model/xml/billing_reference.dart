import 'package:xml/xml.dart';

class BillingReference {
  int invoiceNumber;
  DateTime invoiceIssueDate;

  BillingReference(
      {required this.invoiceIssueDate, required this.invoiceNumber});

  toXml(XmlBuilder builder) {
    builder.element('cac:BillingReference', nest: () {
      builder.element('cac:InvoiceDocumentReference', nest: () {
        builder.element('cbc:ID',
            nest:
                'Invoice Number: $invoiceNumber; Invoice Issue Date: ${invoiceIssueDate.toIso8601String().split('T')[0]}');
      });
    });
  }
}
