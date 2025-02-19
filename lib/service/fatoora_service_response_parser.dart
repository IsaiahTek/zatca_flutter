
import '../enums.dart';
import '../model/error_model.dart';
import '../model/fatoora_service_response.dart';
import '../model/info_model.dart';
import '../model/warning_model.dart';

class FatooraServiceResponseParser {
  /// Extracts all error, warning, and info messages from Fatoora CLI output
  static FatooraServiceResponse extractResponses(String output) {
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
      r'\[\s*WARNING\s*\]\s*(.*?)\s*-\s*(.+)',
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

    // Determine response status
    ResponseStatus status = errors.isEmpty
        ? ResponseStatus.success
        : ResponseStatus.failure;

    return FatooraServiceResponse(
      status: status,
      errors: errors.isEmpty ? null : errors,
      warnings: warnings.isEmpty ? null : warnings,
      infos: infos.isEmpty ? null : infos,
    );
  }
}
