/// Represents the buyer in a transaction, including their name, VAT number, and address.
///
/// The [Buyer] class holds information about the buyer, which is typically required for invoicing
/// and tax-related documents. The class includes:
/// - [name]: The name of the buyer.
/// - [vatNumber]: The VAT (Value Added Tax) number of the buyer, which is used for tax purposes.
/// - [address]: The physical address of the buyer.
class Buyer {
  /// The name of the buyer.
  final String name;

  /// The VAT number of the buyer, used for tax identification.
  final String vatNumber;

  /// The physical address of the buyer.
  final String address;

  /// Constructs a [Buyer] instance with the specified [name], [vatNumber], and [address].
  ///
  /// [name] is the full name of the buyer.
  /// [vatNumber] is the VAT number assigned to the buyer for tax purposes.
  /// [address] is the complete physical address of the buyer.
  Buyer({required this.name, required this.vatNumber, required this.address});

  /// Converts the [Buyer] instance to a JSON representation.
  ///
  /// This method returns a map containing the [name], [vatNumber], and [address] of the buyer.
  ///
  /// Example:
  /// ```dart
  /// Buyer buyer = Buyer(name: "John Doe", vatNumber: "123456789", address: "123 Main St");
  /// Map<String, dynamic> buyerJson = buyer.toJson();
  /// ```
  Map<String, dynamic> toJson() => {
        "name": name,
        "vatNumber": vatNumber,
        "address": address,
      };
}
