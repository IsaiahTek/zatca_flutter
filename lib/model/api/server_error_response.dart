class ServerErrorResponse {
  final String code;
  final String message;
  final int statusCode;

  ServerErrorResponse({required this.code, required this.message, required this.statusCode});

  static ServerErrorResponse? fromJson(Map<String, dynamic> json, int statusCode) {
    return statusCode == 500 ? ServerErrorResponse(
      code: json['code'],
      message: json['message'],
      statusCode: statusCode,
    ):null;
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'statusCode': statusCode,
      };
}