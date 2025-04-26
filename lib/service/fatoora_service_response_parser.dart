import '../enums.dart';
import '../model/error_model.dart';
import '../model/fatoora_service_response.dart';
import '../model/info_model.dart';
import '../model/warning_model.dart';

/// A utility class for parsing the output from the Fatoora service CLI.
///
/// This class is used internally to extract error, warning, and info messages
/// from the Fatoora CLI output and encapsulate them into a structured response.
class FatooraServiceResponseParser {
  /// Extracts all error, warning, and info messages from the Fatoora CLI output.
  ///
  /// This method processes the raw output from the Fatoora service and extracts the
  /// corresponding error, warning, and info messages, storing them in the appropriate
  /// lists, and returns a [FatooraServiceResponse] object.
  ///
  /// [output] The raw string output from the Fatoora service CLI.
  ///
  /// Returns a [FatooraServiceResponse] containing the extracted data.
  static FatooraServiceResponse extractResponses(String output) =>
      _extractResponses(output);

  /// Internal method to extract error, warning, and info messages from the output.
  ///
  /// This method performs regular expression matching to identify and categorize messages
  /// in the Fatoora service CLI output.
  ///
  /// [output] The raw string output from the Fatoora service CLI.
  ///
  /// Returns a [FatooraServiceResponse] containing the parsed data.
  static FatooraServiceResponse _extractResponses(String output) {
    List<ErrorModel> errors = [];
    List<WarningModel> warnings = [];
    List<InfoModel> infos = [];

    // Extract [ERROR] messages
    final errorRegex = RegExp(
      r'\[\s*ERROR\s*\]\s*(.*?)\s*-\s*(.+)',
      multiLine: true,
    );

    for (final match in errorRegex.allMatches(output)) {
      String source = match.group(1)?.trim() ?? "Unknown";
      String message = match.group(2)?.trim() ?? "Unknown error";

      errors.add(ErrorModel(message: message, source: source));
    }

    // Extract [WARNING] messages
    final warningRegex = RegExp(
      r'\[\s*WARN\s*\]\s*(.*?)\s*-\s*(.+)',
      multiLine: true,
    );

    for (final match in warningRegex.allMatches(output)) {
      String source = match.group(1)?.trim() ?? "Unknown";
      String message = match.group(2)?.trim() ?? "Unknown warning";

      warnings.add(WarningModel(message: message, source: source));
    }

    // Extract [INFO] messages
    final infoRegex = RegExp(
      r'\[\s*INFO\s*\]\s*(.*?)\s*-\s*(.+)',
      multiLine: true,
    );

    for (final match in infoRegex.allMatches(output)) {
      String source = match.group(1)?.trim() ?? "Unknown";
      String message = match.group(2)?.trim() ?? "Unknown info";

      infos.add(InfoModel(message: message, source: source));
    }

    // Determine response status based on the presence of errors
    ResponseStatus status =
        errors.isEmpty ? ResponseStatus.success : ResponseStatus.failure;

    return FatooraServiceResponse(
      status: status,
      errors: errors.isEmpty ? null : errors,
      warnings: warnings.isEmpty ? null : warnings,
      infos: infos.isEmpty ? null : infos,
    );
  }
}
