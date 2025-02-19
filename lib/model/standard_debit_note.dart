class StandardDebitNote {
  final String id;
  final String uuid;
  final String issueDate;
  final String issueTime;
  final String documentCurrencyCode;
  final String taxCurrencyCode;
  final BillingReference billingReference;
  final List<AdditionalDocumentReference> additionalDocumentReferences;
  final Signature signature;
  final AccountingSupplierParty accountingSupplierParty;
  final AccountingCustomerParty accountingCustomerParty;
  final Delivery delivery;

  StandardDebitNote({
    required this.id,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.documentCurrencyCode,
    required this.taxCurrencyCode,
    required this.billingReference,
    required this.additionalDocumentReferences,
    required this.signature,
    required this.accountingSupplierParty,
    required this.accountingCustomerParty,
    required this.delivery,
  });
}

class BillingReference {
  final InvoiceDocumentReference invoiceDocumentReference;

  BillingReference({
    required this.invoiceDocumentReference,
  });
}

class InvoiceDocumentReference {
  final String id;

  InvoiceDocumentReference({
    required this.id,
  });
}

class AdditionalDocumentReference {
  final String id;
  final String uuid;

  AdditionalDocumentReference({
    required this.id,
    required this.uuid,
  });
}

class Signature {
  final SignatureInformation signatureInformation;

  Signature({
    required this.signatureInformation,
  });
}

class SignatureInformation {
  final String id;
  final String referencedSignatureID;
  final String signatureValue;

  SignatureInformation({
    required this.id,
    required this.referencedSignatureID,
    required this.signatureValue,
  });
}

class AccountingSupplierParty {
  final Party party;

  AccountingSupplierParty({
    required this.party,
  });
}

class AccountingCustomerParty {
  final Party party;

  AccountingCustomerParty({
    required this.party,
  });
}

class Party {
  final PartyIdentification partyIdentification;
  final PostalAddress postalAddress;
  final PartyTaxScheme partyTaxScheme;

  Party({
    required this.partyIdentification,
    required this.postalAddress,
    required this.partyTaxScheme,
  });
}

class PartyIdentification {
  final String id;
  final String name;

  PartyIdentification({
    required this.id,
    required this.name,
  });
}

class PostalAddress {
  final String streetName;
  final String buildingNumber;
  final String citySubdivisionName;
  final String cityName;
  final String postalZone;
  final Country country;

  PostalAddress({
    required this.streetName,
    required this.buildingNumber,
    required this.citySubdivisionName,
    required this.cityName,
    required this.postalZone,
    required this.country,
  });
}

class Country {
  final String countryName;

  Country({
    required this.countryName,
  });
}

class PartyTaxScheme {
  // You can add any necessary fields for tax schemes if required.
}

class Delivery {
  final String actualDeliveryDate;

  Delivery({
    required this.actualDeliveryDate,
  });
}
