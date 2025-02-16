class CsrConfig {
  
  String? commonName;
  String? serialNumber;
  String? organizationIdentifier;
  String? organizationUnitName;
  String? organizationName;
  String? countryName;
  String? invoiceType;
  String? locationAddress;
  String? industryBusinessCategory;

  CsrConfig({
    this.commonName,
    this.serialNumber,
    this.organizationIdentifier,
    this.organizationUnitName,
    this.organizationName,
    this.countryName,
    this.invoiceType,
    this.locationAddress,
    this.industryBusinessCategory
  });

  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = {
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
    return data;
  }

  CsrConfig.fromMap(Map<String, dynamic> csrRaw){
      commonName = csrRaw["csr.common.name"];
      serialNumber= csrRaw["csr.serial.number"];
      organizationIdentifier= csrRaw["csr.organization.identifier"];
      organizationUnitName= csrRaw["csr.organization.unit.name"];
      organizationName= csrRaw["csr.organization.name"];
      countryName= csrRaw["csr.country.name"];
      invoiceType= csrRaw["csr.invoice.type"];
      locationAddress= csrRaw["csr.location.address"];
      industryBusinessCategory= csrRaw["csr.industry.business.category"];
  }

}