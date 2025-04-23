/// A model representing a server error response, typically for HTTP 500 errors.
class ServerErrorResponse {
  /// The error code returned by the server.
  final String code;

  /// A human-readable message describing the error.
  final String message;

  /// The HTTP status code associated with the response.
  final int statusCode;

  /// Creates a [ServerErrorResponse] instance.
  ///
  /// All fields are required to construct the object.
  ServerErrorResponse({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  /// Factory constructor to parse a JSON map and status code into a [ServerErrorResponse] object.
  ///
  /// Returns `null` if the [statusCode] is not `500`, indicating this is not a server error.
  ///
  /// Example:
  /// ```dart
  /// final response = ServerErrorResponse.fromJson(jsonMap, 500);
  /// ```
  static ServerErrorResponse? fromJson(
      Map<String, dynamic> json, int statusCode) {
    return statusCode == 500
        ? ServerErrorResponse(
            code: json['code'],
            message: json['message'],
            statusCode: statusCode,
          )
        : null;
  }

  /// Converts the [ServerErrorResponse] instance into a JSON map.
  ///
  /// Useful for serializing the object back to JSON format.
  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'statusCode': statusCode,
      };
}
