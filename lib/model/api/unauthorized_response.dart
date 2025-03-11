class UnauthorizedResponse {
  final int timestamp;
  final int statusCode;
  final String error;
  final String message;

  UnauthorizedResponse({
    required this.timestamp,
    required this.statusCode,
    required this.error,
    required this.message,
  });

  static UnauthorizedResponse? fromJson(
      Map<String, dynamic> json, int statusCode) {
    return statusCode == 401
        ? UnauthorizedResponse(
            timestamp: json['timestamp'],
            statusCode: json['status'],
            error: json['error'],
            message: json['message'],
          )
        : null;
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'status': statusCode,
        'error': error,
        'message': message,
      };
}
