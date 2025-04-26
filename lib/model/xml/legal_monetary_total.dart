import 'package:xml/xml.dart';

/// Represents the legal monetary totals for an invoice, including various financial
/// amounts such as line extension, tax amounts, prepaid amounts, and the payable amount.
///
/// The [LegalMonetaryTotal] class holds the essential financial summary related to the
/// invoice's monetary totals, such as the line extension amount, tax exclusive and inclusive
/// amounts, allowance total, prepaid amounts, and payable amounts. These totals are often
/// required for legal or regulatory compliance in many invoicing systems.
class LegalMonetaryTotal {
  /// The total amount before any tax is applied (line extension amount).
  final String lineExtensionAmount;

  /// The total amount excluding taxes (tax-exclusive amount).
  final String taxExclusiveAmount;

  /// The total amount including taxes (tax-inclusive amount).
  final String taxInclusiveAmount;

  /// The amount to be paid after considering all factors (payable amount).
  final String payableAmount;

  /// The amount that has been prepaid (prepaid amount).
  final double prepaidAmount;

  /// The total amount of allowances (allowance total amount).
  final double allowanceTotalAmount;

  /// Constructs a [LegalMonetaryTotal] with the provided financial amounts.
  ///
  /// [lineExtensionAmount] is the total amount before tax.
  /// [taxExclusiveAmount] is the amount excluding taxes.
  /// [taxInclusiveAmount] is the amount including taxes.
  /// [payableAmount] is the total amount that is to be paid.
  /// [prepaidAmount] is the amount already prepaid.
  /// [allowanceTotalAmount] is the total amount of allowances.
  LegalMonetaryTotal({
    required this.lineExtensionAmount,
    required this.taxExclusiveAmount,
    required this.taxInclusiveAmount,
    required this.payableAmount,
    required this.allowanceTotalAmount,
    required this.prepaidAmount,
  });

  /// Converts the [LegalMonetaryTotal] instance into XML format using the [XmlBuilder].
  ///
  /// This method generates an XML representation of the monetary totals for the invoice.
  /// It adds elements for each of the financial totals, with the currency set to SAR (Saudi Riyal).
  /// Example:
  /// ```xml
  /// <cbc:LineExtensionAmount currencyID="SAR">1000.00</cbc:LineExtensionAmount>
  /// <cbc:TaxExclusiveAmount currencyID="SAR">950.00</cbc:TaxExclusiveAmount>
  /// <cbc:TaxInclusiveAmount currencyID="SAR">1050.00</cbc:TaxInclusiveAmount>
  /// <cbc:AllowanceTotalAmount currencyID="SAR">50.00</cbc:AllowanceTotalAmount>
  /// <cbc:PrepaidAmount currencyID="SAR">200.00</cbc:PrepaidAmount>
  /// <cbc:PayableAmount currencyID="SAR">850.00</cbc:PayableAmount>
  /// ```
  void toXml(XmlBuilder builder) {
    builder.element('cbc:LineExtensionAmount',
        nest: lineExtensionAmount, attributes: {'currencyID': 'SAR'});
    builder.element('cbc:TaxExclusiveAmount',
        nest: taxExclusiveAmount, attributes: {'currencyID': 'SAR'});
    builder.element('cbc:TaxInclusiveAmount',
        nest: taxInclusiveAmount, attributes: {'currencyID': 'SAR'});
    builder.element('cbc:AllowanceTotalAmount',
        nest: allowanceTotalAmount.toString(),
        attributes: {'currencyID': 'SAR'});
    builder.element('cbc:PrepaidAmount',
        nest: prepaidAmount.toString(), attributes: {'currencyID': 'SAR'});
    builder.element('cbc:PayableAmount',
        nest: payableAmount, attributes: {'currencyID': 'SAR'});
  }
}
