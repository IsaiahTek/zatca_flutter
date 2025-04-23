/// Represents the total values of an invoice, including the subtotal, VAT amount, 
/// and the grand total.
///
/// The [InvoiceTotal] class holds the final calculations for an invoice, summarizing 
/// the subtotal before taxes, the VAT amount, and the final grand total after adding 
/// taxes. It is used to represent the overall financial summary of an invoice.
class InvoiceTotal {
  /// The subtotal amount before VAT is applied.
  final double subtotal;

  /// The total VAT amount applied to the invoice.
  final double vatAmount;

  /// The grand total amount of the invoice, including VAT.
  final double grandTotal;

  /// Constructs an [InvoiceTotal] with the provided amounts.
  ///
  /// [subtotal] is the total amount before VAT is added.
  /// [vatAmount] is the total VAT amount.
  /// [grandTotal] is the total amount after VAT is included.
  InvoiceTotal({
    required this.subtotal,
    required this.vatAmount,
    required this.grandTotal,
  });

  /// Converts the [InvoiceTotal] instance into a JSON map.
  ///
  /// This method generates a map representation of the invoice total, which can be 
  /// used for serializing the object into JSON format for APIs or storage.
  /// Example:
  /// ```json
  /// {
  ///   "subtotal": 100.00,
  ///   "vatAmount": 15.00,
  ///   "grandTotal": 115.00
  /// }
  /// ```
  Map<String, dynamic> toJson() => {
        "subtotal": subtotal,
        "vatAmount": vatAmount,
        "grandTotal": grandTotal,
      };
}
