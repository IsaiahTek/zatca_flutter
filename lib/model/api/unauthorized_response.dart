/// A model representing an unauthorized error response (HTTP 401).
///
/// This typically occurs when authentication credentials are missing or invalid.
class UnauthorizedResponse {
  /// The timestamp when the error occurred, represented as a Unix epoch (milliseconds).
  final int timestamp;

  /// The HTTP status code returned by the server (should be 401 for unauthorized access).
  final int statusCode;

  /// A short string describing the error (e.g., "Unauthorized").
  final String error;

  /// A human-readable message providing more detail about the error.
  final String message;

  /// Constructs an [UnauthorizedResponse] instance with all required fields.
  UnauthorizedResponse({
    required this.timestamp,
    required this.statusCode,
    required this.error,
    required this.message,
  });

  /// Factory method to parse a JSON map and [statusCode] into an [UnauthorizedResponse] object.
  ///
  /// Returns `null` if the [statusCode] is not 401, indicating it's not an unauthorized response.
  ///
  /// Example:
  /// ```dart
  /// final response = UnauthorizedResponse.fromJson(jsonMap, 401);
  /// ```
  static UnauthorizedResponse? fromJson(
      Map<String, dynamic> json, int statusCode) {
    return statusCode == 401
        ? UnauthorizedResponse(
            timestamp: json['timestamp'],
            statusCode: json['status'],
            error: json['error'],
            message: json['message'],
          )
        : null;
  }

  /// Converts this instance into a JSON-compatible map.
  ///
  /// Useful for serializing the object for logging, debugging, or API response transformation.
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'status': statusCode,
        'error': error,
        'message': message,
      };
}
