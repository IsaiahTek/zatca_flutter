import 'dart:convert';

import 'package:zatca_flutter/local_store.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/service/util.dart';

class MyBusinessInfo extends BusinessParty {
  String companyID;

  MyBusinessInfo({
    required super.name,
    required super.address,
    required super.taxId,
    required super.buildingNumber,
    required super.citySubdivision,
    required super.city,
    required super.postalZone,
    required super.countryCode,
    required super.schemeID,
    required super.businessID,
    required this.companyID,
  }) {
    save().then((d) {
      LocalStore.instance.myBusinessInfo = this;
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'taxId': taxId,
      'buildingNumber': buildingNumber,
      'city': city,
      'citySubdivision': citySubdivision,
      'postalZone': postalZone,
      'countryCode': countryCode,
      'schemeID': schemeID,
      'companyID': companyID,
      'businessID': businessID,
    };
  }

  factory MyBusinessInfo.fromJson(Map<String, dynamic> json) {
    return MyBusinessInfo(
        name: json['name'],
        address: json['address'],
        taxId: json['taxId'],
        buildingNumber: json['buildingNumber'],
        citySubdivision: json['citySubdivision'],
        city: json['city'],
        postalZone: json['postalZone'],
        countryCode: json['countryCode'],
        schemeID: json['schemeID'],
        companyID: json['companyID'],
        businessID: json['businessID']);
  }

  Future<void> save() async {
    saveToFile(jsonEncode(toJson()), 'myBusinessInfo');
  }

  static Future<MyBusinessInfo?> load() async {
    String? raw = await getFileContentAsString('myBusinessInfo');
    if (raw != null) {
      return MyBusinessInfo.fromJson(jsonDecode(raw));
    }
  }
}
