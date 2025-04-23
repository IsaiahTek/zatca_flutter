import 'message.dart';

/// A model representing the results of a validation process, including different types of messages
/// such as information, warnings, and errors.
///
/// This class provides a structure to handle and parse validation-related messages. The messages are
/// categorized into three types: info, warning, and error messages. Each category is represented as a
/// list of [MessageModel] instances. The class supports JSON serialization and deserialization.
///
/// Example:
/// ```dart
/// ValidationResults results = ValidationResults.fromJson(jsonData);
/// ```
class ValidationResults {
  /// A list of information messages that provide details about the validation process.
  final List<MessageModel>? infoMessages;

  /// A list of warning messages that indicate potential issues with the validation.
  final List<MessageModel>? warningMessages;

  /// A list of error messages that highlight issues that prevent successful validation.
  final List<MessageModel>? errorMessages;

  /// Constructs a [ValidationResults] instance with optional lists of messages.
  ///
  /// [infoMessages], [warningMessages], and [errorMessages] are optional and can be `null`.
  ValidationResults(
      {this.infoMessages, this.warningMessages, this.errorMessages});

  /// Creates a [ValidationResults] instance from a JSON map.
  ///
  /// This factory constructor parses the provided [json] and converts it into a [ValidationResults]
  /// instance, extracting the info, warning, and error messages.
  ///
  /// Example:
  /// ```dart
  /// ValidationResults results = ValidationResults.fromJson(jsonData);
  /// ```
  factory ValidationResults.fromJson(Map<String, dynamic> json) {
    return ValidationResults(
      infoMessages: _parseMessages(json['infoMessages']),
      warningMessages: _parseMessages(json['warningMessages']),
      errorMessages: _parseMessages(json['errorMessages']),
    );
  }

  /// Converts the [ValidationResults] instance back into a JSON map.
  ///
  /// This method serializes the [ValidationResults] into a format suitable for transmission over
  /// a network or storage in a database. It serializes the message lists into JSON arrays.
  ///
  /// Example:
  /// ```dart
  /// Map<String, dynamic> jsonData = results.toJson();
  /// ```
  Map<String, dynamic> toJson() => {
        'infoMessages': infoMessages?.map((m) => m.toJson()).toList(),
        'warningMessages': warningMessages?.map((m) => m.toJson()).toList(),
        'errorMessages': errorMessages?.map((m) => m.toJson()).toList(),
      };

  /// Parses a dynamic data object into a list of [MessageModel] instances.
  ///
  /// This helper method checks if the [data] is a list or a single item and converts it into a
  /// list of [MessageModel] objects. If the data is `null`, it returns `null`. If it's a list, it
  /// creates a list of [MessageModel] objects from each item. If it's a single item, it wraps it in
  /// a list of a single [MessageModel].
  ///
  /// Example:
  /// ```dart
  /// List<MessageModel>? messages = _parseMessages(json['messages']);
  /// ```
  static List<MessageModel>? _parseMessages(dynamic data) {
    // If data is null, return null.
    if (data == null) return null;

    // If data is a List, map each item to a MessageModel and return the resulting list.
    if (data is List) {
      return data.map((e) => MessageModel.fromJson(e)).toList();
    } else {
      // If data is not a List, assume it's a single message, wrap it in a list, and return it.
      return [MessageModel.fromJson(data)];
    }
  }
}
