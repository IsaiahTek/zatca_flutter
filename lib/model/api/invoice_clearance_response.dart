import 'message.dart';
import 'server_error_response.dart';
import 'unauthorized_response.dart';
import 'util.dart';

/// Enum describing the clearance status of an invoice from ZATCA.
enum InvoiceClearanceResponseStatus {
  /// Invoice has been cleared successfully.
  cleared,

  /// Invoice was not cleared.
  notCleared,

  /// Request was unauthorized.
  unauthorized,

  /// Request was invalid.
  invalidRequest,

  /// Unknown or undefined status.
  unknown
}

/// Represents the actual data returned when an invoice is successfully cleared.
class ClearanceData {
  /// The base64 encoded cleared invoice string.
  final String clearedInvoice;

  /// The status of the clearance operation (e.g., "Cleared").
  final String clearanceStatus;

  /// Constructs a [ClearanceData] object.
  ClearanceData({
    required this.clearanceStatus,
    required this.clearedInvoice,
  });

  /// Parses a [ClearanceData] object from a JSON map.
  static ClearanceData fromJson(Map<String, dynamic> json) {
    return ClearanceData(
      clearanceStatus: json['clearanceStatus'],
      clearedInvoice: json['clearedInvoice'],
    );
  }

  /// Converts the object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'clearanceStatus': clearanceStatus,
      'clearedInvoice': clearedInvoice,
    };
  }
}

/// Response model for invoice clearance requests.
class InvoiceClearanceResponse {
  /// A list of messages that include validation results (errors, warnings, info).
  final ValidationResults? validationResults;

  /// The invoice clearance payload (cleared invoice and status).
  final ClearanceData? clearanceData;

  /// The high-level clearance status returned by ZATCA.
  final String? clearanceStatus;

  /// Base64 hash of the invoice.
  final String? invoiceHash;

  /// Base64 encoded cleared invoice.
  final String? clearedInvoice;

  /// Details of any server-side error returned by ZATCA.
  final ServerErrorResponse? serverErrorResponse;

  /// Information about an unauthorized response.
  final UnauthorizedResponse? unauthorizedResponse;

  /// Parsed enum representing the clearance response status.
  final InvoiceClearanceResponseStatus status;

  /// HTTP status code returned by the server.
  final int statusCode;

  /// Constructs an [InvoiceClearanceResponse] instance.
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

  /// Parses a [InvoiceClearanceResponse] object from a JSON map and status code.
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

  /// Converts the object into a JSON map.
  Map<String, dynamic> toJson() => {
        'validationResults': validationResults?.toJson(),
        'clearanceData': clearanceData?.toJson(),
        'clearanceStatus': clearanceStatus,
        'status': status.name,
        'statusCode': statusCode,
      };

  /// Parses the string status into an enum [InvoiceClearanceResponseStatus].
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

/// Holds categorized validation messages received after invoice clearance.
class ValidationResults {
  /// Informational messages, such as tips or suggestions.
  final List<MessageModel>? infoMessages;

  /// Warning messages, typically indicating non-critical issues.
  final List<MessageModel>? warningMessages;

  /// Error messages indicating validation failure.
  final List<MessageModel>? errorMessages;

  /// Overall validation status summary (e.g., "Valid", "Invalid").
  final String? status;

  /// Constructs a [ValidationResults] instance.
  ValidationResults({
    this.infoMessages,
    this.warningMessages,
    this.errorMessages,
    this.status,
  });

  /// Parses a [ValidationResults] object from JSON.
  factory ValidationResults.fromJson(Map<String, dynamic> json) {
    return ValidationResults(
      infoMessages: parseMessages(json['infoMessages']),
      warningMessages: parseMessages(json['warningMessages']),
      errorMessages: parseMessages(json['errorMessages']),
      status: json['status'],
    );
  }

  /// Converts the object into a JSON map.
  Map<String, dynamic> toJson() => {
        'infoMessages': infoMessages?.map((m) => m.toJson()).toList(),
        'warningMessages': warningMessages?.map((m) => m.toJson()).toList(),
        'errorMessages': errorMessages?.map((m) => m.toJson()).toList(),
        'status': status,
      };
}
