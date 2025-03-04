class StandardDebitNote {
  final String id;
  final String uuid;
  final String issueDate;
  final String issueTime;
  final String documentCurrencyCode;
  final String taxCurrencyCode;
  // final BillingReference billingReference;
  // final List<AdditionalDocumentReference> additionalDocumentReferences;
  // final Signature signature;
  // final AccountingSupplierParty accountingSupplierParty;
  // final AccountingCustomerParty accountingCustomerParty;
  // final Delivery delivery;

  StandardDebitNote({
    required this.id,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.documentCurrencyCode,
    required this.taxCurrencyCode,
    // required this.billingReference,
    // required this.additionalDocumentReferences,
    // required this.signature,
    // required this.accountingSupplierParty,
    // required this.accountingCustomerParty,
    // required this.delivery,
  });
}

