import 'package:xml/xml.dart';

/// An abstract base class for representing a party, which could be an individual or a business.
/// It holds the basic details of a party, including name, tax ID, and address, and defines the
/// common XML conversion logic.
abstract class PartyBase {
  /// The name of the party (individual or business).
  String name;

  /// The tax identification number of the party.
  String taxId;

  /// The address of the party.
  String address;

  /// Constructor to initialize the basic details of the party.
  PartyBase({
    required this.name,
    required this.taxId,
    required this.address,
  });

  /// Converts the party's details into XML format.
  ///
  /// This method needs to be implemented by subclasses to define how the party details should
  /// be represented in XML. It uses the [XmlBuilder] to generate the necessary XML structure.
  void toXml(XmlBuilder builder);
}

/// Represents an individual party (person), including their name, tax ID, and address.
/// The `toXml` method generates an XML structure specific to an individual party.
class IndividualParty extends PartyBase {
  /// Constructor to initialize the individual party's details.
  IndividualParty({
    required super.name,
    required super.taxId,
    required super.address,
  });

  /// Converts the individual party's details into XML format.
  ///
  /// This XML structure includes the name, tax ID, address, and legal entity information for
  /// an individual party. The XML elements generated are:
  /// - Postal address with street name.
  /// - Party tax scheme with the company ID (tax ID) and VAT scheme.
  /// - Party legal entity with the registration name (party name).
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

/// Represents a business party, including its address, tax ID, and other business-specific details.
/// The `toXml` method generates an XML structure specific to a business party.
class BusinessParty extends PartyBase {
  /// The building number of the business party.
  String buildingNumber;

  /// The subdivision of the city where the business is located.
  String citySubdivision;

  /// The city where the business is located.
  String city;

  /// The postal zone (postal code) of the business.
  String postalZone;

  /// The country code where the business is located.
  String countryCode;

  /// The business ID (e.g., commercial registration number).
  String businessID;

  /// The scheme ID for the business, typically 'CRN' (Commercial Registration Number).
  String schemeID;

  /// Constructor to initialize the business party's details.
  BusinessParty({
    required super.address,
    required super.name,
    required super.taxId,
    required this.buildingNumber,
    required this.citySubdivision,
    required this.city,
    required this.postalZone,
    required this.countryCode,
    required this.schemeID,
    required this.businessID,
  });

  /// Converts the business party's details into XML format.
  ///
  /// This XML structure includes the business name, tax ID, address, business ID, and legal entity
  /// information. The XML elements generated are:
  /// - Party identification with the business ID (using the scheme ID).
  /// - Postal address with street name, building number, subdivision, city, postal zone, and country.
  /// - Party tax scheme with the company ID (tax ID) and VAT scheme.
  /// - Party legal entity with the registration name (business name).
  @override
  void toXml(XmlBuilder builder) {
    builder.element('cac:Party', nest: () {
      builder.element('cac:PartyIdentification', nest: () {
        builder.element('cbc:ID',
            nest: businessID, attributes: {'schemeID': schemeID});
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
