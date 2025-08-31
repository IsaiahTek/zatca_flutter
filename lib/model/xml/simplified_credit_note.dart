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

/// A class representing a simplified credit note (or debit note) used in transactions.
///
/// The [SimplifiedCreditNote] class holds the necessary data for a credit note, including
/// information about the supplier, customer, tax, items, and payment methods. It can also
/// generate an XML representation of the credit note that can be used for reporting or invoicing.
class SimplifiedCreditNote {
  /// Unique identifier for the credit note.
  final String id;

  /// Internal control number (ICV) for the credit note.
  final int icv;

  /// Universal Unique Identifier (UUID) for the credit note.
  final String uuid;

  /// The date the credit note was issued.
  final DateTime issueDate;

  /// The time the credit note was issued.
  final DateTime issueTime;

  /// Currency used in the credit note (e.g., SAR for Saudi Riyals).
  final String currency;

  /// The customer to whom the credit note is addressed.
  final IndividualParty customer;

  /// The list of items (invoice lines) associated with the credit note.
  final List<InvoiceLine> lines;

  /// The tax details related to the credit note.
  final TaxDetails tax;

  /// The legal monetary total of the credit note (e.g., subtotal, taxes, total).
  final LegalMonetaryTotal monetaryTotal;

  /// The PIH (Payment Instructions Header) or additional reference for the credit note.
  final String pih;

  /// The billing reference details associated with the credit note.
  final BillingReference billingReference;

  /// Delivery information, if applicable to the credit note.
  final Delivery? delivery;

  /// Payment means details specifying how the credit note will be paid.
  final PaymentMeans paymentMeans;

  /// Allowance or charge details, if applicable to the credit note.
  final AllowanceCharge? allowanceCharge;

  /// InvoiceTypeCode
  final InvoiceTypeCode? invoiceTypeCode;

  /// The supplier information, fetched from local storage.
  MyBusinessInfo? get supplier => LocalStore.instance.myBusinessInfo;

  /// Constructor to initialize the [SimplifiedCreditNote] object with necessary values.
  SimplifiedCreditNote({
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

  /// Generates the XML representation of the credit note in a format required for reporting.
  ///
  /// This method creates a fully structured XML document with all the necessary elements
  /// such as the credit note ID, customer details, items, tax, and payment methods. It also
  /// includes additional references like the ICV and PIH.
  ///
  /// Returns the XML string representing the credit note.
  String toXml() {
    if (supplier == null) {
      throw Exception("You need to first set your business info");
    }
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

      // InvoiceTypeCode
      invoiceTypeCode != null
          ? invoiceTypeCode?.toXml(builder)
          : InvoiceTypeCode.simplifiedCreditNote().toXml(builder);

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

  /// Generates the XML file for the credit note and saves it to a file.
  ///
  /// This method is used to generate the XML representation of the credit note and save it
  /// to a file with the given [fileName]. If the supplier information is missing, an exception
  /// will be thrown.
  ///
  /// Returns the file path where the XML is saved or `null` if the file could not be saved.
  Future<String?> generateAndSaveXml(String fileName) async {
    // if (supplier != null) {
    //   return null;
    // }
    return await saveToFile(toXml(), fileName);
  }
}
