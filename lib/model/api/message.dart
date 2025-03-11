class MessageModel {
  final String type;
  final String code;
  final String category;
  final String message;
  final String status;

  MessageModel({
    required this.type,
    required this.code,
    required this.category,
    required this.message,
    required this.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      type: json['type'],
      code: json['code'],
      category: json['category'],
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'category': category,
        'message': message,
        'status': status,
      };
}
