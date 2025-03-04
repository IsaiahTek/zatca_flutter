class Buyer {
  final String name;
  final String vatNumber;
  final String address;

  Buyer({required this.name, required this.vatNumber, required this.address});

  Map<String, dynamic> toJson() => {
        "name": name,
        "vatNumber": vatNumber,
        "address": address,
      };
}