import 'package:xml/xml.dart';

abstract class PartyBase{
  String name;
  String taxId;
  String address;

  PartyBase({
    required this.name,
    required this.taxId,
    required this.address,
  });

  toXml(XmlBuilder builder);
}

class IndividualParty extends PartyBase {

  IndividualParty({
    required super.name,
    required super.taxId,
    required super.address,
  });

  @override
  void toXml(XmlBuilder builder) {
    builder.element('cac:Party', nest: () {
      builder.element('cac:PostalAddress', nest: () {
        builder.element('cbc:StreetName', nest: address);
      });
      builder.element('cac:PartyTaxScheme', nest: () {
        builder.element('cbc:CompanyID', nest: taxId);
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID', nest: 'VAT');
        });
      });
      builder.element('cac:PartyLegalEntity', nest: () {
        builder.element('cbc:RegistrationName', nest: name);
      });
    });
  }
}

class BusinessParty extends PartyBase{

  String buildingNumber;
  String citySubdivision;
  String city;
  String postalZone;
  String countryCode;
  String businessID;
  /// schemeID is typically 'CRN'
  String schemeID;

  BusinessParty({
    required super.address,
    required super.name,
    required super.taxId,
    required this.buildingNumber,
    required this.citySubdivision,
    required this.city,
    required this.postalZone,
    required this.countryCode,
    /// schemeID is typically 'CRN'
    required this.schemeID,
    required this.businessID,
  });

  @override
  void toXml(XmlBuilder builder) {
    builder.element('cac:Party', nest: () {
      builder.element('cac:PartyIdentification', nest: () {
        builder.element('cbc:ID', nest: businessID, attributes: {'schemeID': schemeID});
      });
      builder.element('cac:PostalAddress', nest: () {
        builder.element('cbc:StreetName', nest: address);
        builder.element('cbc:BuildingNumber', nest: buildingNumber);
        builder.element('cbc:CitySubdivisionName', nest: citySubdivision);
        builder.element('cbc:CityName', nest: city);
        builder.element('cbc:PostalZone', nest: postalZone);
        builder.element('cac:Country', nest: () {
          builder.element('cbc:IdentificationCode', nest: countryCode);
        });
      });
      builder.element('cac:PartyTaxScheme', nest: () {
        builder.element('cbc:CompanyID', nest: taxId);
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID', nest: 'VAT');
        });
      });
      builder.element('cac:PartyLegalEntity', nest: () {
        builder.element('cbc:RegistrationName', nest: name);
      });
    });
  }
}