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