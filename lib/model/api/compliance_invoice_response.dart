enum CCSIDCheckResponseStatus { pass, error, unauthorized, invalidRequest, unknown }

class ComplianceInvoiceCheckResponse {
  final ValidationResults? validationResults;
  final String? reportingStatus;
  final String? clearanceStatus;
  final String? qrSellertStatus;
  final String? qrBuyertStatus;
  final ServerErrorResponse? serverErrorResponse;
  final UnauthorizedResponse? unauthorizedResponse;
  final CCSIDCheckResponseStatus status;
  final int statusCode;

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

  factory ComplianceInvoiceCheckResponse.fromJson(Map<String, dynamic> json, int statusCode) {
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

  Map<String, dynamic> toJson() => {
        'validationResults': validationResults?.toJson(),
        'reportingStatus': reportingStatus,
        'clearanceStatus': clearanceStatus,
        'qrSellertStatus': qrSellertStatus,
        'qrBuyertStatus': qrBuyertStatus,
        'status': status.name,
        'statusCode': statusCode,
      };

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

class MessageModel {
  final String type;
  final String code;
  final String category;
  final String message;
  final String status;

  MessageModel({
    required this.type,
    required this.code,
    required this.category,
    required this.message,
    required this.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      type: json['type'],
      code: json['code'],
      category: json['category'],
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'category': category,
        'message': message,
        'status': status,
      };
}

class UnauthorizedResponse {
  final int timestamp;
  final int statusCode;
  final String error;
  final String message;

  UnauthorizedResponse({
    required this.timestamp,
    required this.statusCode,
    required this.error,
    required this.message,
  });

  static UnauthorizedResponse? fromJson(Map<String, dynamic> json, int statusCode) {
    return statusCode == 401 ? UnauthorizedResponse(
      timestamp: json['timestamp'],
      statusCode: json['status'],
      error: json['error'],
      message: json['message'],
    ) : null;
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'status': statusCode,
        'error': error,
        'message': message,
      };
}

class ServerErrorResponse {
  final String code;
  final String message;
  final int statusCode;

  ServerErrorResponse({required this.code, required this.message, required this.statusCode});

  static ServerErrorResponse? fromJson(Map<String, dynamic> json, int statusCode) {
    return statusCode == 500 ? ServerErrorResponse(
      code: json['code'],
      message: json['message'],
      statusCode: statusCode,
    ):null;
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'statusCode': statusCode,
      };
}
