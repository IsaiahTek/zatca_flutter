class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double taxableAmount;
  final double vatRate;
  final double vatAmount;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.taxableAmount,
    required this.vatRate,
    required this.vatAmount,
  });

  Map<String, dynamic> toJson() => {
        "description": description,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "taxableAmount": taxableAmount,
        "vatRate": vatRate,
        "vatAmount": vatAmount,
      };
}