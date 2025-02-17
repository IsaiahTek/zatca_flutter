import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zatca_flutter/service/fatoora_cli.dart';
import 'package:zatca_flutter/service/fatoora_path_finder.dart';
import 'package:zatca_flutter/zatca_flutter.dart';


void main() {

  testWidgets('Invoice Hash Generation With custom output json file name', (WidgetTester widget)async {
    // await ZatcaFlutter.init();
    FatooraPathFinder.instance.setFatooraPath = "/home/isaiah/development/zatca-R3.3.9/Apps";
    var d = await FatooraCli.getHelp();
    debugPrint("$d");
    expect(d is String, true);
  });
}
