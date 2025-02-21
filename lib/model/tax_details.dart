import 'package:xml/xml.dart';

class TaxDetails {
  String amount;
  String percent;
  String currency;
  String taxableAmount;

  TaxDetails({required this.amount, required this.percent, required this.currency, required this.taxableAmount});


  void toXml(XmlBuilder builder) {
    builder.element('cbc:TaxAmount', attributes: {'currencyID': currency}, nest: amount);
    builder.element('cac:TaxSubtotal', nest: () {
      builder.element('cbc:TaxableAmount', attributes: {'currencyID': currency}, nest: taxableAmount);
      builder.element('cbc:TaxAmount', attributes: {'currencyID': currency}, nest: amount);
      builder.element('cac:TaxCategory', nest: () {
        builder.element('cbc:ID', nest: 'S');
        builder.element('cbc:Percent', nest: percent);
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID', nest: 'VAT');
        });
      });
    });
  }

  toJson(){
    return {
      'amount': amount,
      'percent': percent
    };
  }
}