/// Represents an individual item in an invoice, including details such as description,
/// quantity, unit price, taxable amount, VAT rate, and VAT amount.
///
/// The [InvoiceItem] class contains the necessary fields to represent a single item
/// listed in an invoice, including pricing and VAT details. This is typically used in
/// invoices for billing or tax reporting purposes.
///
/// Fields:
/// - [description]: A description of the item being billed.
/// - [quantity]: The quantity of the item.
/// - [unitPrice]: The price per unit of the item.
/// - [taxableAmount]: The taxable amount for the item (without VAT).
/// - [vatRate]: The VAT rate applied to the item (expressed as a percentage).
/// - [vatAmount]: The VAT amount for the item, calculated based on the VAT rate.
class InvoiceItem {
  /// A description of the item being billed.
  final String description;

  /// The quantity of the item.
  final int quantity;

  /// The price per unit of the item.
  final double unitPrice;

  /// The taxable amount for the item (before VAT).
  final double taxableAmount;

  /// The VAT rate applied to the item, expressed as a percentage.
  final double vatRate;

  /// The VAT amount calculated based on the taxable amount and VAT rate.
  final double vatAmount;

  /// Constructs an [InvoiceItem] with the provided details.
  ///
  /// [description] is a textual description of the item.
  /// [quantity] is the quantity of the item purchased.
  /// [unitPrice] is the price per unit of the item.
  /// [taxableAmount] is the taxable portion of the item, exclusive of VAT.
  /// [vatRate] is the VAT rate expressed as a percentage (e.g., 5% VAT is 5.0).
  /// [vatAmount] is the calculated VAT amount for the item.
  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.taxableAmount,
    required this.vatRate,
    required this.vatAmount,
  });

  /// Converts the [InvoiceItem] instance to a JSON map.
  ///
  /// The method generates a map representation of the invoice item, which can be used
  /// for serializing the object into JSON for APIs or storage.
  ///
  /// Example:
  /// ```json
  /// {
  ///   "description": "Laptop",
  ///   "quantity": 1,
  ///   "unitPrice": 1000.0,
  ///   "taxableAmount": 1000.0,
  ///   "vatRate": 5.0,
  ///   "vatAmount": 50.0
  /// }
  /// ```
  Map<String, dynamic> toJson() => {
        "description": description,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "taxableAmount": taxableAmount,
        "vatRate": vatRate,
        "vatAmount": vatAmount,
      };
}
