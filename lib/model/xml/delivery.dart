import 'package:xml/xml.dart';
import 'package:zatca_flutter/service/util.dart';

class Delivery {
  DateTime actualDate;
  DateTime latestDate;

  Delivery({required this.actualDate, required this.latestDate});

  String get aDate => getZatcaCompliantDate(actualDate);
  String get lDate => getZatcaCompliantDate(latestDate);

  toXml(XmlBuilder builder){
    builder.element('cac:Delivery', nest: (){
      builder.element('cbc:ActualDeliveryDate', nest: aDate);
      builder.element('cbc:LatestDeliveryDate', nest: lDate);
    });
  }
}