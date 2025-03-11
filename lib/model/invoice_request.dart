class InvoiceRequest {
  final String invoiceHash;
  final String invoice;
  final String uuid;

  const InvoiceRequest(
      {required this.invoice, required this.invoiceHash, required this.uuid});

  static InvoiceRequest fromMap(Map<String, dynamic> map) {
    return InvoiceRequest(
        invoice: map["invoice"],
        invoiceHash: map["invoiceHash"],
        uuid: map["uuid"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "invoiceHash": invoiceHash,
      "invoice": invoice,
      "uuid": uuid,
    };
  }

  @override
  String toString() {
    return 'InvoiceRequest => "invoiceHash": $invoiceHash, "invoice": $invoice, "uuid": $uuid';
  }
}
