import 'package:zatca_flutter/service/fatoora_path_finder.dart';

class ZatcaFlutter{
  static Future<void> init()async{
    await FatooraPathFinder.instance.init();
  }
}