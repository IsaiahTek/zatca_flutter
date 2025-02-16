/// An object representing the structure of the error object returned by the API endpoints. Specifically, it includes the Category of the error, its code and message.
class ErrorModel {
  final String source;
  final String message;

  const ErrorModel({
    required this.source,
    required this.message,
  });

  @override
  String toString() {
    return "Error (SOURCE: $source, TEXT: $message)";
  }
}