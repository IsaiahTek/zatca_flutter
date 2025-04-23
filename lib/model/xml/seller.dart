/// A class representing the seller (vendor) in an invoice or transaction.
///
/// The [Seller] class contains details about the seller, such as their name,
/// VAT number, and address, which are typically required in business transactions.
class Seller {
  /// The name of the seller.
  final String name;

  /// The VAT (Value Added Tax) number of the seller, which is used for tax reporting purposes.
  final String vatNumber;

  /// The address of the seller, usually in the form of street address, city, and postal code.
  final String address;

  /// Constructor to initialize the [Seller] object with a name, VAT number, and address.
  Seller({required this.name, required this.vatNumber, required this.address});

  /// Converts the [Seller] object into a JSON map.
  ///
  /// This method is used to serialize the [Seller] object into a format that can be
  /// used in APIs, databases, or other systems that require JSON data representation.
  Map<String, dynamic> toJson() => {
        "name": name,
        "vatNumber": vatNumber,
        "address": address,
      };
}
