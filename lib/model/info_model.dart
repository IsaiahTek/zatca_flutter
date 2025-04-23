/// A model representing an informational message returned by the API.
///
/// This class is used to communicate details related to the API's status,
/// typically when a user is instructed to consult other APIs for further
/// action or clarification.
class InfoModel {
  /// The informational message describing the result or instruction.
  final String message;

  /// The source or category from which this information originates.
  final String source;

  /// Creates a new instance of [InfoModel].
  ///
  /// - [message]: The informational message to be displayed or logged.
  /// - [source]: The origin or source of the information (e.g., API endpoint, service).
  const InfoModel({
    required this.message,
    required this.source,
  });

  /// Returns a string representation of the info message for logging or debugging.
  @override
  String toString() {
    return "Info (SOURCE: $source; TEXT: $message)";
  }
}
