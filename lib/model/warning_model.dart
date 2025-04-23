/// An object representing the structure of the warning object returned by the API endpoints.
///
/// This class contains information about a warning encountered during
/// the operation, including the source of the warning and the warning message.
class WarningModel {
  /// The source of the warning, typically representing the part of the system
  /// or process that triggered the warning.
  final String source;

  /// The message detailing the warning.
  ///
  /// This message describes the issue or event that triggered the warning,
  /// typically providing the user with context or suggestions for resolution.
  final String message;

  /// Creates a new instance of [WarningModel].
  ///
  /// - [source]: The source of the warning, such as the system module or process.
  /// - [message]: The message detailing the warning.
  const WarningModel({required this.source, required this.message});

  @override
  String toString() {
    return "Warning (SOURCE: $source; TEXT: $message)";
  }
}
