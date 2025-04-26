import 'dart:convert';
import 'package:zatca_flutter/enums.dart';

/// Represents the main API response from the Production CSID endpoint.
class ProductionCSIDResponse {
  /// HTTP status code of the response.
  final int statusCode;

  /// Categorized response status derived from the HTTP status code.
  final CSIDResponseStatus status;

  /// Success data when the request is successful (status code 200).
  final ProductionCSIDSuccessData? successData;

  /// Error data when there's a client-side error (status code 400).
  final ProductionCSIDErrorData? errorData;

  /// Failure data when there's a server-side error (status code 406/500).
  final ProductionCSIDFailureData? failureData;

  ProductionCSIDResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate model based on status code and JSON structure.
  factory ProductionCSIDResponse.fromJson(
      int statusCode, Map<String, dynamic> json) {
    CSIDResponseStatus status = _getStatus(statusCode);

    if (status == CSIDResponseStatus.success && json.containsKey('requestID')) {
      return ProductionCSIDResponse(
        statusCode: statusCode,
        status: status,
        successData: ProductionCSIDSuccessData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.clientError &&
        json.containsKey('errors')) {
      return ProductionCSIDResponse(
        statusCode: statusCode,
        status: status,
        errorData: ProductionCSIDErrorData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.serverError &&
        json.containsKey('code') &&
        json.containsKey('message')) {
      return ProductionCSIDResponse(
        statusCode: statusCode,
        status: status,
        failureData: ProductionCSIDFailureData.fromJson(json),
      );
    } else {
      return ProductionCSIDResponse(
          statusCode: statusCode, status: CSIDResponseStatus.unknown);
    }
  }

  /// Serializes the model to JSON.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'statusCode': statusCode,
      'status': status.toString().split('.').last
    };
    if (successData != null) json.addAll(successData!.toJson());
    if (errorData != null) json.addAll(errorData!.toJson());
    if (failureData != null) json.addAll(failureData!.toJson());
    return json;
  }

  /// Returns response status category based on HTTP status code.
  static CSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CSIDResponseStatus.success;
    if (statusCode == 400) return CSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) {
      return CSIDResponseStatus.serverError;
    }
    return CSIDResponseStatus.unknown;
  }
}

/// Represents the success response data for a Production CSID request.
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

  /// Constructs the model from JSON.
  factory ProductionCSIDSuccessData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDSuccessData(
      requestID: json['requestID'],
      dispositionMessage: json['dispositionMessage'],
      binarySecurityToken: json['binarySecurityToken'],
      secret: json['secret'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'dispositionMessage': dispositionMessage,
      'binarySecurityToken': binarySecurityToken,
      'secret': secret,
    };
  }
}

/// Represents success data for a CSID renewal request.
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
    required this.tokenType,
  });

  /// Constructs the model from JSON.
  factory ProductionCSIDRenewalSuccessData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDRenewalSuccessData(
      requestID: json['requestID'],
      dispositionMessage: json['dispositionMessage'],
      binarySecurityToken: json['binarySecurityToken'],
      secret: json['secret'],
      tokenType: json['tokenType'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'dispositionMessage': dispositionMessage,
      'binarySecurityToken': binarySecurityToken,
      'secret': secret,
      'tokenType': tokenType,
    };
  }
}

/// Represents the data returned in case of client-side errors.
class ProductionCSIDErrorData {
  final List<ProductionError> errors;

  ProductionCSIDErrorData({required this.errors});

  /// Constructs the model from JSON.
  factory ProductionCSIDErrorData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDErrorData(
      errors: (json['errors'] as List)
          .map((e) => ProductionError.fromJson(e))
          .toList(),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map((e) => e.toJson()).toList(),
    };
  }
}

/// Represents a single error object within a client error response.
class ProductionError {
  final String code;
  final String message;

  ProductionError({required this.code, required this.message});

  /// Constructs the model from JSON.
  factory ProductionError.fromJson(Map<String, dynamic> json) {
    return ProductionError(
      code: json['code'],
      message: json['message'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

/// Represents data returned for server-side failures (e.g. HTTP 500).
class ProductionCSIDFailureData {
  final String code;
  final String message;

  ProductionCSIDFailureData({required this.code, required this.message});

  /// Constructs the model from JSON.
  factory ProductionCSIDFailureData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDFailureData(
      code: json['code'],
      message: json['message'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

/// Utility function to parse a raw JSON string into a [ProductionCSIDResponse].
ProductionCSIDResponse parseProductionCSIDResponse(
    int statusCode, String jsonStr) {
  return ProductionCSIDResponse.fromJson(statusCode, jsonDecode(jsonStr));
}

/// Represents the main API response from the Production CSID Renewal endpoint.
class ProductionCSIDRenewalResponse {
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

  /// Parses JSON into the appropriate model based on status code and structure.
  factory ProductionCSIDRenewalResponse.fromJson(
      int statusCode, Map<String, dynamic> json) {
    CSIDResponseStatus status = _getStatus(statusCode);

    if (status == CSIDResponseStatus.success && json.containsKey('requestID')) {
      return ProductionCSIDRenewalResponse(
        statusCode: statusCode,
        status: status,
        successData: ProductionCSIDRenewalSuccessData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.clientError &&
        json.containsKey('errors')) {
      return ProductionCSIDRenewalResponse(
        statusCode: statusCode,
        status: status,
        errorData: ProductionCSIDErrorData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.serverError &&
        json.containsKey('code') &&
        json.containsKey('message')) {
      return ProductionCSIDRenewalResponse(
        statusCode: statusCode,
        status: status,
        failureData: ProductionCSIDFailureData.fromJson(json),
      );
    } else {
      return ProductionCSIDRenewalResponse(
          statusCode: statusCode, status: CSIDResponseStatus.unknown);
    }
  }

  /// Serializes the model to JSON.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'statusCode': statusCode,
      'status': status.toString().split('.').last
    };
    if (successData != null) json.addAll(successData!.toJson());
    if (errorData != null) json.addAll(errorData!.toJson());
    if (failureData != null) json.addAll(failureData!.toJson());
    return json;
  }

  /// Returns the response status category based on HTTP status code.
  static CSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CSIDResponseStatus.success;
    if (statusCode == 400) return CSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) {
      return CSIDResponseStatus.serverError;
    }
    return CSIDResponseStatus.unknown;
  }
}
