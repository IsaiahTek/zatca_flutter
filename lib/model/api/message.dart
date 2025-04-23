/// Represents a single message returned as part of validation or processing results.
/// This could be an info, warning, or error message depending on the [type] field.
class MessageModel {
  /// The type of the message (e.g., "INFO", "WARNING", "ERROR").
  final String type;

  /// The unique code identifying this message type or error.
  final String code;

  /// A classification or grouping of the message (e.g., "Validation", "BusinessRule").
  final String category;

  /// The human-readable message content.
  final String message;

  /// The status of the message or process this message relates to.
  final String status;

  /// Constructs a [MessageModel] with the given values.
  MessageModel({
    required this.type,
    required this.code,
    required this.category,
    required this.message,
    required this.status,
  });

  /// Factory method to create a [MessageModel] instance from a JSON map.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      type: json['type'],
      code: json['code'],
      category: json['category'],
      message: json['message'],
      status: json['status'],
    );
  }

  /// Converts this [MessageModel] to a JSON map.
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'category': category,
        'message': message,
        'status': status,
      };
}
