import 'dart:convert';
import 'package:zatca_flutter/enums.dart';

/// Represents the main API response from the Production CSID endpoint.
class ProductionCSIDResponse {
  /// HTTP status code of the response.
  final int statusCode;

  /// Categorized response status derived from the HTTP status code.
  final CSIDResponseStatus status;

  /// Success data when the request is successful (HTTP 200).
  final ProductionCSIDSuccessData? successData;

  /// Error data when there's a client-side error (HTTP 400).
  final ProductionCSIDErrorData? errorData;

  /// Failure data when there's a server-side error (HTTP 406/500).
  final ProductionCSIDFailureData? failureData;

  /// Creates a [ProductionCSIDResponse] instance.
  ProductionCSIDResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate model based on status code and JSON structure.
  ///
  /// - [statusCode]: HTTP response code.
  /// - [json]: JSON body of the response.
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
        statusCode: statusCode,
        status: CSIDResponseStatus.unknown,
      );
    }
  }

  /// Serializes the model back to JSON.
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

  /// Returns the categorized response status based on [statusCode].
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
  /// Unique identifier for the request.
  final int requestID;

  /// Message describing the disposition of the request.
  final String dispositionMessage;

  /// The issued binary security token.
  final String binarySecurityToken;

  /// The secret associated with the security token.
  final String secret;

  /// Creates a [ProductionCSIDSuccessData] instance.
  ProductionCSIDSuccessData({
    required this.requestID,
    required this.dispositionMessage,
    required this.binarySecurityToken,
    required this.secret,
  });

  /// Constructs the model from a JSON map.
  factory ProductionCSIDSuccessData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDSuccessData(
      requestID: json['requestID'],
      dispositionMessage: json['dispositionMessage'],
      binarySecurityToken: json['binarySecurityToken'],
      secret: json['secret'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
        'requestID': requestID,
        'dispositionMessage': dispositionMessage,
        'binarySecurityToken': binarySecurityToken,
        'secret': secret,
      };
}

/// Represents the success data for a Production CSID renewal request.
class ProductionCSIDRenewalSuccessData {
  /// Unique identifier for the renewal request.
  final int requestID;

  /// Message describing the outcome of the renewal.
  final String dispositionMessage;

  /// The renewed binary security token.
  final String binarySecurityToken;

  /// The secret associated with the renewed token.
  final String secret;

  /// Type of the security token.
  final String tokenType;

  /// Creates a [ProductionCSIDRenewalSuccessData] instance.
  ProductionCSIDRenewalSuccessData({
    required this.requestID,
    required this.dispositionMessage,
    required this.binarySecurityToken,
    required this.secret,
    required this.tokenType,
  });

  /// Constructs the model from a JSON map.
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
  Map<String, dynamic> toJson() => {
        'requestID': requestID,
        'dispositionMessage': dispositionMessage,
        'binarySecurityToken': binarySecurityToken,
        'secret': secret,
        'tokenType': tokenType,
      };
}

/// Represents the data returned in case of client-side errors (HTTP 400).
class ProductionCSIDErrorData {
  /// List of error objects.
  final List<ProductionError> errors;

  /// Creates a [ProductionCSIDErrorData] instance.
  ProductionCSIDErrorData({required this.errors});

  /// Constructs the model from a JSON map.
  factory ProductionCSIDErrorData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDErrorData(
      errors: (json['errors'] as List)
          .map((e) => ProductionError.fromJson(e))
          .toList(),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
        'errors': errors.map((e) => e.toJson()).toList(),
      };
}

/// Represents a single error within a client error response.
class ProductionError {
  /// Error code.
  final String code;

  /// Human-readable error message.
  final String message;

  /// Creates a [ProductionError] instance.
  ProductionError({required this.code, required this.message});

  /// Constructs the model from a JSON map.
  factory ProductionError.fromJson(Map<String, dynamic> json) {
    return ProductionError(
      code: json['code'],
      message: json['message'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };
}

/// Represents server-side failure data (e.g., HTTP 500 errors).
class ProductionCSIDFailureData {
  /// Error code.
  final String code;

  /// Error message.
  final String message;

  /// Creates a [ProductionCSIDFailureData] instance.
  ProductionCSIDFailureData({required this.code, required this.message});

  /// Constructs the model from a JSON map.
  factory ProductionCSIDFailureData.fromJson(Map<String, dynamic> json) {
    return ProductionCSIDFailureData(
      code: json['code'],
      message: json['message'],
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };
}

/// Utility function to parse a raw JSON string into a [ProductionCSIDResponse].
///
/// - [statusCode]: HTTP status code.
/// - [jsonStr]: JSON response string.
ProductionCSIDResponse parseProductionCSIDResponse(
    int statusCode, String jsonStr) {
  return ProductionCSIDResponse.fromJson(statusCode, jsonDecode(jsonStr));
}

/// Represents the main API response from the Production CSID Renewal endpoint.
class ProductionCSIDRenewalResponse {
  /// HTTP status code of the response.
  final int statusCode;

  /// Categorized response status derived from the HTTP status code.
  final CSIDResponseStatus status;

  /// Success data when the renewal request is successful.
  final ProductionCSIDRenewalSuccessData? successData;

  /// Error data when there's a client-side error during renewal.
  final ProductionCSIDErrorData? errorData;

  /// Failure data when there's a server-side error during renewal.
  final ProductionCSIDFailureData? failureData;

  /// Creates a [ProductionCSIDRenewalResponse] instance.
  ProductionCSIDRenewalResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate model based on status code and JSON structure.
  ///
  /// - [statusCode]: HTTP response code.
  /// - [json]: JSON body of the renewal response.
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
        statusCode: statusCode,
        status: CSIDResponseStatus.unknown,
      );
    }
  }

  /// Serializes the model back to JSON.
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

  /// Returns the categorized response status based on [statusCode].
  static CSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CSIDResponseStatus.success;
    if (statusCode == 400) return CSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) {
      return CSIDResponseStatus.serverError;
    }
    return CSIDResponseStatus.unknown;
  }
}
