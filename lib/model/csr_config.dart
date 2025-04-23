/// A configuration model representing data used in a Certificate Signing Request (CSR).
///
/// This class holds optional information such as organizational details,
/// location, and industry category that are commonly required when
/// generating a CSR for digital certificates.
class CsrConfig {
  /// The Common Name (CN) — typically the domain name or entity name.
  String? commonName;

  /// A unique identifier like a serial or registration number.
  String? serialNumber;

  /// The organization's legal or tax identifier.
  String? organizationIdentifier;

  /// The name of the specific department or unit within the organization.
  String? organizationUnitName;

  /// The legal name of the organization.
  String? organizationName;

  /// The country code (ISO 3166-1 alpha-2) representing the organization's location.
  String? countryName;

  /// The type of invoice (e.g., standard, simplified) associated with the CSR.
  String? invoiceType;

  /// The physical address of the organization or location related to the CSR.
  String? locationAddress;

  /// The industry or business category of the organization.
  String? industryBusinessCategory;

  /// Constructs a [CsrConfig] object with optional named parameters.
  CsrConfig({
    this.commonName,
    this.serialNumber,
    this.organizationIdentifier,
    this.organizationUnitName,
    this.organizationName,
    this.countryName,
    this.invoiceType,
    this.locationAddress,
    this.industryBusinessCategory,
  });

  /// Converts the [CsrConfig] instance into a JSON-compatible [Map].
  ///
  /// The keys follow a specific CSR naming format.
  Map<String, dynamic> toJson() {
    return {
      "csr.common.name": commonName,
      "csr.serial.number": serialNumber,
      "csr.organization.identifier": organizationIdentifier,
      "csr.organization.unit.name": organizationUnitName,
      "csr.organization.name": organizationName,
      "csr.country.name": countryName,
      "csr.invoice.type": invoiceType,
      "csr.location.address": locationAddress,
      "csr.industry.business.category": industryBusinessCategory,
    };
  }

  /// Creates a [CsrConfig] instance from a JSON-compatible [Map].
  ///
  /// The map keys are expected to follow the CSR naming convention.
  CsrConfig.fromMap(Map<String, dynamic> csrRaw) {
    commonName = csrRaw["csr.common.name"];
    serialNumber = csrRaw["csr.serial.number"];
    organizationIdentifier = csrRaw["csr.organization.identifier"];
    organizationUnitName = csrRaw["csr.organization.unit.name"];
    organizationName = csrRaw["csr.organization.name"];
    countryName = csrRaw["csr.country.name"];
    invoiceType = csrRaw["csr.invoice.type"];
    locationAddress = csrRaw["csr.location.address"];
    industryBusinessCategory = csrRaw["csr.industry.business.category"];
  }
}
