/// Model class for a Production CSID (PCSID) request payload.
/// This is used when making requests to retrieve the Production Compliance Signing ID certificate.
class PCSIDRequestProp {
  /// A unique request identifier used to trace and identify the request.
  final String requestId;

  /// A temporary binary security token issued by ZATCA, used for authentication.
  final String binarySecurityToken;

  /// A secret key associated with the request, usually provided during CSID registration.
  final String secret;

  /// Constructs a [PCSIDRequestProp] instance with the required parameters.
  PCSIDRequestProp({
    required this.binarySecurityToken,
    required this.requestId,
    required this.secret,
  });
}
