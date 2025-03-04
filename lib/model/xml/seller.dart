class Seller {
  final String name;
  final String vatNumber;
  final String address;

  Seller({required this.name, required this.vatNumber, required this.address});

  Map<String, dynamic> toJson() => {
        "name": name,
        "vatNumber": vatNumber,
        "address": address,
      };
}
