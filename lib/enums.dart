/// Enum for Tax Category Codes, which represent different tax types in the system.
/// These values are used to categorize tax information for invoices.
enum TaxCategoryCode {
  /// Exempt from tax.
  exempt,

  /// Subject to standard tax rate.
  standard,

  /// Subject to zero-rated tax.
  zeroRated,

  /// Outside the scope of VAT (Value Added Tax).
  outsideVatScope
}

/// A map that maps each [TaxCategoryCode] to its respective string value used in the system.
/// The string values are commonly used for serialization or communication with external services.
final Map<TaxCategoryCode, String> taxCategoryCodeValues = {
  TaxCategoryCode.exempt: 'E',             // Exempt tax category
  TaxCategoryCode.standard: 'S',           // Standard tax category
  TaxCategoryCode.outsideVatScope: 'O',   // Outside VAT scope
  TaxCategoryCode.zeroRated: 'Z'          // Zero-rated tax category
};

/// Enum for Tax Scheme Codes, which represent different types of tax schemes.
/// These codes are used to identify the tax system applied to the invoice.
enum TaxSchemeCode {
  /// Value Added Tax (VAT) is the tax system used in the Kingdom of Saudi Arabia (KSA).
  vat,

  /// Central Sales Tax (CST) is a tax system used in India.
  cst,

  /// Goods & Services Tax (GST) is a tax system used in several countries like India, Canada, and others.
  gst
}

/// Enum for Invoice Result Status, which represents the different statuses an invoice can have after processing.
/// These statuses are used to indicate the result of the invoice reporting process.
enum InvoiceResultStatus {
  /// The invoice has been reported successfully.
  reported,

  /// The invoice has not been reported.
  notReported,

  /// The invoice has been accepted but with warnings.
  acceptedWithWarnings,
}

/// Enum for Cleared Invoice Result Status, which represents whether an invoice has been cleared in the system.
/// It helps track the invoice's clearance status.
enum ClearedInvoiceResultStatus {
  /// The invoice has been cleared.
  cleared,

  /// The invoice has not been cleared.
  notCleared,
}

/// Enum for Response Status, which is used to represent the result of a response to an API request.
/// This helps in indicating whether the request was successful or failed.
enum ResponseStatus {
  /// The request failed.
  failure,

  /// The request was successful.
  success
}

/// Enum for CSID (Certificate Serial ID) Response Status, which indicates the result of an operation related to CSID.
/// It includes success or different error types encountered during processing.
enum CSIDResponseStatus {
  /// The CSID operation was successful.
  success,

  /// The CSID operation encountered a client-side error.
  clientError,

  /// The CSID operation encountered a server-side error.
  serverError,

  /// The CSID operation encountered an unknown error.
  unknown
}
