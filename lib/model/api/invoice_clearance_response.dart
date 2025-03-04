import 'message.dart';
import 'server_error_response.dart';
import 'unauthorized_response.dart';

enum InvoiceClearanceResponseStatus { cleared, notCleared, unauthorized, invalidRequest, unknown }

class InvoiceClearanceResponse {
  final ValidationResults? validationResults;
  final String? reportingStatus;
  final String? clearanceStatus;
  final String? qrSellertStatus;
  final String? qrBuyertStatus;
  final ServerErrorResponse? serverErrorResponse;
  final UnauthorizedResponse? unauthorizedResponse;
  final InvoiceClearanceResponseStatus status;
  final int statusCode;

  InvoiceClearanceResponse({
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

  factory InvoiceClearanceResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    return InvoiceClearanceResponse(
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

  static InvoiceClearanceResponseStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PASS':
        return InvoiceClearanceResponseStatus.cleared;
      case 'ERROR':
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

  ValidationResults({this.infoMessages, this.warningMessages, this.errorMessages});

  factory ValidationResults.fromJson(Map<String, dynamic> json) {
    return ValidationResults(
      infoMessages: _parseMessages(json['infoMessages']),
      warningMessages: _parseMessages(json['warningMessages']),
      errorMessages: _parseMessages(json['errorMessages']),
    );
  }

  Map<String, dynamic> toJson() => {
        'infoMessages': infoMessages?.map((m) => m.toJson()).toList(),
        'warningMessages': warningMessages?.map((m) => m.toJson()).toList(),
        'errorMessages': errorMessages?.map((m) => m.toJson()).toList(),
      };

  static List<MessageModel>? _parseMessages(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => MessageModel.fromJson(e)).toList();
    } else {
      return [MessageModel.fromJson(data)];
    }
  }
}
