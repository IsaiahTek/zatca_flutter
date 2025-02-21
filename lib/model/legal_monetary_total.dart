import 'package:xml/xml.dart';

class LegalMonetaryTotal {
  String lineExtensionAmount;
  String taxExclusiveAmount;
  String taxInclusiveAmount;
  String payableAmount;
  double prepaidAmount;
  double allowanceTotalAmount;

  LegalMonetaryTotal({
    required this.lineExtensionAmount,
    required this.taxExclusiveAmount,
    required this.taxInclusiveAmount,
    required this.payableAmount,
    required this.allowanceTotalAmount,
    required this.prepaidAmount
  });

  void toXml(XmlBuilder builder) {
    builder.element('cbc:LineExtensionAmount', nest: lineExtensionAmount, attributes: {'currencyID':'SAR'});
    builder.element('cbc:TaxExclusiveAmount', nest: taxExclusiveAmount, attributes: {'currencyID':'SAR'});
    builder.element('cbc:TaxInclusiveAmount', nest: taxInclusiveAmount, attributes: {'currencyID':'SAR'});
    builder.element('cbc:PayableAmount', nest: payableAmount, attributes: {'currencyID':'SAR'});
    builder.element('cbc:AllowanceTotalAmount', nest: allowanceTotalAmount, attributes: {'currencyID':'SAR'});
    builder.element('cbc:PrepaidAmount', nest: prepaidAmount, attributes: {'currencyID':'SAR'});
  }
}