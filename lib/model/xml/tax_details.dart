import 'package:xml/xml.dart';
import 'package:zatca_flutter/enums.dart';

/// A class representing the tax details associated with an invoice.
///
/// The [TaxDetails] class holds information about the tax calculation for the invoice,
/// including the tax amount, percentage, taxable amount, and the associated tax category
/// and tax scheme.
class TaxDetails {
  /// The tax amount calculated for the invoice (in the specified currency).
  final String amount;

  /// The tax percentage applied to the taxable amount.
  final String percent;

  /// The currency in which the tax amount is denominated (e.g., SAR for Saudi Riyals).
  final String currency;

  /// The taxable amount on which the tax is applied.
  final String taxableAmount;

  /// The tax category code associated with the tax (e.g., standard, reduced, exempt).
  final TaxCategoryCode? code;

  /// The tax scheme code that specifies the type of tax applied (e.g., VAT).
  final TaxSchemeCode? taxSchemeCode;

  /// Constructor to initialize the [TaxDetails] object with required tax information.
  TaxDetails({
    required this.amount,
    required this.percent,
    required this.currency,
    required this.taxableAmount,
    this.code,
    this.taxSchemeCode,
  });

  /// Converts the tax details to XML format.
  ///
  /// This method builds the XML representation of the tax details, including the tax amount,
  /// taxable amount, tax category, tax scheme, and related elements.
  ///
  /// [builder] is the XML builder used to create the XML document.
  void toXml(XmlBuilder builder) {
    builder.element('cbc:TaxAmount',
        attributes: {'currencyID': currency}, nest: amount);
    builder.element('cac:TaxSubtotal', nest: () {
      builder.element('cbc:TaxableAmount',
          attributes: {'currencyID': currency}, nest: taxableAmount);
      builder.element('cbc:TaxAmount',
          attributes: {'currencyID': currency}, nest: amount);
      builder.element('cac:TaxCategory', nest: () {
        builder.element('cbc:ID',
            nest: taxCategoryCodeValues[code ?? TaxCategoryCode.standard]);
        builder.element('cbc:Percent', nest: percent);
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID',
              nest: taxSchemeCode?.name.toUpperCase() ??
                  TaxSchemeCode.vat.name.toUpperCase());
        });
      });
    });
  }

  /// Converts the tax details to a JSON format.
  ///
  /// This method generates a map containing the tax amount and percentage as key-value pairs.
  ///
  /// Returns a map containing the `amount` and `percent` fields.
  toJson() {
    return {'amount': amount, 'percent': percent};
  }
}
