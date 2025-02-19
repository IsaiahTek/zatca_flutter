import 'package:zatca_flutter/service/fatoora_service_finder.dart';

class ZatcaFlutter{
  static Future<void> init()async{
    await FatooraServiceFinder.instance.init();
  }
}