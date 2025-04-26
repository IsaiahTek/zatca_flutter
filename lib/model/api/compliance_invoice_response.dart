import 'invoice_clearance_response.dart';
import 'server_error_response.dart';
import 'unauthorized_response.dart';

/// Enum representing the possible status outcomes of an invoice compliance check.
enum CCSIDCheckResponseStatus {
  /// The invoice passed all validation checks.
  pass,

  /// An error occurred during the validation process.
  error,

  /// The request was unauthorized.
  unauthorized,

  /// The request was malformed or invalid.
  invalidRequest,

  /// The response status could not be determined.
  unknown
}

/// Response model for invoice compliance status checking.
///
/// This model is used to represent the outcome of a compliance check for an invoice submission to ZATCA.
/// It captures both successful validations and various error cases including unauthorized access or server failures.
class ComplianceInvoiceCheckResponse {
  /// Contains detailed results of the validation process if available.
  final ValidationResults? validationResults;

  /// Indicates the reporting status of the invoice (e.g., "REPORTED", "NOT_REPORTED").
  final String? reportingStatus;

  /// Indicates the clearance status of the invoice (e.g., "CLEARED", "NOT_CLEARED").
  final String? clearanceStatus;

  /// QR code status as seen by the seller side, useful for QR validation.
  final String? qrSellertStatus;

  /// QR code status as seen by the buyer side, useful for QR validation.
  final String? qrBuyertStatus;

  /// Represents server-side error response, if a server error occurred.
  final ServerErrorResponse? serverErrorResponse;

  /// Represents the response data when a request is unauthorized (HTTP 401/403).
  final UnauthorizedResponse? unauthorizedResponse;

  /// Represents the overall status of the response based on server interpretation.
  final CCSIDCheckResponseStatus status;

  /// The HTTP status code of the response.
  final int statusCode;

  /// Constructor for creating a [ComplianceInvoiceCheckResponse] instance.
  ComplianceInvoiceCheckResponse({
    this.validationResults,
    this.reportingStatus,
    this.clearanceStatus,
    this.qrSellertStatus,
    this.qrBuyertStatus,
    this.serverErrorResponse,
    this.unauthorizedResponse,
    required this.status,
    required this.statusCode,
  });

  /// Factory constructor that creates a [ComplianceInvoiceCheckResponse] object from JSON.
  ///
  /// It attempts to parse fields like validation results, reporting/clearance status,
  /// QR code statuses, and any potential error responses based on the HTTP status code.
  factory ComplianceInvoiceCheckResponse.fromJson(
      Map<String, dynamic> json, int statusCode) {
    return ComplianceInvoiceCheckResponse(
      validationResults: json['validationResults'] != null
          ? ValidationResults.fromJson(json['validationResults'])
          : null,
      serverErrorResponse: ServerErrorResponse.fromJson(json, statusCode),
      unauthorizedResponse: UnauthorizedResponse.fromJson(json, statusCode),
      reportingStatus: json['reportingStatus'],
      clearanceStatus: json['clearanceStatus'],
      qrSellertStatus: json['qrSellertStatus'],
      qrBuyertStatus: json['qrBuyertStatus'],
      status: _parseStatus(json['status']),
      statusCode: statusCode,
    );
  }

  /// Converts the [ComplianceInvoiceCheckResponse] instance back to a JSON map.
  Map<String, dynamic> toJson() => {
        'validationResults': validationResults?.toJson(),
        'reportingStatus': reportingStatus,
        'clearanceStatus': clearanceStatus,
        'qrSellertStatus': qrSellertStatus,
        'qrBuyertStatus': qrBuyertStatus,
        'status': status.name,
        'statusCode': statusCode,
      };

  /// Helper method to convert a string status into an enum value.
  static CCSIDCheckResponseStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PASS':
        return CCSIDCheckResponseStatus.pass;
      case 'ERROR':
        return CCSIDCheckResponseStatus.error;
      default:
        return CCSIDCheckResponseStatus.unknown;
    }
  }
}
