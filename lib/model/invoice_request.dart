class InvoiceRequest {
  final String invoiceHash;
  final String invoice;

  const InvoiceRequest({
    required this.invoice,
    required this.invoiceHash
  });
}