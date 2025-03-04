import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';

import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/api/compliance_invoice_response.dart';
import 'package:zatca_flutter/model/api/compliance_csid_response.dart';
import 'package:http/http.dart' as http;
import 'package:zatca_flutter/model/api/invoice_clearance_response.dart';
import 'package:zatca_flutter/model/api/invoice_reporting_response.dart';
import 'package:zatca_flutter/model/api/production_csid_response.dart';
import 'package:zatca_flutter/model/cert_and_key.dart';
import 'package:zatca_flutter/model/api/csr_request.dart';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/service/fatoora_service_finder.dart';
import 'package:zatca_flutter/service/util.dart';

/// Application mode.
enum Mode {
  /// To be used when testing the application through the developer portal
  developerPortal,
  
  /// To be used when testing the application through the simulation portal
  simulation,

  /// To be used when in production mode. This what you use for live application
  production,
  
}

/// Local Storage that holds most data for communication within the app
class LocalStore{
  LocalStore._(){
    Tokeys._readLocalValues(isForCompliance: false).then((tokeys){
      _pcsid = tokeys;
    });
    Tokeys._readLocalValues(isForCompliance: true).then((tokeys){
      _ccsid = tokeys;
    });
  }

  static LocalStore? _instance;

  /// The single LocalStore instance accross usage.
  static LocalStore get instance => _instance??=LocalStore._();

  Tokeys? _ccsid;
  Tokeys? _pcsid;

  /// Compliance CSID object returned from zatca/fatoora
  Tokeys? get ccsid => _ccsid;

  /// Production CSID object returned from zatca/fatoora
  Tokeys? get pcsid => _pcsid;

  /// Called to updated ccsid with the passed in object
  static updateCcsid(Tokeys tokeys){
    tokeys._saveToLocal(isForCompliance: true);
    LocalStore.instance._ccsid = tokeys;
  }

  /// Called to updated pcsid with the passed in object
  static updatePcsid(Tokeys tokeys){
    tokeys._saveToLocal(isForCompliance: false);
    LocalStore.instance._pcsid = tokeys;
  }

}

/// The model used by CSIDs
class Tokeys{

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
  Map<String, dynamic> toJson(){
    return {
      "token": token,
      "secret": secret,
      "requestID": requestID
    };
  }

  /// Returns a String equivalent of the CSID object
  String toJsonString(){
    return jsonEncode(toJson());
  }

  /// Constructs and returns CSID object from a CSID json object
  static Tokeys fromJson(json){
    return Tokeys(token: json['token'], secret: json['secret'], requestID: json['requestID']);
  }

  static Future<Tokeys> _readLocalValues({required bool isForCompliance}) async {
    String raw = await getFileContentAsString(isForCompliance?'ccsid.json':'pcsid.json', folder: '.tokens');
    return Tokeys.fromJson(jsonDecode(raw));
  }

  /// Save Production/Compliance CSID value to storage.
  Future<void> _saveToLocal({required bool isForCompliance}) async {
    await saveToFile(toJsonString(), isForCompliance?'ccsid.json':'pcsid.json', folder: '.tokens');
  }

}

/// Abstract class for handling core communication with zatca/fatoora server.
abstract class RequestBase {

  /// Set the mode of operation.
  final Mode mode;
  String get _complianceCSIDUrl => "$_base/compliance";
  String get _complianceCheckUrl => "$_base/compliance/invoices";
  String get _productionCSIDUrl => "$_base/production/csids";
  String get _productionCSIDRenewalUrl => "$_base/production/csids";
  String get _reportingUrl => "$_base/invoices/reporting/single";
  String get _clearanceUrl => "$_base/invoices/clearance/single";

  
  late LocalStore _store;

  /// Production CSID values
  Tokeys? get pcsidTokeys => _store.pcsid;

  /// Compliance CSID values
  Tokeys? get ccsidTokeys => _store.ccsid;

  RequestBase({required this.mode}){
    _store = LocalStore.instance;
  }

  String get _base {
    String getBase(String e) =>
        "https://gw-fatoora.zatca.gov.sa/e-invoicing/$e";
    switch (mode) {
      case Mode.developerPortal:
        return getBase("developer-portal");
      case Mode.production:
        return getBase("core");
      case Mode.simulation:
        return getBase("simulation");
    }
  }

  /// CSR value should be base64 encoded and not a PEM value.
  Future<ComplianceCSIDResponse> requestComplianceCSID(
      {required CCSIDRequestProp request}) async {
    return _requestComplianceCSID(request: request);
  }

  Future<ComplianceCSIDResponse> _requestComplianceCSID(
      {required CCSIDRequestProp request}) async {
    final Map<String, String> headers = {
      'Accept-Version': 'V2', // Ensure correct API version
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'OTP': request.otp, // OTP is required in headers
    };

    final Map<String, dynamic> body = {
      "csr": request.csr // Only CSR is sent in the request body
    };

    try {
      final response = await http.post(
        Uri.parse(_complianceCSIDUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      ComplianceCSIDResponse res = ComplianceCSIDResponse.fromJson(
          response.statusCode, jsonDecode(response.body));
      if (res.successData != null &&
          res.successData!.binarySecurityToken.isNotEmpty) {
            String token = res.successData!.binarySecurityToken;
            String secret = res.successData!.secret;
            int requestID = res.successData!.requestID;
            LocalStore.updateCcsid(Tokeys(token: token, secret: secret, requestID: requestID));
        // saveToFile(token, 'ccsid_binary_token',
        //     folder: '.tokens');
      }
      return res;
    } catch (e) {
      return ComplianceCSIDResponse(
        statusCode: 500,
        status: CSIDResponseStatus.serverError,
        failureData: ComplianceFailureData(
            code: "Network-Error", message: "Failed to connect: $e"),
      );
    }
  }

  /// Re
  Future<ComplianceInvoiceCheckResponse?> requestComplianceCheck(
      {required InvoiceRequest prop}) async {
    return _requestComplianceCheck(prop: prop);
  }

  Future<ComplianceInvoiceCheckResponse?> _requestComplianceCheck(
      {required InvoiceRequest prop}) async {
    final url = Uri.parse(_complianceCheckUrl);

    // Encode username:password to Base64 for Basic Authentication
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ccsidTokeys?.token}:${ccsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
    };


    try {
      final body = jsonEncode(prop.toMap());
      logInfo("Compliance check body: $body AND URL $url");
      final response =
          await http.post(url, headers: headers, body: body);
          
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        logInfo("RESPONSE json $jsonResponse");

        return ComplianceInvoiceCheckResponse.fromJson(
            jsonResponse, response.statusCode);
      } else {
        log('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error submitting invoice: $e');
      return null;
    }
  }

  Future<ProductionCSIDResponse> requestProductionCSIDOnboarding() async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ccsidTokeys?.token}:${ccsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "compliance_request_id":
          ccsidTokeys?.requestID
    };

    try {
      final url = Uri.parse(_productionCSIDUrl);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      ProductionCSIDResponse res = ProductionCSIDResponse.fromJson(
          response.statusCode, jsonDecode(response.body));
      if (res.successData != null &&
          res.successData!.binarySecurityToken.isNotEmpty) {
            String token = res.successData!.binarySecurityToken;
            String secret = res.successData!.secret;
            int requestID = res.successData!.requestID;
            LocalStore.updatePcsid(Tokeys(token: token, secret: secret, requestID: requestID));
        // saveToFile(token, 'pcsid_binary_token',
        //     folder: '.tokens');
      }
      return res;
    } catch (e) {
      logError("Error requesting Production CSID $e");
      return ProductionCSIDResponse(
        statusCode: 500,
        status: CSIDResponseStatus.serverError,
        failureData: ProductionCSIDFailureData(
            code: "Network-Error", message: "Failed to connect: $e"),
      );
    }
  }

  Future<void> convertTokenAndKeyToPemAndSaveToSDKForSigning(
      {required CertAndKey certAndKey}) async {
    try {
      String cert = certAndKey.cert;
      String key = certAndKey.key;
      String certInPemFormat = utf8.decode(base64.decode(cert));

      String pkcs8Base64 = key;

      Uint8List pkcs8DerBytes = base64Decode(pkcs8Base64);
      ASN1Parser asn1Parser = ASN1Parser(pkcs8DerBytes);

      ASN1Sequence pkcs8Sequence = asn1Parser.nextObject() as ASN1Sequence;
      if (pkcs8Sequence.elements.length < 3) {
        throw Exception("Invalid PKCS#8 structure.");
      }

      // Extract the private key from the third element (ASN1OctetString)
      ASN1OctetString privateKeyOctet =
          pkcs8Sequence.elements[2] as ASN1OctetString;
      Uint8List privateKeyBytes = privateKeyOctet.valueBytes();

      // logError("RAW TOKEN: $cert");
      // logError("DECODED CERT: $certInPemFormat");
      String keyInPerFormat = base64Encode(privateKeyBytes);

      saveToAbsolutePath(String content, String path) {
        File file = File(path);
        file.writeAsString(content);
      }

      Future<void> updateCertInSDK() async {
        Directory? certDir = FatooraServiceFinder.instance.defaultCertDirectory;
        bool? canUpdate = await certDir?.exists();
        if (canUpdate != null && canUpdate && certDir != null) {
          saveToAbsolutePath(keyInPerFormat,
              "${certDir.path}${Platform.pathSeparator}ec-secp256k1-priv-key.pem");
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

  Future<ProductionCSIDRenewalResponse> requestProductionCSIDRenewal({required PCSIDRenewalRequestProp prop}) async {
    final Map<String, String> headers = {
      'Accept-Version': 'V2', // Ensure correct API version
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'OTP': prop.otp, // OTP is required in headers
    };

    final Map<String, dynamic> body = {
      "csr": prop.csr // Only CSR is sent in the request body
    };

    try {
      final url = Uri.parse(_productionCSIDRenewalUrl);
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      ProductionCSIDRenewalResponse res = ProductionCSIDRenewalResponse.fromJson(
          response.statusCode, jsonDecode(response.body));
      if (res.successData != null &&
          res.successData!.binarySecurityToken.isNotEmpty) {
            String token = res.successData!.binarySecurityToken;
            String secret = res.successData!.secret;
            int requestID = res.successData!.requestID;
            LocalStore.updatePcsid(Tokeys(token: token, secret: secret, requestID: requestID));
        // saveToFile(token, 'ccsid_binary_token',
        //     folder: '.tokens');
      }
      return res;
    } catch (e) {
      return ProductionCSIDRenewalResponse(
        statusCode: 500,
        status: CSIDResponseStatus.serverError,
        failureData: ProductionCSIDFailureData(
            code: "Network-Error", message: "Failed to connect: $e"),
      );
    }
  }

  Future<InvoiceReportingResponse?> requestReporting(InvoiceRequest prop) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ccsidTokeys?.token}:${ccsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
      // 'Clearance-Status': '0'
    };

    final Map<String, dynamic> body = prop.toMap();

    try {
      final url = Uri.parse(_reportingUrl);
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      InvoiceReportingResponse res = InvoiceReportingResponse.fromJson(
          jsonDecode(response.body), response.statusCode);
    
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<InvoiceClearanceResponse?> requestClearance(InvoiceRequest prop) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ccsidTokeys?.token}:${ccsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
      // 'Clearance-Status': '0'
    };

    final Map<String, dynamic> body = prop.toMap();

    try {
      final url = Uri.parse(_clearanceUrl);
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      InvoiceClearanceResponse res = InvoiceClearanceResponse.fromJson(jsonDecode(response.body), response.statusCode);
      
      return res;
    } catch (e) {
      return null;
    }
  }
}

///
abstract class SimulationRequestBase extends RequestBase {
  ///
  SimulationRequestBase({super.mode = Mode.simulation});
}
///
class SimulationRequest extends SimulationRequestBase {}
///
class DeveloperPortalRequestBase extends RequestBase {
  ///
  DeveloperPortalRequestBase({super.mode = Mode.developerPortal});
}
///
class DeveloperPortalRequest extends DeveloperPortalRequestBase {}
///
class ProductionRequestBase extends RequestBase {
  ///
  ProductionRequestBase({super.mode = Mode.production});
}
///
class ProductionRequest extends ProductionRequestBase {}
///
class RequestTypes {
  ///
  SimulationRequest simulation = SimulationRequest();
  ///
  DeveloperPortalRequest developerPortal = DeveloperPortalRequest();
  ///
  ProductionRequest production = ProductionRequest();
}
