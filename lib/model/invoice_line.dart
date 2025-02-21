import 'package:xml/xml.dart';
import 'package:zatca_flutter/model/tax_details.dart';

class InvoiceLine {
  String? id;
  String name;
  String quantity;
  String price;
  String total;
  TaxDetails tax;

  InvoiceLine({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    required this.tax,
  });

  void toXml(XmlBuilder builder, int id) {
    builder.element('cbc:ID', nest: id);
    builder.element('cbc:InvoicedQuantity', attributes: {'unitCode': 'PCE'}, nest: quantity);
    builder.element('cbc:LineExtensionAmount', attributes: {'currencyID': 'SAR'}, nest: total);
    builder.element('cac:TaxTotal', nest: ()=> tax.toXml(builder));
    builder.element('cac:Item', nest: (){
      builder.element('cbc:Name', nest: name);
      builder.element('cac:ClassifiedTaxCategory', nest: (){
        builder.element('cbc:ID', nest: 'S');
        builder.element('cbc:Percent', nest:tax.percent);
        builder.element('cac:TaxScheme', nest: (){
          builder.element('cbc:ID', nest: 'VAT');
        });
      });
    });
    builder.element('cac:Price', nest: (){
      builder.element('cbc:PriceAmount', nest: price, attributes: {'currencyID': tax.currency});
      // builder.element('cac:AllowanceCharge', nest: (){});
    });
  }

  toJson(){
    return {
      'id': id,
      'price': price,
      'quantity': quantity,
      'total': total,
      'tax': tax.toJson()
    };
  }
}