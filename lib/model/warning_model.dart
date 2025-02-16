/// An object representing the structure of the error object returned by the API endpoints. Specifically, it includes the Category of the error, its code and message.
class WarningModel {
  final String source;
  final String message;

  const WarningModel({
    required this.source,
    required this.message
  });

  @override
  String toString() {
    return "Warning (SOURCE: $source; TEXT: $message)";
  }
}