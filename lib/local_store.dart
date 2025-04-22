import 'dart:convert';
import 'dart:io';

import 'package:zatca_flutter/model/my_business_info.dart';
import 'package:zatca_flutter/zatca_flutter.dart';

import 'service/fatoora_service_finder.dart';
import 'service/util.dart';

/// The model used by CSIDs
class Tokeys {
  /// String value of the binary token
  String token;

  /// String value of the CSID secret returned by fatoora/zatca
  String secret;

  /// The integer value of CSID request ID.
  int requestID;

  /// Tokeys constructor
  Tokeys({
    required this.token,
    required this.secret,
    required this.requestID,
  });

  /// Returns a json equivalent of the CSID object
  Map<String, dynamic> toJson() {
    return {"token": token, "secret": secret, "requestID": requestID};
  }

  /// Returns a String equivalent of the CSID object
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Constructs and returns CSID object from a CSID json object
  static Tokeys fromJson(json) {
    return Tokeys(
        token: json['token'],
        secret: json['secret'],
        requestID: json['requestID']);
  }

  static Future<Tokeys?> _readLocalValues(
      {required bool isForCompliance}) async {
    String? raw = await getFileContentAsString(
        isForCompliance ? 'ccsid.json' : 'pcsid.json',
        folder: '.tokens');
    return raw != null ? Tokeys.fromJson(jsonDecode(raw)) : null;
  }

  /// Save Production/Compliance CSID value to storage.
  Future<void> _saveToLocal({required bool isForCompliance}) async {
    await saveToFile(
        toJsonString(), isForCompliance ? 'ccsid.json' : 'pcsid.json',
        folder: '.tokens');
  }
}

/// Local Storage that holds most data for communication within the app
class LocalStore {
  LocalStore._() {
    _init();
  }

  /// Initialazing local store.
  Future<void> init() => _init();

  Future<void> _init() async {
    Tokeys._readLocalValues(isForCompliance: false).then((tokeys) {
      _pcsid = tokeys;
    });
    Tokeys._readLocalValues(isForCompliance: true).then((tokeys) {
      _ccsid = tokeys;
    });
    MyBusinessInfo.load().then((d) {
      myBusinessInfo = d;
    });
  }

  MyBusinessInfo? myBusinessInfo;

  static LocalStore? _instance;

  /// The single LocalStore instance accross usage.
  static LocalStore get instance => _instance ??= LocalStore._();

  Tokeys? _ccsid;
  Tokeys? _pcsid;

  /// Compliance CSID object returned from zatca/fatoora
  Tokeys? get ccsid => _ccsid;

  /// Production CSID object returned from zatca/fatoora
  Tokeys? get pcsid => _pcsid;

  /// Called to updated ccsid with the passed in object
  static updateCcsid(Tokeys tokeys) {
    tokeys._saveToLocal(isForCompliance: true);
    LocalStore.instance._ccsid = tokeys;
  }

  /// Called to updated pcsid with the passed in object
  static updatePcsid(Tokeys tokeys) {
    tokeys._saveToLocal(isForCompliance: false);
    LocalStore.instance._pcsid = tokeys;
  }

  Future<void> _convertCertAndSaveToStorage({required String cert}) async {
    try {
      String certInPemFormat = utf8.decode(base64.decode(cert));

      Future<void> updateCertInSDK() async {
        Directory? certDir = FatooraServiceFinder.instance.defaultCertDirectory;
        bool? canUpdate = await certDir?.exists();
        if (canUpdate != null && canUpdate && certDir != null) {
          saveToAbsolutePath(certInPemFormat,
              "${certDir.path}${Platform.pathSeparator}cert.pem");
        }
      }

      updateCertInSDK();
    } catch (e) {
      logError(
          "Couldn't convert cert/key to pem without header/footer and line-breaks $e");
    }
  }

  Future<void> switchCertInSDK({bool usePCSID = true}) async {
    return _convertCertAndSaveToStorage(
        cert: usePCSID ? pcsid!.token : ccsid!.token);
  }
}
