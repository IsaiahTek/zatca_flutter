import 'package:xml/xml.dart';
import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';

/// Represents an allowance or charge, typically used in tax-related transactions.
///
/// This class models an allowance or charge element, which is used to represent discounts or
/// additional charges in financial transactions, particularly in the context of tax invoices.
///
/// It includes the following properties:
/// - [reason]: The reason for the allowance or charge (e.g., discount).
/// - [amount]: The amount of the allowance or charge.
/// - [tax]: A [TaxDetails] object that provides tax information related to the allowance or charge.
class AllowanceCharge {
  /// The reason for the allowance or charge (e.g., discount).
  final String reason;

  /// The amount of the allowance or charge.
  final double amount;

  /// The tax details related to this allowance or charge.
  final TaxDetails tax;

  /// Constructs an [AllowanceCharge] instance with the specified [reason], [amount], and [tax].
  ///
  /// [reason] is a string representing the reason for the allowance or charge (e.g., discount).
  /// [amount] is a numeric value representing the amount of the allowance or charge.
  /// [tax] is a [TaxDetails] instance that contains tax-related information.
  AllowanceCharge(
      {required this.reason, required this.amount, required this.tax});

  /// Converts the [AllowanceCharge] instance to an XML representation using the [XmlBuilder].
  ///
  /// This method builds the XML structure for an allowance or charge, following the specified
  /// XML schema for the transaction. The XML elements are structured according to the standards
  /// required for tax reporting or invoicing.
  ///
  /// Example:
  /// ```dart
  /// XmlBuilder builder = XmlBuilder();
  /// allowanceCharge.toXml(builder);
  /// ```
  void toXml(XmlBuilder builder) {
    builder.element('cac:AllowanceCharge', nest: () {
      // Charge indicator element (indicating whether this is a charge or allowance)
      builder.element('cbc:ChargeIndicator', nest: false);

      // Allowance charge reason element (e.g., 'discount')
      builder.element('cbc:AllowanceChargeReason', nest: reason);

      // Amount element, with the currency set to SAR (Saudi Riyal)
      builder.element('cbc:Amount',
          attributes: {'currencyID': 'SAR'}, nest: amount);

      // Tax category element containing tax-related information
      builder.element('cac:TaxCategory', nest: () {
        // Tax category ID element with scheme details
        builder.element('cbc:ID',
            attributes: {'schemeID': 'UN/ECE 5305', 'schemeAgencyID': '6'},
            nest: taxCategoryCodeValues[tax.code ?? TaxCategoryCode.standard]);

        // Tax percentage element
        builder.element('cbc:Percent', nest: tax.percent);

        // Tax scheme element with scheme ID and code
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID',
              attributes: {'schemeID': 'UN/ECE 5153', 'schemeAgencyID': '6'},
              nest: tax.taxSchemeCode?.name.toUpperCase() ??
                  TaxSchemeCode.vat.name.toUpperCase());
        });
      });
    });
  }
}
