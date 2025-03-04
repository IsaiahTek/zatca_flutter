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

class Party extends PartyBase {

  Party({
    required super.name,
    required super.taxId,
    required super.address,
  });

  @override
  void toXml(XmlBuilder builder) {
    builder.element('cac:Party', nest: () {
      builder.element('cac:PartyIdentification', nest: () {
        builder.element('cbc:ID', nest: taxId, attributes: {'schemeID': 'CRN'});
      });
      builder.element('cac:PostalAddress', nest: () {
        builder.element('cbc:StreetName', nest: address);
        // builder.element('cbc:BuildingNumber', nest: buildingNumber);
        // builder.element('cbc:CitySubdivisionName', nest: citySubdivision);
        // builder.element('cbc:CityName', nest: city);
        // builder.element('cbc:PostalZone', nest: postalZone);
        // builder.element('cac:Country', nest: () {
        //   builder.element('cbc:IdentificationCode', nest: countryCode);
        // });
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

class SupplierParty extends PartyBase{

  String buildingNumber;
  String citySubdivision;
  String city;
  String postalZone;
  String countryCode;
  int crn;

  SupplierParty({
    required super.address,
    required super.name,
    required super.taxId,
    required this.buildingNumber,
    required this.citySubdivision,
    required this.city,
    required this.postalZone,
    required this.countryCode,
    required this.crn,
  });

  @override
  void toXml(XmlBuilder builder) {
    builder.element('cac:Party', nest: () {
      builder.element('cac:PartyIdentification', nest: () {
        builder.element('cbc:ID', nest: crn, attributes: {'schemeID': 'CRN'});
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