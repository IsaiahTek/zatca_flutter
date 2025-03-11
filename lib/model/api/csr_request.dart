class CCSIDRequestProp {
  final String csr;
  final String otp;

  const CCSIDRequestProp({required this.csr, required this.otp});
}

class PCSIDRenewalRequestProp extends CCSIDRequestProp {
  PCSIDRenewalRequestProp({required super.csr, required super.otp});
}
