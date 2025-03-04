import 'package:xml/xml.dart';

class Delivery {
  DateTime actualDate;
  DateTime latestDate;

  Delivery({required this.actualDate, required this.latestDate});

  toXml(XmlBuilder builder){
    builder.element('cac:Delivery', nest: (){
      builder.element('cbc:ActualDeliveryDate', nest: actualDate);
      builder.element('cbc:LatestDeliveryDate', nest: latestDate);
    });
  }
}