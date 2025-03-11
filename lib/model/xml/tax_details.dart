import 'package:xml/xml.dart';
import 'package:zatca_flutter/enums.dart';

class TaxDetails {
  String amount;
  String percent;
  String currency;
  String taxableAmount;
  TaxCategoryCode? code;
  TaxSchemeCode? taxSchemeCode;

  TaxDetails(
      {required this.amount,
      required this.percent,
      required this.currency,
      required this.taxableAmount,
      this.code,
      this.taxSchemeCode});

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

  toJson() {
    return {'amount': amount, 'percent': percent};
  }
}
