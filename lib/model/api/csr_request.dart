/// Compliance CSID Request parameters model
class CCSIDRequestProp {
  /// The CSR String value should be a base64 encoded value and not a PEM value.
  final String csr;

  /// The One-Time-Password from your Zatca/Fatoora Account if production, otherwise, use test values such as `123456`
  final String otp;

  /// Constructor
  const CCSIDRequestProp({required this.csr, required this.otp});
}

/// Production CSID Renewal Request parameters model
class PCSIDRenewalRequestProp extends CCSIDRequestProp {
  /// Constructor
  PCSIDRenewalRequestProp({required super.csr, required super.otp});
}
