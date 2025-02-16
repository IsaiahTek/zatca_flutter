import 'dart:io';
import 'package:xml/xml.dart' as xml;

import '../model/simplified_invoice.dart';

class SimplifiedInvoiceToXmlConverter {
  static String generateXml(SimplifiedInvoice invoice) {
    final builder = xml.XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('Invoice', namespaces: {'cbc': 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'}, nest: () {
      builder.element('cbc:InvoiceTypeCode', nest: "Simplified Invoice"); 
      builder.element('cbc:ID', nest: invoice.invoiceNumber);
      builder.element('cbc:IssueDate', nest: invoice.issueDateTime.toIso8601String());

      // Seller Information
      builder.element('AccountingSupplierParty', nest: () {
        builder.element('Party', nest: () {
          builder.element('cbc:Name', nest: invoice.seller.name);
          builder.element('cbc:VATNumber', nest: invoice.seller.vatNumber);
          builder.element('cbc:Address', nest: invoice.seller.address);
        });
      });

      // Invoice Items
      builder.element('InvoiceLine', nest: () {
        for (var item in invoice.items) {
          builder.element('cbc:Item', nest: () {
            builder.element('cbc:Description', nest: item.description);
            builder.element('cbc:Quantity', nest: item.quantity.toString());
            builder.element('cbc:Price', nest: item.unitPrice.toStringAsFixed(2));
            builder.element('cbc:TaxableAmount', nest: item.taxableAmount.toStringAsFixed(2));
            builder.element('cbc:TaxAmount', nest: item.vatAmount.toStringAsFixed(2));
            builder.element('cbc:TaxPercentage', nest: item.vatRate.toString());
          });
        }
      });

      // Invoice Totals
      builder.element('LegalMonetaryTotal', nest: () {
        builder.element('cbc:LineExtensionAmount', nest: invoice.invoiceTotal.subtotal.toStringAsFixed(2));
        builder.element('cbc:TaxExclusiveAmount', nest: invoice.invoiceTotal.subtotal.toStringAsFixed(2));
        builder.element('cbc:TaxInclusiveAmount', nest: invoice.invoiceTotal.grandTotal.toStringAsFixed(2));
        builder.element('cbc:PayableAmount', nest: invoice.invoiceTotal.grandTotal.toStringAsFixed(2));
      });

      // Additional Elements (UUID, Digital Signature, Hash)
      builder.element('cbc:UUID', nest: invoice.uuid);
      builder.element('cbc:DigitalSignature', nest: invoice.electronicSignature);
      builder.element('cbc:Hash', nest: invoice.hash);
      builder.element('cbc:CryptographicStamp', nest: invoice.cryptographicStamp);

      // Mandatory QR Code
      builder.element('cbc:QRCode', nest: invoice.qrCode);
    });

    final invoiceXml = builder.buildDocument();
    return invoiceXml.toXmlString(pretty: true);
  }

  static Future<void> saveXmlToFile(String xmlString, String filePath) async {
    File file = File(filePath);
    await file.writeAsString(xmlString);
  }
}
