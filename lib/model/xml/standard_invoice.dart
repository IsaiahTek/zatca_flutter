import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:zatca_flutter/local_store.dart';
import 'package:zatca_flutter/model/my_business_info.dart';
import 'package:zatca_flutter/model/xml/delivery.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/invoice_type_code.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/service/util.dart';

import 'party.dart';

/// A class representing a standard invoice used for issuing an invoice to a customer.
///
/// The [StandardInvoice] class holds all necessary data for an invoice, including
/// customer and supplier details, invoice lines (items), tax details, delivery information,
/// and other related fields. It can generate the XML and JSON representations of the invoice,
/// suitable for reporting and invoicing purposes.
class StandardInvoice {
  /// Unique identifier for the invoice.
  final String id;

  /// Internal control number (ICV) for the invoice.
  final int icv;

  /// Universal Unique Identifier (UUID) for the invoice.
  final String uuid;

  /// The date the invoice was issued.
  final DateTime issueDate;

  /// The time the invoice was issued.
  final DateTime issueTime;

  /// Currency used in the invoice (e.g., SAR for Saudi Riyals).
  final String currency;

  /// The customer to whom the invoice is issued.
  final BusinessParty customer;

  /// The list of items (invoice lines) associated with the invoice.
  final List<InvoiceLine> lines;

  /// The tax details related to the invoice.
  final TaxDetails tax;

  /// The legal monetary total of the invoice (e.g., subtotal, taxes, total).
  final LegalMonetaryTotal monetaryTotal;

  /// The PIH (Payment Instructions Header) or additional reference for the invoice.
  final String pih;

  /// The delivery information related to the invoice.
  final Delivery delivery;

  /// Invoice Type Code
  final InvoiceTypeCode? invoiceTypeCode;

  /// The supplier information, fetched from local storage.
  MyBusinessInfo? get supplier => LocalStore.instance.myBusinessInfo;

  /// Constructor to initialize the [StandardInvoice] object with necessary values.
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
    required this.pih,
    required this.delivery,
    this.invoiceTypeCode,
  });

  /// Converts the invoice to a JSON map, suitable for serializing to JSON format.
  ///
  /// Returns a map containing the invoice data.
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

  /// Converts the invoice to a JSON string.
  ///
  /// This is a convenient method that encodes the JSON representation of the invoice.
  ///
  /// Returns the JSON string.
  String toJsonString() => jsonEncode(toJson());

  /// Generates the XML representation of the invoice.
  ///
  /// This method creates an XML document structured with all the required elements for
  /// the invoice, including information such as the invoice ID, customer details, items,
  /// tax information, supplier details, and other related references like delivery and PIH.
  ///
  /// Returns the XML string representing the invoice.
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

      // Invoice Type Code
      invoiceTypeCode != null
          ? invoiceTypeCode?.toXml(builder)
          : InvoiceTypeCode.standardTaxInvoice();

      builder.element('cbc:DocumentCurrencyCode', nest: currency);
      builder.element('cbc:TaxCurrencyCode', nest: currency);

      // Additional Document Reference for ICV
      builder.element('cac:AdditionalDocumentReference', nest: () {
        builder.element('cbc:ID', nest: 'ICV');
        builder.element('cbc:UUID', nest: icv);
      });

      // Additional Document Reference for PIH
      builder.element('cac:AdditionalDocumentReference', nest: () {
        builder.element('cbc:ID', nest: 'PIH');
        builder.element('cac:Attachment', nest: () {
          builder.element('cbc:EmbeddedDocumentBinaryObject',
              attributes: {'mimeCode': 'text/plain'},
              nest: pih.isEmpty ? getPIHForFirstInvoice() : pih);
        });
      });

      // Supplier and Customer parties
      builder.element('cac:AccountingSupplierParty',
          nest: () => supplier?.toXml(builder));
      builder.element('cac:AccountingCustomerParty',
          nest: () => customer.toXml(builder));

      // Delivery builder
      delivery.toXml(builder);

      // Tax totals and Legal Monetary totals
      builder.element('cac:TaxTotal', nest: () {
        builder.element('cbc:TaxAmount',
            attributes: {'currencyID': tax.currency}, nest: tax.amount);
      });

      builder.element('cac:TaxTotal', nest: () => tax.toXml(builder));
      builder.element('cac:LegalMonetaryTotal',
          nest: () => monetaryTotal.toXml(builder));

      // Invoice Lines (Items)
      for (int id = 0; id < lines.length; id++) {
        InvoiceLine line = lines[id];
        builder.element('cac:InvoiceLine', nest: () => line.toXml(builder, id));
      }
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Generates and saves the XML representation of the invoice to a file.
  ///
  /// This method uses the [toXml()] method to generate the XML and then saves it to a file
  /// using the provided [fileName]. The method is asynchronous.
  Future<void> generateAndSaveXml(String fileName) async {
    await saveToFile(toXml(), fileName);
  }
}
