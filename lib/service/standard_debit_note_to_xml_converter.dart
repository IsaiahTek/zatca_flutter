import 'dart:io';
import 'package:xml/xml.dart' as xml;

import '../model/standard_debit_note.dart';

class StandardDebitNoteToXmlConverter {
  static String generateXml(StandardDebitNote debitNote) {
    final builder = xml.XmlBuilder();

    // XML declaration
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    // Root element
    builder.element('DebitNote', namespaces: {'cbc': 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'}, nest: () {
      builder.element('cbc:InvoiceTypeCode', nest: "SimpleDebitNote");
      builder.element('cbc:ID', nest: debitNote.id);
      builder.element('cbc:UUID', nest: debitNote.uuid);
      builder.element('cbc:IssueDate', nest: debitNote.issueDate);
      builder.element('cbc:IssueTime', nest: debitNote.issueTime);
      builder.element('cbc:DocumentCurrencyCode', nest: debitNote.documentCurrencyCode);
      builder.element('cbc:TaxCurrencyCode', nest: debitNote.taxCurrencyCode);

      // Billing Reference
      builder.element('BillingReference', nest: () {
        builder.element('cbc:InvoiceDocumentReference', nest: () {
          builder.element('cbc:ID', nest: debitNote.billingReference.invoiceDocumentReference.id);
        });
      });

      // Additional Document References
      builder.element('AdditionalDocumentReferences', nest: () {
        for (var reference in debitNote.additionalDocumentReferences) {
          builder.element('cbc:ID', nest: reference.id);
          builder.element('cbc:UUID', nest: reference.uuid);
        }
      });

      // Signature
      builder.element('Signature', nest: () {
        builder.element('cbc:ID', nest: debitNote.signature.signatureInformation.id);
        builder.element('cbc:ReferencedSignatureID', nest: debitNote.signature.signatureInformation.referencedSignatureID);
        builder.element('cbc:SignatureValue', nest: debitNote.signature.signatureInformation.signatureValue);
      });

      // Accounting Supplier Party
      builder.element('AccountingSupplierParty', nest: () {
        builder.element('Party', nest: () {
          builder.element('cbc:ID', nest: debitNote.accountingSupplierParty.party.partyIdentification.id);
          builder.element('cbc:Name', nest: debitNote.accountingSupplierParty.party.partyIdentification.name);
        });
      });

      // Accounting Customer Party
      builder.element('AccountingCustomerParty', nest: () {
        builder.element('Party', nest: () {
          builder.element('cbc:ID', nest: debitNote.accountingCustomerParty.party.partyIdentification.id);
          builder.element('cbc:Name', nest: debitNote.accountingCustomerParty.party.partyIdentification.name);
        });
      });

      // Delivery Information
      builder.element('Delivery', nest: () {
        builder.element('cbc:ActualDeliveryDate', nest: debitNote.delivery.actualDeliveryDate);
      });
    });

    // Build the document and return as string
    final debitNoteXml = builder.buildDocument();
    return debitNoteXml.toXmlString(pretty: true);
  }

  static Future<void> saveXmlToFile(String xmlString, String filePath) async {
    File file = File(filePath);
    await file.writeAsString(xmlString);
  }
}
