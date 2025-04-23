import 'dart:io';

import 'package:zatca_flutter/service/util.dart';

/// The main FATOORA CLI service.
class FatooraServiceFinder {
  static FatooraServiceFinder? _instance;

  /// Set and get the csr file name to be used;
  String csrFileName = "csrConfig.properties";

  String? _fatooraHome;
  String? _sdkConfig;

  String? _path;

  /// Returns the SDK path
  String? get path => _getPath();

  String? _getPath(){
    return _path;
  }

  /// Returns the installed ZATCA SDK Config folder path
  String? get sdkConfig {
    return _sdkConfig;
  }

  String? _getFatooraHome() => _fatooraHome;

  /// Returns the Fatoora Home path
  String? get fatooraHome => _getFatooraHome();

  Directory? _getCertDir(){
    if (_fatooraHome != null) {
      String parentDirPath = Directory(_fatooraHome!).parent.path;
      Directory certDir = Directory(
          "$parentDirPath${Platform.pathSeparator}Data${Platform.pathSeparator}Certificates");
      return certDir;
    } else {
      return null;
    }
  }

  /// Returns the Cert directory
  Directory? get defaultCertDirectory => _getCertDir();

  void _setFatooraPath(String path){
    _path = path;
  }

  void _setSdkHome(String path){
    _sdkConfig = path;
  }

  set setFatooraPath(String path) {
    _setFatooraPath(path);
  }

  set setSdkHome(String path) {
    _setSdkHome(path);
  }

  FatooraServiceFinder._() {
    _init();
  }

  /// Initializing Fatoora Service
  Future<void> init() => _init();

  String get _searchCommand {
    if (Platform.isLinux) {
      return 'which';
    } else if (Platform.isWindows) {
      return 'where';
    } else {
      throw Exception("Only Windows and Linux Platforms are allowed");
    }
  }

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

  /// An instant of the service and is the same accross usage.
  static FatooraServiceFinder get instance =>
      _instance ??= FatooraServiceFinder._();
}
