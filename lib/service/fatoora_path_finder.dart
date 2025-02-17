import 'dart:io';

class FatooraPathFinder {

  static FatooraPathFinder? _instance;

  String csrFileName = "csrFileName";

  String? _path;

  String? get path{
    return _path;
  }

  set setFatooraPath(String s){
    _path = s;
  }

  FatooraPathFinder._(){
    _init();
  }

  Future<void> init()async{ _init(); }

  String get _searchCommand{
    if(Platform.isLinux){
      return 'which';
    }else if(Platform.isWindows){
      return 'where';
    }else{
      throw Exception("Only Windows and Linux Platforms are allowed");
    }
  }

  Future<void> _init()async{
    if(path == null){
      Process.run(_searchCommand, ["fatoora"]).then((data){
        _path = data.stdout.toString().trim();
      });
    }else{
    }
  }

  static FatooraPathFinder get instance => _instance ??= FatooraPathFinder._();
}