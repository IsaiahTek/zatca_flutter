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

/// A class representing a simplified debit note used in transactions.
///
/// The [SimplifiedDebitNote] class holds the necessary data for a debit note, including
/// information about the supplier, customer, tax, items, and payment methods. It can also
/// generate an XML representation of the debit note that can be used for reporting or invoicing.
class SimplifiedDebitNote {
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

  /// The customer to whom the debit note is addressed.
  final IndividualParty customer;

  /// The list of items (invoice lines) associated with the debit note.
  final List<InvoiceLine> lines;

  /// The tax details related to the debit note.
  final TaxDetails tax;

  /// The legal monetary total of the debit note (e.g., subtotal, taxes, total).
  final LegalMonetaryTotal monetaryTotal;

  /// The PIH (Payment Instructions Header) or additional reference for the debit note.
  final String pih;

  /// The billing reference details associated with the debit note.
  final BillingReference billingReference;

  /// Delivery information, if applicable to the debit note.
  final Delivery? delivery;

  /// Payment means details specifying how the debit note will be paid.
  final PaymentMeans paymentMeans;

  /// Allowance or charge details, if applicable to the debit note.
  final AllowanceCharge? allowanceCharge;

  /// Invoice Type Code
  final InvoiceTypeCode? invoiceTypeCode;

  /// The supplier information, fetched from local storage.
  MyBusinessInfo? get supplier => LocalStore.instance.myBusinessInfo;

  /// Constructor to initialize the [SimplifiedDebitNote] object with necessary values.
  SimplifiedDebitNote({
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
    this.delivery,
    this.allowanceCharge,
    this.invoiceTypeCode,
  });

  /// Generates the XML representation of the debit note in a format required for reporting.
  ///
  /// This method creates a fully structured XML document with all the necessary elements
  /// such as the debit note ID, customer details, items, tax, and payment methods. It also
  /// includes additional references like the ICV and PIH.
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
          : InvoiceTypeCode.simplifiedDebitNote();

      builder.element('cbc:DocumentCurrencyCode', nest: currency);
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
              attributes: {'mimeCode': 'text/plain'},
              nest: pih.isEmpty ? getPIHForFirstInvoice() : pih);
        });
      });

      builder.element('cac:AccountingSupplierParty',
          nest: () => supplier?.toXml(builder));
      builder.element('cac:AccountingCustomerParty',
          nest: () => customer.toXml(builder));

      // Delivery builder
      delivery?.toXml(builder);

      // PaymentMeans Builder
      paymentMeans.toXml(builder);

      // AllowanceCharge builder
      allowanceCharge?.toXml(builder);

      builder.element('cac:TaxTotal', nest: () {
        builder.element('cbc:TaxAmount',
            attributes: {'currencyID': tax.currency}, nest: tax.amount);
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

  /// Generates the XML file for the debit note and saves it to a file.
  ///
  /// This method is used to generate the XML representation of the debit note and save it
  /// to a file with the given [fileName]. It asynchronously saves the file to the local storage.
  Future<void> generateAndSaveXml(String fileName) async {
    saveToFile(toXml(), fileName);
  }
}
