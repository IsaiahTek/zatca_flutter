import 'dart:convert';

import 'package:zatca_flutter/local_store.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/service/util.dart';

/// A model representing the business information for the user's company.
///
/// This class extends [BusinessParty] and includes additional fields, such as
/// [companyID], to store business-related details. It also provides methods
/// for serializing and saving this data to local storage.
class MyBusinessInfo extends BusinessParty {
  /// The unique identifier for the company.
  final String companyID;

  /// Creates a new instance of [MyBusinessInfo].
  ///
  /// - [name]: The name of the business.
  /// - [address]: The address of the business.
  /// - [taxId]: The tax identification number of the business.
  /// - [buildingNumber]: The building number of the business.
  /// - [citySubdivision]: The subdivision of the city where the business is located.
  /// - [city]: The city where the business is located.
  /// - [postalZone]: The postal zone for the business address.
  /// - [countryCode]: The country code for the business address.
  /// - [schemeID]: The identification scheme used for the business.
  /// - [businessID]: The unique identifier for the business.
  /// - [companyID]: The unique identifier for the company.
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
    // Save the instance to local storage when it's created.
    save().then((d) {
      LocalStore.instance.myBusinessInfo = this;
    });
  }

  /// Converts the [MyBusinessInfo] instance to a JSON-serializable map.
  ///
  /// Returns a map containing all relevant business details including
  /// [name], [address], [taxId], [buildingNumber], etc.
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

  /// Creates a new [MyBusinessInfo] instance from a JSON map.
  ///
  /// - [json]: A map containing business details to construct the instance.
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
      businessID: json['businessID'],
    );
  }

  /// Saves the current [MyBusinessInfo] instance to a local file.
  ///
  /// The data is serialized into JSON format and stored in a file named
  /// 'myBusinessInfo' using the [saveToFile] utility function.
  Future<void> save() async {
    saveToFile(jsonEncode(toJson()), 'myBusinessInfo');
  }

  /// Loads the [MyBusinessInfo] instance from local storage.
  ///
  /// This method attempts to retrieve and deserialize the 'myBusinessInfo'
  /// file, returning the [MyBusinessInfo] instance if successful, or null
  /// if the file does not exist or cannot be read.
  ///
  /// Returns a [Future] that resolves to the loaded [MyBusinessInfo], or null.
  static Future<MyBusinessInfo?> load() async {
    String? raw = await getFileContentAsString('myBusinessInfo');
    if (raw != null) {
      return MyBusinessInfo.fromJson(jsonDecode(raw));
    } else {
      return null;
    }
  }
}
