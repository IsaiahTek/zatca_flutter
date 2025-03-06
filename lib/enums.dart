enum TaxCategoryCode{
  standard,
  exempt,
  zeroRated,
  outsideVatScope
}

final Map<TaxCategoryCode, String> taxCategoryCodeValues = {
  TaxCategoryCode.exempt: 'E',
  TaxCategoryCode.standard: 'S',
  TaxCategoryCode.outsideVatScope: 'O',
  TaxCategoryCode.zeroRated: 'Z'
};

enum TaxSchemeCode{
  /// Value Added Tax (VAT) (KSA's tax system)
  vat,

  /// Central Sales Tax (CST)
  cst,
  
  /// Goods & Services Tax (GST)
  gst
}

/// Invoice Report Response
enum InvoiceResultStatus{
  reported,
  notReported,
  acceptedWithWarnings,
}

enum ClearedInvoiceResultStatus{
  cleared,
  notCleared
}

enum ResponseStatus{
  failure,
  success
}


/// Enum representing different response statuses
enum CSIDResponseStatus { success, clientError, serverError, unknown }