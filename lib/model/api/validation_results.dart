import 'message.dart';

class ValidationResults {
  final List<MessageModel>? infoMessages;
  final List<MessageModel>? warningMessages;
  final List<MessageModel>? errorMessages;

  ValidationResults({this.infoMessages, this.warningMessages, this.errorMessages});

  factory ValidationResults.fromJson(Map<String, dynamic> json) {
    return ValidationResults(
      infoMessages: _parseMessages(json['infoMessages']),
      warningMessages: _parseMessages(json['warningMessages']),
      errorMessages: _parseMessages(json['errorMessages']),
    );
  }

  Map<String, dynamic> toJson() => {
    'infoMessages': infoMessages?.map((m) => m.toJson()).toList(),
    'warningMessages': warningMessages?.map((m) => m.toJson()).toList(),
    'errorMessages': errorMessages?.map((m) => m.toJson()).toList(),
  };

  static List<MessageModel>? _parseMessages(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => MessageModel.fromJson(e)).toList();
    } else {
      return [MessageModel.fromJson(data)];
    }
  }
}