/// A model that holds a digital certificate and its corresponding private key.
///
/// This class is commonly used for cryptographic operations such as
/// signing, encryption, or SSL/TLS authentication.
class CertAndKey {
  /// The digital certificate in PEM or base64-encoded format.
  final String cert;

  /// The private key associated with the certificate, also in PEM or base64-encoded format.
  final String key;

  /// Creates a new instance of [CertAndKey].
  ///
  /// - [cert]: The digital certificate.
  /// - [key]: The private key paired with the certificate.
  const CertAndKey({required this.cert, required this.key});
}
