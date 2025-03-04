import 'dart:io';

import 'package:zatca_flutter/service/util.dart';

class FatooraServiceFinder {
  static FatooraServiceFinder? _instance;

  String csrFileName = "csrConfig.properties";

  String? _fatooraHome;
  String? _sdkConfig;

  String? _path;

  String? get path {
    return _path;
  }

  String? get sdkConfig {
    return _sdkConfig;
  }

  String? get fatooraHome {
    return _fatooraHome;
  }

  Directory? get defaultCertDirectory {
    if (_fatooraHome != null) {
      String parentDirPath = Directory(_fatooraHome!).parent.path;
      Directory certDir = Directory(
          "$parentDirPath${Platform.pathSeparator}Data${Platform.pathSeparator}Certificates");
      return certDir;
    } else {
      return null;
    }
  }

  set setFatooraPath(String path) {
    _path = path;
  }

  set setSdkHome(String path){
    _sdkConfig = path;
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

  static FatooraServiceFinder get instance =>
      _instance ??= FatooraServiceFinder._();
}
