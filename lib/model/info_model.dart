/// An object representing the result of the clearance or reporting API endpoints when the clearance flag is turned on or off. Basically, it shows an informational message instructing the client to see the other api.
class InfoModel {
  final String message;
  final String source;

  const InfoModel({required this.message, required this.source});

  @override
  String toString() {
    return "Info (SOURCE: $source; TEXT: $message)";
  }
}
