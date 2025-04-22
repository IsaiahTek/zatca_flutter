import 'package:zatca_flutter/request.dart';
import 'package:zatca_flutter/service/fatoora_service_finder.dart';

import 'local_store.dart';

/// Zatca Flutter Entry point.
class ZatcaFlutter {
  /// Initialization of relevant services
  static Future<void> init({required Mode mode}){
    return _init(mode: mode);
  }

  static Future<void> _init({required Mode mode}) async {
    _setMode(mode);
    await FatooraServiceFinder.instance.init();
    await LocalStore.instance.init();
  }

  static void _setMode(Mode mode){
    ZatcaFlutter._mode = mode;
  }

  static late Mode _mode;

  /// Returns the current mode of Request to Zatca Server
  static Mode get mode{
    return _mode;
  }

  static RequestBase get _request{
    switch (mode) {
      case Mode.production:
        return ProductionRequest();
      case Mode.developerPortal:
        return DeveloperPortalRequest();
      default:
        return SimulationRequest();
    }
  }

  /// The API for your app to use in communicating with Zatca/Fatoora Server
  static RequestBase get request{
    return _request;
  }

}
