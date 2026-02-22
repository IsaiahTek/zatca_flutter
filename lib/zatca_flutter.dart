import 'package:zatca_flutter/dart_java_bridge/zatca_java_singleton.dart';
import 'package:zatca_flutter/request.dart';
import 'package:zatca_flutter/service/fatoora_service_finder.dart';
import 'local_store.dart';

/// Zatca Flutter Entry Point
///
/// This class provides the entry point to initialize and interact with Zatca-related services in a Flutter application.
/// It provides initialization methods, manages the mode (production, developer portal, simulation),
/// and provides an API to communicate with Zatca/Fatoora servers based on the current mode.
class ZatcaFlutter {
  /// Initializes the relevant services required for Zatca Flutter.
  ///
  /// This method initializes the mode and sets up the FatooraServiceFinder and LocalStore instances.
  ///
  /// Parameters:
  /// - [mode]: The mode in which the application will operate. This could be production, developer portal, or simulation.
  static Future<void> init({required Mode mode}) {
    return _init(mode: mode);
  }

  /// Private method that handles the actual initialization.
  ///
  /// It sets the mode and initializes necessary services (FatooraServiceFinder and LocalStore).
  static Future<void> _init({required Mode mode}) async {
    _setMode(mode);
    await ZatcaJavaSingleton.init();
    await FatooraServiceFinder.instance.init();
    await LocalStore.instance.init();
  }

  /// Private method to set the mode for the Zatca Flutter service.
  static void _setMode(Mode mode) {
    ZatcaFlutter._mode = mode;
  }

  /// The current mode of the application.
  ///
  /// This variable stores the mode (production, developer portal, or simulation) that determines how
  /// the application interacts with the Zatca/Fatoora server.
  static late Mode _mode;

  /// Returns the current mode of the request to the Zatca server.
  ///
  /// The mode can be one of the following:
  /// - [Mode.production]: Used when communicating with the production environment.
  /// - [Mode.sandbox]: Used when interacting with the developer portal.
  /// - [Mode.simulation]: Used when operating in a simulation environment.
  static Mode get mode => _getMode();

  static Mode _getMode() => _mode;

  /// Returns the appropriate request instance based on the current mode.
  ///
  /// Depending on the mode (production, developer portal, or simulation), this method returns
  /// the corresponding request type to interact with the Zatca/Fatoora server.
  static RequestBase get _request {
    switch (mode) {
      case Mode.production:
        return ProductionRequest();
      case Mode.sandbox:
        return DeveloperPortalRequest();
      default:
        return SimulationRequest();
    }
  }

  /// The API interface for communicating with the Zatca/Fatoora server.
  ///
  /// This provides the methods and properties necessary to interact with the server based on the
  /// current mode. The request is either for the production, developer portal, or simulation environment.
  static RequestBase get request {
    return _request;
  }
}
