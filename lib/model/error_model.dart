/// A model representing the structure of an error returned by API endpoints.
///
/// This object includes details about the source of the error and a
/// descriptive message, making it useful for debugging and user feedback.
class ErrorModel {
  /// The origin or category of the error (e.g., validation, server, etc.).
  final String source;

  /// A human-readable description of the error.
  final String message;

  /// Creates a new instance of [ErrorModel].
  ///
  /// - [source]: Identifies where the error originated.
  /// - [message]: Provides details about the error.
  const ErrorModel({
    required this.source,
    required this.message,
  });

  /// Returns a string representation of the error for logging or debugging.
  @override
  String toString() {
    return "Error (SOURCE: $source, TEXT: $message)";
  }
}
