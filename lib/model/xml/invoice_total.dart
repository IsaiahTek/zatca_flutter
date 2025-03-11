class InvoiceTotal {
  final double subtotal;
  final double vatAmount;
  final double grandTotal;

  InvoiceTotal(
      {required this.subtotal,
      required this.vatAmount,
      required this.grandTotal});

  Map<String, dynamic> toJson() => {
        "subtotal": subtotal,
        "vatAmount": vatAmount,
        "grandTotal": grandTotal,
      };
}
