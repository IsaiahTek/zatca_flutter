import 'message.dart';
import 'server_error_response.dart';
import 'unauthorized_response.dart';
import 'util.dart';

enum InvoiceClearanceResponseStatus {
  cleared,
  notCleared,
  unauthorized,
  invalidRequest,
  unknown
}

class ClearanceData {
  String clearedInvoice;
  String clearanceStatus;

  ClearanceData({required this.clearanceStatus, required this.clearedInvoice});

  static ClearanceData fromJson(Map<String, dynamic> json) {
    return ClearanceData(
      clearanceStatus: json['clearanceStatus'],
      clearedInvoice: json['clearedInvoice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clearanceStatus': clearanceStatus,
      'clearedInvoice': clearedInvoice,
    };
  }
}

class InvoiceClearanceResponse {
  final ValidationResults? validationResults;
  final ClearanceData? clearanceData;
  final String? clearanceStatus;
  final String? invoiceHash;
  final String? clearedInvoice;
  final ServerErrorResponse? serverErrorResponse;
  final UnauthorizedResponse? unauthorizedResponse;
  final InvoiceClearanceResponseStatus status;
  final int statusCode;

  InvoiceClearanceResponse({
    this.validationResults,
    this.clearanceData,
    this.clearanceStatus,
    this.serverErrorResponse,
    this.unauthorizedResponse,
    this.clearedInvoice,
    this.invoiceHash,
    required this.status,
    required this.statusCode,
  });

  factory InvoiceClearanceResponse.fromJson(
      Map<String, dynamic> json, int statusCode) {
    return InvoiceClearanceResponse(
      validationResults: ValidationResults.fromJson(json['validationResults']),
      clearanceData: json['validationResults'] != null
          ? ClearanceData.fromJson(json)
          : null,
      serverErrorResponse: ServerErrorResponse.fromJson(json, statusCode),
      unauthorizedResponse: UnauthorizedResponse.fromJson(json, statusCode),
      clearanceStatus: json['clearanceStatus'],
      status: _parseStatus(json['clearanceStatus']),
      statusCode: statusCode,
      invoiceHash: json['invoiceHash'],
      clearedInvoice: json['clearedInvoice'],
    );
  }

  Map<String, dynamic> toJson() => {
        'validationResults': validationResults?.toJson(),
        'clearanceData': clearanceData?.toJson(),
        'clearanceStatus': clearanceStatus,
        'status': status.name,
        'statusCode': statusCode,
      };

  static InvoiceClearanceResponseStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'cleared':
        return InvoiceClearanceResponseStatus.cleared;
      case 'not cleared':
        return InvoiceClearanceResponseStatus.notCleared;
      default:
        return InvoiceClearanceResponseStatus.unknown;
    }
  }
}

class ValidationResults {
  final List<MessageModel>? infoMessages;
  final List<MessageModel>? warningMessages;
  final List<MessageModel>? errorMessages;
  final String? status;

  ValidationResults(
      {this.infoMessages,
      this.warningMessages,
      this.errorMessages,
      this.status});

  factory ValidationResults.fromJson(Map<String, dynamic> json) {
    return ValidationResults(
        infoMessages: parseMessages(json['infoMessages']),
        warningMessages: parseMessages(json['warningMessages']),
        errorMessages: parseMessages(json['errorMessages']),
        status: json['status']);
  }

  Map<String, dynamic> toJson() => {
        'infoMessages': infoMessages?.map((m) => m.toJson()).toList(),
        'warningMessages': warningMessages?.map((m) => m.toJson()).toList(),
        'errorMessages': errorMessages?.map((m) => m.toJson()).toList(),
        'status': status
      };
}
