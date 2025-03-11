import 'package:xml/xml.dart';
import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';

class AllowanceCharge {
  String reason;
  double amount;
  TaxDetails tax;

  AllowanceCharge(
      {required this.reason, required this.amount, required this.tax});

  toXml(XmlBuilder builder) {
    builder.element('cac:AllowanceCharge', nest: () {
      builder.element('cbc:ChargeIndicator', nest: false);
      builder.element('cbc:AllowanceChargeReason', nest: 'discount');
      builder.element('cbc:Amount',
          attributes: {'currencyID': 'SAR'}, nest: 0.00);
      builder.element('cac:TaxCategory', nest: () {
        builder.element('cbc:ID',
            attributes: {'schemeID': 'UN/ECE 5305', 'schemeAgencyID': '6'},
            nest: taxCategoryCodeValues[tax.code ?? TaxCategoryCode.standard]);
        builder.element('cbc:Percent', nest: tax.percent);
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
