import 'dart:convert';

/// Enum representing different response statuses
enum CCSIDResponseStatus { success, clientError, serverError, unknown }

/// Main response model for Compliance CSID API
class ComplianceCSIDResponse {
  final int statusCode;
  final CCSIDResponseStatus status;
  final ComplianceSuccessData? successData;
  final ComplianceErrorData? errorData;
  final ComplianceFailureData? failureData;

  ComplianceCSIDResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate response type (Success, Error, or Failure).
  factory ComplianceCSIDResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    CCSIDResponseStatus status = _getStatus(statusCode);

    if (status == CCSIDResponseStatus.success && json.containsKey('requestID')) {
      return ComplianceCSIDResponse(
        statusCode: statusCode,
        status: status,
        successData: ComplianceSuccessData.fromJson(json),
      );
    } else if (status == CCSIDResponseStatus.clientError && json.containsKey('errors')) {
      return ComplianceCSIDResponse(
        statusCode: statusCode,
        status: status,
        errorData: ComplianceErrorData.fromJson(json),
      );
    } else if (status == CCSIDResponseStatus.serverError && json.containsKey('code') && json.containsKey('message')) {
      return ComplianceCSIDResponse(
        statusCode: statusCode,
        status: status,
        failureData: ComplianceFailureData.fromJson(json),
      );
    } else {
      return ComplianceCSIDResponse(statusCode: statusCode, status: CCSIDResponseStatus.unknown);
    }
  }

  /// Converts the model back to JSON.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'statusCode': statusCode, 'status': status.toString().split('.').last};
    if (successData != null) json.addAll(successData!.toJson());
    if (errorData != null) json.addAll(errorData!.toJson());
    if (failureData != null) json.addAll(failureData!.toJson());
    return json;
  }

  /// Determines the response status based on the status code.
  static CCSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CCSIDResponseStatus.success;
    if (statusCode == 400) return CCSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) return CCSIDResponseStatus.serverError;
    return CCSIDResponseStatus.unknown;
  }
}

/// ✅ Success Response (200 OK)
class ComplianceSuccessData {
  final int requestID;
  final String dispositionMessage;
  final String binarySecurityToken;
  final String secret;

  ComplianceSuccessData({
    required this.requestID,
    required this.dispositionMessage,
    required this.binarySecurityToken,
    required this.secret,
  });

  factory ComplianceSuccessData.fromJson(Map<String, dynamic> json) {
    return ComplianceSuccessData(
      requestID: json['requestID'],
      dispositionMessage: json['dispositionMessage'],
      binarySecurityToken: json['binarySecurityToken'],
      secret: json['secret'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'dispositionMessage': dispositionMessage,
      'binarySecurityToken': binarySecurityToken,
      'secret': secret,
    };
  }
}

/// ❌ Client Errors (400 Bad Request)
class ComplianceErrorData {
  final List<ComplianceError> errors;

  ComplianceErrorData({required this.errors});

  factory ComplianceErrorData.fromJson(Map<String, dynamic> json) {
    return ComplianceErrorData(
      errors: (json['errors'] as List)
          .map((e) => ComplianceError.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map((e) => e.toJson()).toList(),
    };
  }
}

/// 🚨 Specific Error Model
class ComplianceError {
  final String code;
  final String message;

  ComplianceError({required this.code, required this.message});

  factory ComplianceError.fromJson(Map<String, dynamic> json) {
    return ComplianceError(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

/// ⚠️ Server Errors (406, 500, etc.)
class ComplianceFailureData {
  final String code;
  final String message;

  ComplianceFailureData({required this.code, required this.message});

  factory ComplianceFailureData.fromJson(Map<String, dynamic> json) {
    return ComplianceFailureData(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

/// Parses a JSON string into a ComplianceCSIDResponse object.
ComplianceCSIDResponse parseComplianceCSIDResponse(int statusCode, String jsonStr) {
  return ComplianceCSIDResponse.fromJson(statusCode, jsonDecode(jsonStr));
}
