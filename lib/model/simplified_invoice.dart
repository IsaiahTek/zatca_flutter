import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:zatca_flutter/model/invoice_line.dart';
import 'package:zatca_flutter/model/legal_monetary_total.dart';
import 'package:zatca_flutter/model/tax_details.dart';

import 'party.dart';

class SimplifiedInvoice {
  String id;
  int icv;
  String uuid;
  DateTime issueDate;
  DateTime issueTime;
  String typeCode;
  String currency;
  SupplierParty supplier;
  Party customer;
  List<InvoiceLine> lines;
  TaxDetails tax;
  LegalMonetaryTotal monetaryTotal;
  String pih;

  SimplifiedInvoice({
    required this.icv,
    required this.id,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.typeCode,
    required this.currency,
    required this.supplier,
    required this.customer,
    required this.lines,
    required this.tax,
    required this.monetaryTotal,
    // this.isFirstInvoice = false,
    required this.pih,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "issueDate": issueDate.toIso8601String().split('T')[0],
      "issuedTime": issueTime.toIso8601String().split('T')[1].split('.')[0],
      "typeCode": typeCode,
      "currency": currency,
      "supplier": supplier,
      "customer": customer,
      "lines": lines.map((item) => item.toJson()).toList(),
      "tax": tax.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  String toXml(XmlBuilder builder) {
    builder.element('Invoice', namespaces: {
      "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2": "",
      "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2":
          "cac",
      "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2":
          "cbc",
      "urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2":
          "ext"
    }, nest: () {
      builder.element('cbc:ProfileID', nest: 'reporting:1.0');
      builder.element('cbc:ID', nest: id);
      builder.element('cbc:UUID', nest: uuid);
      builder.element('cbc:IssueDate',
          nest: issueDate.toIso8601String().split('T')[0]);
      builder.element('cbc:IssueTime',
          nest: issueTime.toIso8601String().split('T')[1].split('.')[0]);
      builder.element('cbc:InvoiceTypeCode',
          nest: '388', attributes: {'name': '0200000'});
      builder.element('cbc:DocumentCurrencyCode', nest: currency);
      // builder.element('cbc:Note', nest: 'en');
      builder.element('cbc:TaxCurrencyCode', nest: currency);

      builder.element('cac:AdditionalDocumentReference', nest: () {
        builder.element('cbc:ID', nest: 'ICV');
        builder.element('cbc:UUID', nest: icv);
      });

      builder.element('cac:AdditionalDocumentReference', nest: () {
        builder.element('cbc:ID', nest: 'PIH');
        builder.element('cac:Attachment', nest: () {
          builder.element('cbc:EmbeddedDocumentBinaryObject',
              attributes: {'mimeCode': 'text/plain'}, nest: pih);
        });
      });

      builder.element('cac:AccountingSupplierParty',
          nest: () => supplier.toXml(builder));
      builder.element('cac:AccountingCustomerParty',
          nest: () => customer.toXml(builder));

      builder.element('cac:TaxTotal', nest: () => tax.toXml(builder));
      builder.element('cac:LegalMonetaryTotal',
          nest: () => monetaryTotal.toXml(builder));

      for (int id = 0; id < lines.length; id++) {
        InvoiceLine line = lines[id];
        builder.element('cac:InvoiceLine', nest: () => line.toXml(builder, id));
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }
}
