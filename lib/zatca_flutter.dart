import 'package:zatca_flutter/request.dart';
import 'package:zatca_flutter/service/fatoora_service_finder.dart';

/// Zatca Flutter Entry point.
class ZatcaFlutter{

  /// Initialization of relevant services
  static Future<void> init()async{
    await FatooraServiceFinder.instance.init();
    await LocalStore.instance.init();
  }
}