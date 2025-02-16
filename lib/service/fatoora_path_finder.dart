import 'dart:io';

import 'package:flutter/material.dart';

class FatooraPathFinder {

  static FatooraPathFinder? _instance;

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
    debugPrint("SEARCH COMMAND: $_searchCommand");
    if(path == null){
      debugPrint("...FINDING PATH: Current Value ($_path)");
      Process.run(_searchCommand, ["fatoora"]).then((data){
        _path = data.stdout.toString().trim();
        debugPrint("FOUND PATH: $_path");
      });
    }else{
      debugPrint("PATH IS NOT NULL $path");
    }
  }

  static FatooraPathFinder get instance => _instance ??= FatooraPathFinder._();
}