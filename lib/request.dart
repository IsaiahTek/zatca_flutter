import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';

import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/local_store.dart';
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
  /// To be used when testing the application through the developer portal.
  sandbox,

  /// To be used when testing the application through the simulation portal.
  simulation,

  /// To be used in production. This is what you use for live application.
  production,
}

/// Abstract class for handling core communication with zatca/fatoora server.
abstract class RequestBase {
  /// The mode of operation.
  final Mode mode;

  final LocalStore _store = LocalStore.instance;

  /// Production CSID values
  Tokeys? get pcsidTokeys => _store.pcsid;

  /// Compliance CSID values
  Tokeys? get ccsidTokeys => _store.ccsid;

  /// Constructor
  RequestBase({required this.mode});

  String get _complianceCSIDUrl => "$_base/compliance";
  String get _complianceCheckUrl => "$_base/compliance/invoices";
  String get _productionCSIDUrl => "$_base/production/csids";
  String get _productionCSIDRenewalUrl => "$_base/production/csids";
  String get _reportingUrl => "$_base/invoices/reporting/single";
  String get _clearanceUrl => "$_base/invoices/clearance/single";

  String get _base {
    String getBase(String e) =>
        "https://gw-fatoora.zatca.gov.sa/e-invoicing/$e";
    switch (mode) {
      case Mode.sandbox:
        return getBase("developer-portal");
      case Mode.production:
        return getBase("core");
      case Mode.simulation:
        return getBase("simulation");
    }
  }

  /// Make a request to Zatca/Fatoora server to get the Compliance CSID.
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
      Uri uri = Uri.parse(_complianceCSIDUrl);
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ComplianceCSIDResponse res = ComplianceCSIDResponse.fromJson(
            response.statusCode, jsonDecode(response.body));
        if (res.successData != null &&
            res.successData!.binarySecurityToken.isNotEmpty) {
          String token = res.successData!.binarySecurityToken;
          String secret = res.successData!.secret;
          int requestID = res.successData!.requestID;
          LocalStore.updateCcsid(
              Tokeys(token: token, secret: secret, requestID: requestID));
          // saveToFile(token, 'ccsid_binary_token',
          //     folder: '.tokens');
        }
        return res;
      } else {
        return ComplianceCSIDResponse(
          statusCode: 400,
          status: CSIDResponseStatus.serverError,
          failureData: ComplianceFailureData(
              code: response.statusCode.toString(), message: response.body),
        );
      }
    } catch (e) {
      return ComplianceCSIDResponse(
        statusCode: 500,
        status: CSIDResponseStatus.clientError,
        failureData: ComplianceFailureData(
            code: "Client-Error", message: "Failed to connect: $e"),
      );
    }
  }

  /// Request Compliance Check for invoice/note from Zatca/Fatoora Server
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
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        logInfo("Compliance RESPONSE json $jsonResponse");

        return ComplianceInvoiceCheckResponse.fromJson(
            jsonResponse, response.statusCode);
      } else {
        log('HTTP error: [REASON: ${response.reasonPhrase}, RESPONSE: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error checking compliance: $e');
      return null;
    }
  }

  /// Request Production CSID for onboarding
  Future<ProductionCSIDResponse> requestProductionCSIDOnboarding() async {
    return _requestProductionCSIDOnboarding();
  }

  Future<ProductionCSIDResponse> _requestProductionCSIDOnboarding() async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ccsidTokeys?.token}:${ccsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "compliance_request_id": ccsidTokeys?.requestID
    };

    try {
      final url = Uri.parse(_productionCSIDUrl);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ProductionCSIDResponse res = ProductionCSIDResponse.fromJson(
            response.statusCode, jsonDecode(response.body));
        if (res.successData != null &&
            res.successData!.binarySecurityToken.isNotEmpty) {
          String token = res.successData!.binarySecurityToken;
          String secret = res.successData!.secret;
          int requestID = res.successData!.requestID;
          LocalStore.updatePcsid(
              Tokeys(token: token, secret: secret, requestID: requestID));
          // saveToFile(token, 'pcsid_binary_token',
          //     folder: '.tokens');
        }
        return res;
      } else {
        return ProductionCSIDResponse(
          statusCode: response.statusCode,
          status: CSIDResponseStatus.serverError,
          failureData: ProductionCSIDFailureData(
              code: response.statusCode.toString(), message: response.body),
        );
      }
    } catch (e) {
      logError("Error requesting Production CSID $e");
      return ProductionCSIDResponse(
        statusCode: 500,
        status: CSIDResponseStatus.clientError,
        failureData: ProductionCSIDFailureData(
            code: "Client-Error", message: "Failed to connect: $e"),
      );
    }
  }

  /// Handle conversion and storage of Token & Key for Invoice/Note Signing.
  Future<void> convertTokenAndKeyToPemAndSaveToSDKForSigning(
      {required CertAndKey certAndKey}) async {
    return _convertTokenAndKeyToPemAndSaveToSDKForSigning(
        certAndKey: certAndKey);
  }

  Future<void> _convertTokenAndKeyToPemAndSaveToSDKForSigning(
      {required CertAndKey certAndKey}) async {
    try {
      String key = certAndKey.key;
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

      Directory? certDir = FatooraServiceFinder.instance.defaultCertDirectory;
      bool? canUpdate = await certDir?.exists();
      if (canUpdate != null && canUpdate && certDir != null) {
        saveToAbsolutePath(keyInPerFormat,
            "${certDir.path}${Platform.pathSeparator}ec-secp256k1-priv-key.pem");
      }
    } catch (e) {
      logError(
          "Couldn't convert cert/key to pem without header/footer and line-breaks $e");
    }
  }

  /// Request Production CSID Renewal.
  Future<ProductionCSIDRenewalResponse> requestProductionCSIDRenewal(
      {required PCSIDRenewalRequestProp prop}) async {
    return _requestProductionCSIDRenewal(prop: prop);
  }

  Future<ProductionCSIDRenewalResponse> _requestProductionCSIDRenewal(
      {required PCSIDRenewalRequestProp prop}) async {
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ProductionCSIDRenewalResponse res =
            ProductionCSIDRenewalResponse.fromJson(
                response.statusCode, jsonDecode(response.body));
        if (res.successData != null &&
            res.successData!.binarySecurityToken.isNotEmpty) {
          String token = res.successData!.binarySecurityToken;
          String secret = res.successData!.secret;
          int requestID = res.successData!.requestID;
          LocalStore.updatePcsid(
              Tokeys(token: token, secret: secret, requestID: requestID));
          // saveToFile(token, 'ccsid_binary_token',
          //     folder: '.tokens');
        }
        return res;
      } else {
        return ProductionCSIDRenewalResponse(
          statusCode: response.statusCode,
          status: CSIDResponseStatus.serverError,
          failureData: ProductionCSIDFailureData(
              code: response.statusCode.toString(), message: response.body),
        );
      }
    } catch (e) {
      return ProductionCSIDRenewalResponse(
        statusCode: 500,
        status: CSIDResponseStatus.clientError,
        failureData: ProductionCSIDFailureData(
            code: "Network-Error", message: "Failed to connect: $e"),
      );
    }
  }

  /// [B2C] Report an invoice/note to ZATCA/FATOORA Server
  Future<InvoiceReportingResponse?> requestReporting(
      InvoiceRequest prop) async {
    return _requestReporting(prop);
  }

  Future<InvoiceReportingResponse?> _requestReporting(
      InvoiceRequest prop) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${pcsidTokeys?.token}:${pcsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
      'Clearance-Status': '0' // Disabled
    };

    try {
      Uri url = Uri.parse(_reportingUrl);
      final body = jsonEncode(prop.toMap());
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        logInfo("RESPONSE json $jsonResponse");

        return InvoiceReportingResponse.fromJson(
            jsonResponse, response.statusCode);
      } else {
        log('HTTP error: [REASON: ${response.reasonPhrase}, RESPONSE: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error reporting invoice: $e');
      return null;
    }
  }

  /// [B2B] Make a clearance request for a STANDARD invoice or a STANDARD credit/debit note.
  Future<InvoiceClearanceResponse?> requestClearance(InvoiceRequest prop,
      {String? clearedInvoiceName}) async {
    return _requestClearance(prop);
  }

  Future<InvoiceClearanceResponse?> _requestClearance(InvoiceRequest prop,
      {String? clearedInvoiceName}) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${pcsidTokeys?.token}:${pcsidTokeys?.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
      'Clearance-Status': '1' // Enabled
    };

    try {
      final url = Uri.parse(_clearanceUrl);
      final body = jsonEncode(prop.toMap());
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        logInfo("RESPONSE json ${jsonResponse['validationResults']}");

        InvoiceClearanceResponse clearanceResponse =
            InvoiceClearanceResponse.fromJson(
                jsonResponse, response.statusCode);

        if (clearanceResponse.clearedInvoice != null) {
          String base64DecodedInvoice =
              utf8.decode(base64Decode(clearanceResponse.clearedInvoice!));
          String fileName = clearedInvoiceName ??
              'cleared_invoice-${getNowDateTimeYyyyMmDdHhMmSs()}.xml';
          await saveToFile(base64DecodedInvoice, fileName, folder: 'standard');
          clearanceResponse = InvoiceClearanceResponse.fromJson(
              {...jsonResponse, "fileName": fileName}, response.statusCode);
        }
        return clearanceResponse;
      } else {
        log('HTTP error: [REASON: ${response.reasonPhrase}, RESPONSE: ${response.body}]');
        return null;
      }
      // if (response.statusCode >= 200 && response.statusCode < 300) {
      // } else {
      //   log('HTTP error: ${response.reasonPhrase} AND ${response.body}');
      //   return null;
      // }
    } catch (e) {
      logError("ERROR CLEARING INVOICE: $e");
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
  DeveloperPortalRequestBase({super.mode = Mode.sandbox});
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
