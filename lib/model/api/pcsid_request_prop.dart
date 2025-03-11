class PCSIDRequestProp {
  String requestId;
  String binarySecurityToken;
  String secret;

  PCSIDRequestProp(
      {required this.binarySecurityToken,
      required this.requestId,
      required this.secret});
}
