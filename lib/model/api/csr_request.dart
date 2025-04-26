/// Compliance CSID Request parameters model.
///
/// This class encapsulates the properties required when requesting a
/// Compliance CSID (Cryptographic Stamp Identifier) from ZATCA.
/// It includes essential information like the CSR and the OTP.
class CCSIDRequestProp {
  /// The Certificate Signing Request (CSR) to be sent to ZATCA.
  ///
  /// **Note:** This must be a base64 encoded string, not in PEM format.
  /// You can generate this using OpenSSL or any compatible crypto tool.
  final String csr;

  /// The One-Time Password provided by ZATCA for verification.
  ///
  /// - For **Production**, this is the OTP you receive from your ZATCA/Fatoora dashboard.
  /// - For **Test/Developer** mode, you may use test values like `'123456'`.
  final String otp;

  /// Constructs a [CCSIDRequestProp] with the required CSR and OTP.
  const CCSIDRequestProp({
    required this.csr,
    required this.otp,
  });
}

/// Production CSID Renewal Request parameters model.
///
/// This subclass of [CCSIDRequestProp] is specifically used when renewing
/// a Production CSID. It retains the same structure but semantically indicates
/// its use for renewal operations.
class PCSIDRenewalRequestProp extends CCSIDRequestProp {
  /// Constructs a [PCSIDRenewalRequestProp] with the given CSR and OTP.
  ///
  /// Inherits behavior from [CCSIDRequestProp] but indicates a different intent (renewal).
  PCSIDRenewalRequestProp({
    required super.csr,
    required super.otp,
  });
}
