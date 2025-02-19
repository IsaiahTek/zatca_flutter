import 'dart:io';

class FatooraServiceFinder {
  static FatooraServiceFinder? _instance;

  String csrFileName = "csrConfig.properties";

  String? _fatooraHome;

  String? _path;

  String? get path {
    return _path;
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

  set setFatooraPath(String s) {
    _path = s;
  }

  FatooraServiceFinder._() {
    _init();
  }

  Future<void> init() async {
    _init();
  }

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
        _path = data.stdout.toString().trim();
      });
      String command;
      List<String> args;

      if (Platform.isWindows) {
        command = 'cmd';
        args = ['/C', 'echo %FATOORA_HOME%']; // Windows uses %VAR_NAME%
      } else {
        command = 'bash';
        args = ['-c', 'echo \$FATOORA_HOME']; // Linux/macOS uses $VAR_NAME
      }

      Process.run(command, args, runInShell: true).then((data) {
        String fHome = data.stdout.toString().trim();
        _fatooraHome = fHome;
      });
    } else {}
  }

  static FatooraServiceFinder get instance =>
      _instance ??= FatooraServiceFinder._();
}
