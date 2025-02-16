import 'dart:convert';

import 'package:zatca_flutter/model/api/compliance_invoice_response.dart';
import 'package:zatca_flutter/model/api/compliance_response.dart';
import 'package:zatca_flutter/model/csr_config.dart';
import 'package:http/http.dart' as http;

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
      {required String csr, required String otp}) async {
    return _requestComplianceCSID(csr: csr, otp: otp);
  }

  Future<ComplianceCSIDResponse> _requestComplianceCSID(
      {required String csr, required String otp}) async {
    final Map<String, String> headers = {
      'Accept-Version': 'V2', // Ensure correct API version
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'OTP': otp, // OTP is required in headers
    };

    final Map<String, dynamic> body = {
      "csr": csr // Only CSR is sent in the request body
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
        status: CCSIDResponseStatus.serverError,
        failureData: ComplianceFailureData(
            code: "Network-Error", message: "Failed to connect: $e"),
      );
    }
  }

  /// Re
  Future<ComplianceInvoiceCheckResponse?> requestComplianceCheck(
      {required String username,
      required String password,
      required String invoiceHash,
      required String uuid,
      required String invoice}) async {
    return _requestComplianceCheck(
        username: username,
        password: password,
        invoiceHash: invoiceHash,
        uuid: uuid,
        invoice: invoice);
  }

  Future<ComplianceInvoiceCheckResponse?> _requestComplianceCheck(
      {required String username,
      required String password,
      required String invoiceHash,
      required String uuid,
      required String invoice}) async {
    final url = Uri.parse(_complianceCheckUrl);

    // Encode username:password to Base64 for Basic Authentication
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Accept-Language': 'en',
      'Accept-Version': '1.0',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'invoiceHash': invoiceHash,
      'uuid': uuid,
      'invoice': invoice,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      final jsonResponse = jsonDecode(response.body);

      return ComplianceInvoiceCheckResponse.fromJson(
          jsonResponse, response.statusCode);
    } catch (e) {
      print('Error submitting invoice: $e');
      return null;
    }
  }

  Future<void> requestProductionCSIDOnboarding() async {}
  Future<void> requestProductionCSIDRenewal() async {}
  Future<void> requestReporting() async {}
  Future<void> requestClearance() async {}
}

class SimulationRequest extends RequestBase {
  SimulationRequest({required super.mode});
}

class DeveloperPortalRequest extends RequestBase {
  DeveloperPortalRequest({required super.mode});
}

class ProductionRequest extends RequestBase {
  ProductionRequest({required super.mode});
}

class RequestTypes {
  SimulationRequest simulation = SimulationRequest(mode: Mode.simulation);

  DeveloperPortalRequest developerPortal =
      DeveloperPortalRequest(mode: Mode.developerPortal);

  ProductionRequest production = ProductionRequest(mode: Mode.production);
}
