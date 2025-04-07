import 'package:zatca_flutter/model/api/message.dart';

List<MessageModel>? parseMessages(dynamic data) {
  if (data == null) return null;
  if (data is List) {
    return data.map((e) => MessageModel.fromJson(e)).toList();
  } else {
    return [MessageModel.fromJson(data)];
  }
}
