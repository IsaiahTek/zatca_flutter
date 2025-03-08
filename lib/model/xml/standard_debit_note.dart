// Simplified Debit Note Model to hold the necessary data
import 'package:xml/xml.dart';
import 'package:zatca_flutter/model/xml/allowance_charge.dart';
import 'package:zatca_flutter/model/xml/billing_reference.dart';
import 'package:zatca_flutter/model/xml/delivery.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/model/xml/payment_means.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/service/util.dart';

class SimplifiedDebitNote {
  String id;
  int icv;
  String uuid;
  DateTime issueDate;
  DateTime issueTime;
  String currency;
  BusinessParty supplier;
  BusinessParty customer;
  List<InvoiceLine> lines;
  TaxDetails tax;
  LegalMonetaryTotal monetaryTotal;
  String pih;
  BillingReference billingReference;
  Delivery delivery;
  PaymentMeans paymentMeans;
  AllowanceCharge? allowanceCharge;

  SimplifiedDebitNote({
    required this.icv,
    required this.id,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.currency,
    required this.supplier,
    required this.customer,
    required this.lines,
    required this.tax,
    required this.monetaryTotal,
    // this.isFirstInvoice = false,
    required this.pih,
    required this.billingReference,
    required this.paymentMeans,
    required this.delivery,
    this.allowanceCharge,
  });

  String toXml(){
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
          nest: '381', attributes: {'name': '0211010'});
      builder.element('cbc:DocumentCurrencyCode', nest: currency);
      // builder.element('cbc:Note', nest: 'en');
      builder.element('cbc:TaxCurrencyCode', nest: currency);

      // Build the BillingReference element.
      billingReference.toXml(builder);

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
          nest: () => supplier.toXml(builder));
      builder.element('cac:AccountingCustomerParty',
          nest: () => customer.toXml(builder));

      // Delivery builder
      delivery.toXml(builder);

      // PaymentMeans Builder
      paymentMeans.toXml(builder);

      // AllowanceCharge builder
      allowanceCharge?.toXml(builder);

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
    saveToFile(toXml(), fileName);
  }
}
