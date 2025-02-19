
import 'package:xml/xml.dart';
import 'package:zatca_flutter/model/simplified_debit_note.dart';

class SimplifiedDebitNoteGenerator {
  final SimplifiedDebitNote model;

  SimplifiedDebitNoteGenerator({required this.model});

  String generate() {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('Invoice', nest: () {
      builder.namespace('urn:oasis:names:specification:ubl:schema:xsd:Invoice-2');
      builder.namespace('cbc', 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2');
      builder.namespace('cac', 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2');
      builder.namespace('ext', 'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2');

      // UBL Extensions
      builder.element('ext:UBLExtensions', nest: () {
        builder.element('ext:UBLExtension', nest: () {
          builder.element('ext:ExtensionURI', nest: 'urn:oasis:names:specification:ubl:dsig:enveloped:xades');
          builder.element('ext:ExtensionContent', nest: () {
            builder.element('sig:UBLDocumentSignatures', namespace: 'urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2', nest: () {
              builder.element('sac:SignatureInformation', namespace: 'urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2', nest: () {
                builder.element('cbc:ID', nest: 'urn:oasis:names:specification:ubl:signature:1');
                builder.element('sbc:ReferencedSignatureID', nest: 'urn:oasis:names:specification:ubl:signature:Invoice');
                builder.element('ds:Signature', namespace: 'http://www.w3.org/2000/09/xmldsig#', nest: () {
                  builder.element('ds:SignedInfo', nest: () {
                    builder.element('ds:CanonicalizationMethod', attributes: {'Algorithm': 'http://www.w3.org/2006/12/xml-c14n11'});
                    builder.element('ds:SignatureMethod', attributes: {'Algorithm': 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256'});
                  });
                });
              });
            });
          });
        });
      });

      // Basic Invoice Info
      builder.element('cbc:ProfileID', nest: 'reporting:1.0');
      builder.element('cbc:ID', nest: model.invoiceNumber);
      builder.element('cbc:UUID', nest: model.uuid);
      builder.element('cbc:InvoiceTypeCode', nest: '381');
      builder.element('cbc:IssueDate', nest: model.issueDate);
      builder.element('cbc:IssueTime', nest: model.issueTime);
      builder.element('cbc:DocumentCurrencyCode', nest: model.documentCurrency);
      builder.element('cbc:TaxCurrencyCode', nest: model.taxCurrency);

      // Billing Reference
      builder.element('cac:BillingReference', nest: () {
        builder.element('cac:InvoiceDocumentReference', nest: () {
          builder.element('cbc:ID', nest: model.referenceInvoiceNumber);
          builder.element('cbc:IssueDate', nest: model.referenceInvoiceDate);
        });
      });

      // Supplier Party
      builder.element('cac:AccountingSupplierParty', nest: () {
        builder.element('cac:Party', nest: () {
          builder.element('cac:PartyIdentification', nest: () {
            builder.element('cbc:ID', attributes: {'schemeID': 'CRN'}, nest: model.supplierTaxId);
          });
          builder.element('cac:PartyLegalEntity', nest: () {
            builder.element('cbc:RegistrationName', nest: model.supplierName);
          });
        });
      });

      // Customer Party
      builder.element('cac:AccountingCustomerParty', nest: () {
        builder.element('cac:Party', nest: () {
          builder.element('cac:PartyIdentification', nest: () {
            builder.element('cbc:ID', attributes: {'schemeID': 'CRN'}, nest: model.customerTaxId);
          });
          builder.element('cac:PartyLegalEntity', nest: () {
            builder.element('cbc:RegistrationName', nest: model.customerName);
          });
        });
      });
    });

    final xmlDocument = builder.buildDocument();
    return xmlDocument.toXmlString(pretty: true);
  }

}