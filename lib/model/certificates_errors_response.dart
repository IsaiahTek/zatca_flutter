import 'error_model.dart';

/// A model representing a response that contains a list of certificate-related errors.
///
/// This class is typically used to encapsulate error details returned
/// when certificate operations fail or encounter issues.
class CertificatesErrorsResponse {
  /// A list of errors related to certificate processing.
  ///
  /// Each item in the list is an [ErrorModel] that provides
  /// detailed information about a specific issue.
  final List<ErrorModel> errors;

  /// Creates a new instance of [CertificatesErrorsResponse].
  ///
  /// - [errors]: A list of [ErrorModel] instances representing the encountered errors.
  const CertificatesErrorsResponse({required this.errors});
}
