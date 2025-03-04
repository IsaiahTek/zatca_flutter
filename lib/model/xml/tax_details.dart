import 'package:xml/xml.dart';

enum TaxCategoryCode{
  standard,
  exempt,
  zeroRated,
  outsideVatScope
}

final Map<TaxCategoryCode, String> taxCategoryCodeValues = {
  TaxCategoryCode.exempt: 'E',
  TaxCategoryCode.standard: 'S',
  TaxCategoryCode.outsideVatScope: 'O',
  TaxCategoryCode.zeroRated: 'Z'
};

enum TaxSchemeCode{
  /// Value Added Tax (VAT) (KSA's tax system)
  vat,

  /// Central Sales Tax (CST)
  cst,
  
  /// Goods & Services Tax (GST)
  gst
}

class TaxDetails {
  String amount;
  String percent;
  String currency;
  String taxableAmount;
  TaxCategoryCode code;
  TaxSchemeCode? taxSchemeCode;

  TaxDetails({required this.amount, required this.percent, required this.currency, required this.taxableAmount, required this.code, this.taxSchemeCode});


  void toXml(XmlBuilder builder) {
    
    builder.element('cbc:TaxAmount', attributes: {'currencyID': currency}, nest: amount);
    builder.element('cac:TaxSubtotal', nest: () {
      builder.element('cbc:TaxableAmount', attributes: {'currencyID': currency}, nest: taxableAmount);
      builder.element('cbc:TaxAmount', attributes: {'currencyID': currency}, nest: amount);
      builder.element('cac:TaxCategory', nest: () {
        builder.element('cbc:ID', nest: taxCategoryCodeValues[code]);
        builder.element('cbc:Percent', nest: percent);
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID', nest: taxSchemeCode != null ? taxSchemeCode?.name.toUpperCase() : 'VAT');
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