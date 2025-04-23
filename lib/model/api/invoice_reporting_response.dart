import 'invoice_clearance_response.dart';
import 'server_error_response.dart';
import 'unauthorized_response.dart';

/// Enum that represents the reporting status of an invoice to ZATCA.
enum ReportingResponseStatus {
  /// Invoice has been successfully reported.
  reported,

  /// Invoice has not been reported.
  notReported,

  /// The request was unauthorized.
  unauthorized,

  /// The request was malformed or invalid.
  invalidRequest,

  /// Status is unknown or not specified.
  unknown
}

/// Represents the response received after submitting an invoice for reporting.
class InvoiceReportingResponse {
  /// Results of validation checks returned by ZATCA.
  final ValidationResults? validationResults;

  /// Status of invoice reporting (e.g., "REPORTED", "NOT_REPORTED").
  final String? reportingStatus;

  /// Status of clearance if clearance was part of the process.
  final String? clearanceStatus;

  /// Status of the QR code for the seller.
  final String? qrSellertStatus;

  /// Status of the QR code for the buyer.
  final String? qrBuyertStatus;

  /// Server-side error response, if any occurred during processing.
  final ServerErrorResponse? serverErrorResponse;

  /// Unauthorized response details, if the request was not authorized.
  final UnauthorizedResponse? unauthorizedResponse;

  /// Enum representation of the high-level reporting status.
  final ReportingResponseStatus status;

  /// HTTP status code returned by the server.
  final int statusCode;

  /// Constructs an instance of [InvoiceReportingResponse].
  InvoiceReportingResponse({
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

  /// Creates an instance of [InvoiceReportingResponse] from JSON and status code.
  factory InvoiceReportingResponse.fromJson(
      Map<String, dynamic> json, int statusCode) {
    return InvoiceReportingResponse(
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

  /// Converts the [InvoiceReportingResponse] object to a JSON map.
  Map<String, dynamic> toJson() => {
        'validationResults': validationResults?.toJson(),
        'reportingStatus': reportingStatus,
        'clearanceStatus': clearanceStatus,
        'qrSellertStatus': qrSellertStatus,
        'qrBuyertStatus': qrBuyertStatus,
        'status': status.name,
        'statusCode': statusCode,
      };

  /// Parses a raw status string into a [ReportingResponseStatus] enum.
  static ReportingResponseStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'REPORTED':
        return ReportingResponseStatus.reported;
      case 'NOT_REPORTED':
        return ReportingResponseStatus.notReported;
      default:
        return ReportingResponseStatus.unknown;
    }
  }
}
