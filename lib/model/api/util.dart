import 'package:zatca_flutter/model/api/message.dart';

/// Parses a dynamic [data] object into a list of [MessageModel] instances.
///
/// The function checks if [data] is a list or a single message and converts it into a list of [MessageModel] objects accordingly.
///
/// If [data] is `null`, the function returns `null`. If [data] is a list, it returns a list of [MessageModel] instances created from the list elements. If [data] is a single item, it wraps it in a list of a single [MessageModel].
///
/// Example:
/// ```dart
/// List<MessageModel>? messages = parseMessages(responseData);
/// ```
List<MessageModel>? parseMessages(dynamic data) {
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
