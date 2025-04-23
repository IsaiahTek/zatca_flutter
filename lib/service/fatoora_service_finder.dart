import 'dart:io';
import 'package:zatca_flutter/service/util.dart';

/// The main FATOORA CLI service for managing paths and configurations related to Fatoora SDK.
///
/// This class handles the initialization, retrieval, and management of the paths related to the Fatoora SDK,
/// including the Fatoora home directory, SDK configuration, and certificates directory.
class FatooraServiceFinder {
  static FatooraServiceFinder? _instance;

  /// The default CSR file name used for the configuration.
  String csrFileName = "csrConfig.properties";

  String? _fatooraHome;
  String? _sdkConfig;
  String? _path;

  /// Returns the SDK path.
  String? get path => _getPath();

  String? _getPath() {
    return _path;
  }

  /// Returns the installed ZATCA SDK Config folder path.
  String? get sdkConfig {
    return _sdkConfig;
  }

  String? _getFatooraHome() => _fatooraHome;

  /// Returns the Fatoora Home path.
  String? get fatooraHome => _getFatooraHome();

  /// Returns the default directory where the certificates are stored.
  ///
  /// The certificates directory is located in the parent directory of the Fatoora home.
  Directory? _getCertDir() {
    if (_fatooraHome != null) {
      String parentDirPath = Directory(_fatooraHome!).parent.path;
      Directory certDir = Directory(
          "$parentDirPath${Platform.pathSeparator}Data${Platform.pathSeparator}Certificates");
      return certDir;
    } else {
      return null;
    }
  }

  /// Returns the Cert directory.
  Directory? get defaultCertDirectory => _getCertDir();

  void _setFatooraPath(String path) {
    _path = path;
  }

  void _setSdkHome(String path) {
    _sdkConfig = path;
  }

  /// Sets the Fatoora path.
  set setFatooraPath(String path) {
    _setFatooraPath(path);
  }

  /// Sets the SDK configuration path.
  set setSdkHome(String path) {
    _setSdkHome(path);
  }

  /// Private constructor for [FatooraServiceFinder].
  FatooraServiceFinder._() {
    _init();
  }

  /// Initializes the Fatoora service by determining paths for the SDK and home directory.
  Future<void> init() => _init();

  /// Command to search for Fatoora depending on the platform (Linux or Windows).
  String get _searchCommand {
    if (Platform.isLinux) {
      return 'which';
    } else if (Platform.isWindows) {
      return 'where';
    } else {
      throw Exception("Only Windows and Linux Platforms are allowed");
    }
  }

  /// Initializes paths for Fatoora and SDK configuration.
  Future<void> _init() async {
    if (path == null) {
      Process.run(_searchCommand, ["fatoora"]).then((data) {
        if (Platform.isWindows) {
          List<String> list =
              data.stdout.toString().split(RegExp(r'\s+')).toList();
          if (list.length > 1) {
            _path = list[0];
          } else {
            _path = data.stdout.toString().trim();
          }
        } else {
          _path = data.stdout.toString().trim();
        }
        logInfo("FATOORA PATH FOUND: $_path");
      });

      String command;
      List<String> fatooraHomeSearchArgs;
      List<String> sdkConfigSearchArgs;

      if (Platform.isWindows) {
        command = 'cmd';
        fatooraHomeSearchArgs = ['/C', 'echo %FATOORA_HOME%'];
        sdkConfigSearchArgs = ['/C', 'echo %SDK_CONFIG%'];
      } else {
        command = 'bash';
        fatooraHomeSearchArgs = ['-c', 'echo \$FATOORA_HOME'];
        sdkConfigSearchArgs = ['-c', 'echo \$SDK_CONFIG'];
      }

      Process.run(command, fatooraHomeSearchArgs, runInShell: true)
          .then((data) {
        String fHome = data.stdout.toString().trim();
        _fatooraHome = fHome;
        logInfo("FATOORA HOME $fHome");
      });
      Process.run(command, sdkConfigSearchArgs, runInShell: true).then((data) {
        _sdkConfig = data.stdout.toString().trim();
        logInfo("FATOORA SDK CONFIG: $_sdkConfig");
      });
    } else {}
  }

  /// Returns an instance of the service, ensuring that it's the same across usages.
  static FatooraServiceFinder get instance =>
      _instance ??= FatooraServiceFinder._();
}
