import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:zatca_flutter/local_store.dart';
import 'package:zatca_flutter/model/my_business_info.dart';
import 'package:zatca_flutter/model/xml/delivery.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/service/util.dart';

import 'party.dart';

class StandardInvoice {
  String id;
  int icv;
  String uuid;
  DateTime issueDate;
  DateTime issueTime;
  String currency;
  BusinessParty customer;
  List<InvoiceLine> lines;
  TaxDetails tax;
  LegalMonetaryTotal monetaryTotal;
  String pih;
  Delivery delivery;

  MyBusinessInfo? get supplier => LocalStore.instance.myBusinessInfo;

  StandardInvoice({
    required this.icv,
    required this.id,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.currency,
    required this.customer,
    required this.lines,
    required this.tax,
    required this.monetaryTotal,
    // this.isFirstInvoice = false,
    required this.pih,
    required this.delivery
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "issueDate": issueDate.toIso8601String().split('T')[0],
      "issuedTime": issueTime.toIso8601String().split('T')[1].split('.')[0],
      "currency": currency,
      "supplier": supplier,
      "customer": customer,
      "lines": lines.map((item) => item.toJson()).toList(),
      "tax": tax.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
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
          nest: '388', attributes: {'name': '0100000'});
      builder.element('cbc:DocumentCurrencyCode', nest: currency);
      // builder.element('cbc:Note', nest: 'en');
      builder.element('cbc:TaxCurrencyCode', nest: currency);

      // if(pih.isEmpty){
      //   builder.element('cbc:PreviousInvoiceHash', nest: 'urn:ietf:rfc:3986');
      // }

      builder.element('cac:AdditionalDocumentReference', nest: () {
        builder.element('cbc:ID', nest: 'ICV');
        builder.element('cbc:UUID', nest: icv);
      });
      
      builder.element('cac:AdditionalDocumentReference', nest: () {
        builder.element('cbc:ID', nest: 'PIH');
        builder.element('cac:Attachment', nest: () {
          builder.element('cbc:EmbeddedDocumentBinaryObject',
              attributes: {'mimeCode': 'text/plain'}, nest: pih.isEmpty?getPIHForFirstInvoice():pih);
        });
      });

      builder.element('cac:AccountingSupplierParty',
          nest: () => supplier?.toXml(builder));
      builder.element('cac:AccountingCustomerParty',
          nest: () => customer.toXml(builder));

      // Delivery builder
      delivery.toXml(builder);

      // builder.element('cac:AllowanceCharge', nest: (){
      //   builder.element('cbc:ChargeIndicator', nest: false);
      //   builder.element('cbc:AllowanceChargeReason', nest: 'discount');
      //   builder.element('cbc:Amount', attributes: {'currencyID': 'SAR'}, nest:0.00);
      //   builder.element('cac:TaxCategory', nest: (){
      //     builder.element('cbc:ID', attributes: {'schemeID': 'UN/ECE 5305', 'schemeAgencyID': '6'}, nest: 'S');
      //     builder.element('cbc:Percent', nest: tax.percent);
      //     builder.element('cac:TaxScheme', nest: (){
      //       builder.element('cbc:ID', attributes: {'schemeID': 'UN/ECE 5153', 'schemeAgencyID': '6'}, nest: 'VAT');
      //     });
      //   });
      // });

      builder.element('cac:TaxTotal', nest:(){
        builder.element('cbc:TaxAmount', attributes: {'currencyID': tax.currency}, nest: tax.amount);
      });
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

  Future<void> generateAndSaveXml(String fileName)async{
    await saveToFile(toXml(), fileName);
  }
  
}
