import 'dart:convert';

import 'package:zatca_flutter/enums.dart';


/// Main response model for Production CSID API
class ProductionCSIDResponse {
  final int statusCode;
  final CSIDResponseStatus status;
  final ProductionCSIDSuccessData? successData;
  final ProductionCSIDErrorData? errorData;
  final ProductionCSIDFailureData? failureData;

  ProductionCSIDResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate response type (Success, Error, or Failure).
  factory ProductionCSIDResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    CSIDResponseStatus status = _getStatus(statusCode);

    if (status == CSIDResponseStatus.success && json.containsKey('requestID')) {
      return ProductionCSIDResponse(
        statusCode: statusCode,
        status: status,
        successData: ProductionCSIDSuccessData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.clientError && json.containsKey('errors')) {
      return ProductionCSIDResponse(
        statusCode: statusCode,
        status: status,
        errorData: ProductionCSIDErrorData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.serverError && json.containsKey('code') && json.containsKey('message')) {
      return ProductionCSIDResponse(
        statusCode: statusCode,
        status: status,
        failureData: ProductionCSIDFailureData.fromJson(json),
      );
    } else {
      return ProductionCSIDResponse(statusCode: statusCode, status: CSIDResponseStatus.unknown);
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
  static CSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CSIDResponseStatus.success;
    if (statusCode == 400) return CSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) return CSIDResponseStatus.serverError;
    return CSIDResponseStatus.unknown;
  }
}

/// ✅ Success Response (200 OK)
class ProductionCSIDSuccessData {
  final int requestID;
  final String dispositionMessage;
  final String binarySecurityToken;
  final String secret;

  ProductionCSIDSuccessData({
    required this.requestID,
    required this.dispositionMessage,
    required this.binarySecurityToken,
    required this.secret,
  });

  factory ProductionCSIDSuccessData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDSuccessData(
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

/// ✅ Success Response (200 OK)
class ProductionCSIDRenewalSuccessData {
  final int requestID;
  final String dispositionMessage;
  final String binarySecurityToken;
  final String secret;
  final String tokenType;

  ProductionCSIDRenewalSuccessData({
    required this.requestID,
    required this.dispositionMessage,
    required this.binarySecurityToken,
    required this.secret,
    required this.tokenType
  });

  factory ProductionCSIDRenewalSuccessData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDRenewalSuccessData(
      requestID: json['requestID'],
      dispositionMessage: json['dispositionMessage'],
      binarySecurityToken: json['binarySecurityToken'],
      secret: json['secret'],
      tokenType: json['tokenType']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'dispositionMessage': dispositionMessage,
      'binarySecurityToken': binarySecurityToken,
      'secret': secret,
      'tokenType': tokenType
    };
  }
}

/// ❌ Client Errors (400 Bad Request)
class ProductionCSIDErrorData {
  final List<ProductionError> errors;

  ProductionCSIDErrorData({required this.errors});

  factory ProductionCSIDErrorData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDErrorData(
      errors: (json['errors'] as List)
          .map((e) => ProductionError.fromJson(e))
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
class ProductionError {
  final String code;
  final String message;

  ProductionError({required this.code, required this.message});

  factory ProductionError.fromJson(Map<String, dynamic> json) {
    return ProductionError(
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
class ProductionCSIDFailureData {
  final String code;
  final String message;

  ProductionCSIDFailureData({required this.code, required this.message});

  factory ProductionCSIDFailureData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDFailureData(
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

/// Parses a JSON string into a ProductionCSIDResponse object.
ProductionCSIDResponse parseProductionCSIDResponse(int statusCode, String jsonStr) {
  return ProductionCSIDResponse.fromJson(statusCode, jsonDecode(jsonStr));
}

class ProductionCSIDRenewalResponse{
  final int statusCode;
  final CSIDResponseStatus status;
  final ProductionCSIDRenewalSuccessData? successData;
  final ProductionCSIDErrorData? errorData;
  final ProductionCSIDFailureData? failureData;

  ProductionCSIDRenewalResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate response type (Success, Error, or Failure).
  factory ProductionCSIDRenewalResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    CSIDResponseStatus status = _getStatus(statusCode);

    if (status == CSIDResponseStatus.success && json.containsKey('requestID')) {
      return ProductionCSIDRenewalResponse(
        statusCode: statusCode,
        status: status,
        successData: ProductionCSIDRenewalSuccessData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.clientError && json.containsKey('errors')) {
      return ProductionCSIDRenewalResponse(
        statusCode: statusCode,
        status: status,
        errorData: ProductionCSIDErrorData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.serverError && json.containsKey('code') && json.containsKey('message')) {
      return ProductionCSIDRenewalResponse(
        statusCode: statusCode,
        status: status,
        failureData: ProductionCSIDFailureData.fromJson(json),
      );
    } else {
      return ProductionCSIDRenewalResponse(statusCode: statusCode, status: CSIDResponseStatus.unknown);
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
  static CSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CSIDResponseStatus.success;
    if (statusCode == 400) return CSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) return CSIDResponseStatus.serverError;
    return CSIDResponseStatus.unknown;
  }
}
