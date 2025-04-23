import 'dart:convert';
import 'package:zatca_flutter/enums.dart';

/// Main response model for Compliance CSID API
/// 
/// This model represents the response structure from the Compliance CSID API, which could be a success, error, or failure response.
class ComplianceCSIDResponse {
  /// The HTTP status code returned by the server.
  final int statusCode;

  /// The response status indicating whether the request was successful, had client-side errors, server-side errors, or is unknown.
  final CSIDResponseStatus status;

  /// The data related to a successful response (only if status is [CSIDResponseStatus.success]).
  final ComplianceSuccessData? successData;

  /// The data related to client-side errors (only if status is [CSIDResponseStatus.clientError]).
  final ComplianceErrorData? errorData;

  /// The data related to server-side errors (only if status is [CSIDResponseStatus.serverError]).
  final ComplianceFailureData? failureData;

  /// Constructor for initializing the response model.
  /// 
  /// Parameters:
  /// - [statusCode]: The status code from the server (e.g., 200 for success).
  /// - [status]: The response status (success, client error, server error, or unknown).
  /// - [successData]: The data for a successful response (if any).
  /// - [errorData]: The data for client errors (if any).
  /// - [failureData]: The data for server errors (if any).
  ComplianceCSIDResponse({
    required this.statusCode,
    required this.status,
    this.successData,
    this.errorData,
    this.failureData,
  });

  /// Parses JSON into the appropriate response type (Success, Error, or Failure).
  /// 
  /// Based on the status code, the JSON data is parsed into the corresponding response data class (success, error, or failure).
  factory ComplianceCSIDResponse.fromJson(
      int statusCode, Map<String, dynamic> json) {
    CSIDResponseStatus status = _getStatus(statusCode);

    if (status == CSIDResponseStatus.success && json.containsKey('requestID')) {
      return ComplianceCSIDResponse(
        statusCode: statusCode,
        status: status,
        successData: ComplianceSuccessData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.clientError &&
        json.containsKey('errors')) {
      return ComplianceCSIDResponse(
        statusCode: statusCode,
        status: status,
        errorData: ComplianceErrorData.fromJson(json),
      );
    } else if (status == CSIDResponseStatus.serverError &&
        json.containsKey('code') &&
        json.containsKey('message')) {
      return ComplianceCSIDResponse(
        statusCode: statusCode,
        status: status,
        failureData: ComplianceFailureData.fromJson(json),
      );
    } else {
      return ComplianceCSIDResponse(
          statusCode: statusCode, status: CSIDResponseStatus.unknown);
    }
  }

  /// Converts the model back to JSON.
  /// 
  /// This method converts the response model into a JSON structure, including the status and corresponding data.
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

  /// Determines the response status based on the status code.
  /// 
  /// This method maps the status code to an appropriate response status (success, client error, server error, or unknown).
  static CSIDResponseStatus _getStatus(int statusCode) {
    if (statusCode == 200) return CSIDResponseStatus.success;
    if (statusCode == 400) return CSIDResponseStatus.clientError;
    if (statusCode == 406 || statusCode == 500) {
      return CSIDResponseStatus.serverError;
    }
    return CSIDResponseStatus.unknown;
  }
}

/// Success Response (200 OK)
/// 
/// This class represents the success response data for a valid CSID request.
class ComplianceSuccessData {
  /// The unique request ID for the CSID request.
  final int requestID;

  /// A message indicating the disposition of the CSID request.
  final String dispositionMessage;

  /// The binary security token returned for authentication purposes.
  final String binarySecurityToken;

  /// A secret key or value that is associated with the request.
  final String secret;

  /// Constructor for the success data.
  /// 
  /// Parameters:
  /// - [requestID]: The unique request ID.
  /// - [dispositionMessage]: The message regarding the request's disposition.
  /// - [binarySecurityToken]: The token for authentication.
  /// - [secret]: A secret key or value.
  ComplianceSuccessData({
    required this.requestID,
    required this.dispositionMessage,
    required this.binarySecurityToken,
    required this.secret,
  });

  /// Parses JSON data into a ComplianceSuccessData object.
  factory ComplianceSuccessData.fromJson(Map<String, dynamic> json) {
    return ComplianceSuccessData(
      requestID: json['requestID'],
      dispositionMessage: json['dispositionMessage'],
      binarySecurityToken: json['binarySecurityToken'],
      secret: json['secret'],
    );
  }

  /// Converts the success data back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'dispositionMessage': dispositionMessage,
      'binarySecurityToken': binarySecurityToken,
      'secret': secret,
    };
  }
}

/// Client Errors (400 Bad Request)
/// 
/// This class represents the error data returned for a client-side issue in the CSID API.
class ComplianceErrorData {
  /// A list of errors that occurred on the client side.
  final List<ComplianceError> errors;

  /// Constructor for the client error data.
  /// 
  /// Parameters:
  /// - [errors]: A list of specific error details.
  ComplianceErrorData({required this.errors});

  /// Parses JSON data into a ComplianceErrorData object.
  factory ComplianceErrorData.fromJson(Map<String, dynamic> json) {
    return ComplianceErrorData(
      errors: (json['errors'] as List)
          .map((e) => ComplianceError.fromJson(e))
          .toList(),
    );
  }

  /// Converts the error data back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map((e) => e.toJson()).toList(),
    };
  }
}

/// Specific Error Model
/// 
/// This class represents a single error in the list of errors for client-side issues.
class ComplianceError {
  /// The error code associated with the specific issue.
  final String code;

  /// A description of the error.
  final String message;

  /// Constructor for the specific error.
  /// 
  /// Parameters:
  /// - [code]: The error code.
  /// - [message]: A description of the error.
  ComplianceError({required this.code, required this.message});

  /// Parses JSON data into a ComplianceError object.
  factory ComplianceError.fromJson(Map<String, dynamic> json) {
    return ComplianceError(
      code: json['code'],
      message: json['message'],
    );
  }

  /// Converts the error back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

/// Server Errors (406, 500, etc.)
/// 
/// This class represents the failure data returned for server-side issues in the CSID API.
class ComplianceFailureData {
  /// The error code returned from the server in case of failure.
  final String code;

  /// The error message returned from the server in case of failure.
  final String message;

  /// Constructor for the server failure data.
  /// 
  /// Parameters:
  /// - [code]: The error code from the server.
  /// - [message]: The error message from the server.
  ComplianceFailureData({required this.code, required this.message});

  /// Parses JSON data into a ComplianceFailureData object.
  factory ComplianceFailureData.fromJson(Map<String, dynamic> json) {
    return ComplianceFailureData(
      code: json['code'],
      message: json['message'],
    );
  }

  /// Converts the failure data back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

/// Parses a JSON string into a ComplianceCSIDResponse object.
/// 
/// This function is a utility to simplify parsing JSON strings into the `ComplianceCSIDResponse` model.
/// 
/// Parameters:
/// - [statusCode]: The HTTP status code of the response.
/// - [jsonStr]: The raw JSON string containing the response data.
/// 
/// Returns a `ComplianceCSIDResponse` object.
ComplianceCSIDResponse parseComplianceCSIDResponse(
    int statusCode, String jsonStr) {
  return ComplianceCSIDResponse.fromJson(statusCode, jsonDecode(jsonStr));
}
