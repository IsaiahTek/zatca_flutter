import 'invoice_clearance_response.dart';
import 'server_error_response.dart';
import 'unauthorized_response.dart';

enum ReportingResponseStatus {
  reported,
  notReported,
  unauthorized,
  invalidRequest,
  unknown
}

class InvoiceReportingResponse {
  final ValidationResults? validationResults;
  final String? reportingStatus;
  final String? clearanceStatus;
  final String? qrSellertStatus;
  final String? qrBuyertStatus;
  final ServerErrorResponse? serverErrorResponse;
  final UnauthorizedResponse? unauthorizedResponse;
  final ReportingResponseStatus status;
  final int statusCode;

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

  Map<String, dynamic> toJson() => {
        'validationResults': validationResults?.toJson(),
        'reportingStatus': reportingStatus,
        'clearanceStatus': clearanceStatus,
        'qrSellertStatus': qrSellertStatus,
        'qrBuyertStatus': qrBuyertStatus,
        'status': status.name,
        'statusCode': statusCode,
      };

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
