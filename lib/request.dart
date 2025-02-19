import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';

import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/api/compliance_invoice_response.dart';
import 'package:zatca_flutter/model/api/compliance_csid_response.dart';
import 'package:http/http.dart' as http;
import 'package:zatca_flutter/model/api/production_csid_response.dart';
import 'package:zatca_flutter/model/cert_and_key.dart';
import 'package:zatca_flutter/model/csr_request.dart';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/model/pcsid_request_prop.dart';
import 'package:zatca_flutter/service/fatoora_service_finder.dart';
import 'package:zatca_flutter/service/util.dart';

enum Mode { simulation, developerPortal, production }

abstract class RequestBase {
  final Mode mode;
  String get _complianceCSIDUrl => "$_base/compliance";
  String get _complianceCheckUrl => "$_base/compliance/invoices";
  String get _productionCSIDUrl => "$_base/production/csids";
  String get _productionCSIDRenewalUrl => "$_base/production/csids";
  String get _reportingUrl => "$_base/invoices/reporting/single";
  String get _clearanceUrl => "$_base/invoices/clearance/single";

  const RequestBase({required this.mode});

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

      return ComplianceCSIDResponse.fromJson(
          response.statusCode, jsonDecode(response.body));
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
      {required String username,
      required String password,
      required InvoiceRequest prop}) async {
    return _requestComplianceCheck(
        username: username, password: password, prop: prop);
  }

  Future<ComplianceInvoiceCheckResponse?> _requestComplianceCheck(
      {required String username,
      required String password,
      required InvoiceRequest prop}) async {
    final url = Uri.parse(_complianceCheckUrl);

    // Encode username:password to Base64 for Basic Authentication
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'invoiceHash': prop.invoiceHash,
      'uuid': prop.uuid,
      'invoice': prop.invoice,
    });

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      final jsonResponse = jsonDecode(response.body);

      return ComplianceInvoiceCheckResponse.fromJson(
          jsonResponse, response.statusCode);
    } catch (e) {
      log('Error submitting invoice: $e');
      return null;
    }
  }

  Future<ProductionCSIDResponse> requestProductionCSIDOnboarding(
      {required PCSIDRequestProp prop}) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${prop.binarySecurityToken}:${prop.secret}'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': 'V2',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "compliance_request_id":
          prop.requestId // Only CSR is sent in the request body
    };

    try {
      final url = Uri.parse(_productionCSIDUrl);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      return ProductionCSIDResponse.fromJson(
          response.statusCode, jsonDecode(response.body));
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

      // Decode Base64 input to DER bytes
      Uint8List pkcs8DerBytes = base64Decode(pkcs8Base64);
      ASN1Parser asn1Parser = ASN1Parser(pkcs8DerBytes);

      // Parse PKCS#8 top-level sequence
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

  Future<void> requestProductionCSIDRenewal() async {
    final url = Uri.parse(_productionCSIDRenewalUrl);
    http.patch(url);
  }

  Future<void> requestReporting() async {
    final url = Uri.parse(_reportingUrl);
    http.post(url);
  }

  Future<void> requestClearance() async {
    final url = Uri.parse(_clearanceUrl);
    http.post(url);
  }
}

abstract class SimulationRequestBase extends RequestBase {
  SimulationRequestBase({super.mode = Mode.simulation});
}

class SimulationRequest extends SimulationRequestBase {}

class DeveloperPortalRequestBase extends RequestBase {
  DeveloperPortalRequestBase({super.mode = Mode.developerPortal});
}

class DeveloperPortalRequest extends DeveloperPortalRequestBase {}

class ProductionRequestBase extends RequestBase {
  ProductionRequestBase({super.mode = Mode.production});
}

class ProductionRequest extends ProductionRequestBase {}

class RequestTypes {
  SimulationRequest simulation = SimulationRequest();

  DeveloperPortalRequest developerPortal = DeveloperPortalRequest();

  ProductionRequest production = ProductionRequest();
}
