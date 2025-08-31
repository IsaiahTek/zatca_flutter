// Simplified Debit Note Model to hold the necessary data
import 'package:xml/xml.dart';
import 'package:zatca_flutter/local_store.dart';
import 'package:zatca_flutter/model/my_business_info.dart';
import 'package:zatca_flutter/model/xml/allowance_charge.dart';
import 'package:zatca_flutter/model/xml/billing_reference.dart';
import 'package:zatca_flutter/model/xml/delivery.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/invoice_type_code.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/model/xml/payment_means.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/service/util.dart';

/// A class representing a standard debit note used for issuing debit to a customer.
///
/// The [StandardDebitNote] class holds all necessary data for a debit note, including
/// the customer and supplier information, the debit note lines (items), tax details,
/// payment means, delivery information, and other related fields. It can generate the
/// XML representation of the debit note, suitable for reporting and invoicing purposes.
class StandardDebitNote {
  /// Unique identifier for the debit note.
  final String id;

  /// Internal control number (ICV) for the debit note.
  final int icv;

  /// Universal Unique Identifier (UUID) for the debit note.
  final String uuid;

  /// The date the debit note was issued.
  final DateTime issueDate;

  /// The time the debit note was issued.
  final DateTime issueTime;

  /// Currency used in the debit note (e.g., SAR for Saudi Riyals).
  final String currency;

  /// The customer to whom the debit note is issued.
  final BusinessParty customer;

  /// The list of items (debit note lines) associated with the debit note.
  final List<InvoiceLine> lines;

  /// The tax details related to the debit note.
  final TaxDetails tax;

  /// The legal monetary total of the debit note (e.g., subtotal, taxes, total).
  final LegalMonetaryTotal monetaryTotal;

  /// The PIH (Payment Instructions Header) or additional reference for the debit note.
  final String pih;

  /// The billing reference associated with the debit note.
  final BillingReference billingReference;

  /// The delivery information related to the debit note.
  final Delivery delivery;

  /// The payment means related to the debit note.
  final PaymentMeans paymentMeans;

  /// The allowance or charge related to the debit note (if applicable).
  final AllowanceCharge? allowanceCharge;

  /// Invoice Type Code
  final InvoiceTypeCode? invoiceTypeCode;

  /// The supplier information, fetched from local storage.
  MyBusinessInfo? get supplier => LocalStore.instance.myBusinessInfo;

  /// Constructor to initialize the [StandardDebitNote] object with necessary values.
  StandardDebitNote({
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
    required this.billingReference,
    required this.paymentMeans,
    required this.delivery,
    this.allowanceCharge,
    this.invoiceTypeCode,
  });

  /// Generates the XML representation of the debit note.
  ///
  /// This method creates an XML document structured with all the required elements for
  /// the debit note, including information such as the debit note ID, customer details,
  /// items, tax information, supplier details, and other related references like billing,
  /// delivery, and payment means.
  ///
  /// Returns the XML string representing the debit note.
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
          : InvoiceTypeCode.standardDebitNote().toXml(builder);

      builder.element('cbc:DocumentCurrencyCode', nest: currency);
      builder.element('cbc:TaxCurrencyCode', nest: currency);

      // Build the BillingReference element.
      billingReference.toXml(builder);

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

      // PaymentMeans builder
      paymentMeans.toXml(builder);

      // AllowanceCharge builder
      allowanceCharge?.toXml(builder);

      // Tax totals and Legal Monetary totals
      builder.element('cac:TaxTotal', nest: () {
        builder.element('cbc:TaxAmount',
            attributes: {'currencyID': tax.currency}, nest: tax.amount);
      });

      builder.element('cac:TaxTotal', nest: () => tax.toXml(builder));
      builder.element('cac:LegalMonetaryTotal',
          nest: () => monetaryTotal.toXml(builder));

      // Debit Note Lines (Invoice lines)
      for (int id = 0; id < lines.length; id++) {
        InvoiceLine line = lines[id];
        builder.element('cac:InvoiceLine', nest: () => line.toXml(builder, id));
      }
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Generates and saves the XML representation of the debit note to a file.
  ///
  /// This method uses the [toXml()] method to generate the XML and then saves it to a file
  /// using the provided [fileName]. The method is asynchronous.
  Future<void> generateAndSaveXml(String fileName) async {
    await saveToFile(toXml(), fileName);
  }
}
