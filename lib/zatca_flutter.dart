import 'package:zatca_flutter/service/fatoora_service_finder.dart';

import 'local_store.dart';

/// Zatca Flutter Entry point.
class ZatcaFlutter{

  /// Initialization of relevant services
  static Future<void> init()async{
    await FatooraServiceFinder.instance.init();
    await LocalStore.instance.init();
  }
}