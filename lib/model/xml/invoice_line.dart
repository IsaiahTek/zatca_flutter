import 'package:xml/xml.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';

/// Represents a line item in an invoice, including details such as the item name,
/// quantity, price, total, and tax information.
///
/// The [InvoiceLine] class is used to model an individual item in an invoice,
/// capturing details such as the name, quantity, unit price, total amount,
/// and the associated tax information for proper invoicing and tax reporting.
class InvoiceLine {
  /// An optional identifier for the invoice line.
  String? id;

  /// The name or description of the invoiced item.
  String name;

  /// The quantity of the item being invoiced.
  String quantity;

  /// The unit price of the item being invoiced.
  String price;

  /// The total amount for the item, including any applicable tax.
  String total;

  /// The tax details applied to this invoice line.
  TaxDetails tax;

  /// Constructs an [InvoiceLine] with the provided details.
  ///
  /// [name] is the description of the item.
  /// [quantity] is the number of units for this item.
  /// [price] is the price per unit of the item.
  /// [total] is the total amount for the line item, including VAT.
  /// [tax] is the [TaxDetails] object that contains information about the tax rate and amount.
  InvoiceLine({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    required this.tax,
  });

  /// Converts the [InvoiceLine] instance into XML format using the [XmlBuilder].
  ///
  /// The method generates the XML representation of the invoice line, including
  /// the item details, price, tax, and other related information. This is typically
  /// used for generating XML-based invoices.
  ///
  /// [id] is the unique identifier for this invoice line.
  void toXml(XmlBuilder builder, int id) {
    builder.element('cbc:ID', nest: id);
    builder.element('cbc:InvoicedQuantity',
        attributes: {'unitCode': 'PCE'}, nest: quantity);
    builder.element('cbc:LineExtensionAmount',
        attributes: {'currencyID': 'SAR'}, nest: total);

    builder.element('cac:TaxTotal', nest: () {
      builder.element('cbc:TaxAmount',
          attributes: {'currencyID': 'SAR'}, nest: tax.amount);
      builder.element('cbc:RoundingAmount',
          attributes: {'currencyID': 'SAR'},
          nest: num.parse(tax.taxableAmount) + num.parse(tax.amount));
    });

    builder.element('cac:Item', nest: () {
      builder.element('cbc:Name', nest: name);
      builder.element('cac:ClassifiedTaxCategory', nest: () {
        builder.element('cbc:ID', nest: 'S');
        builder.element('cbc:Percent', nest: tax.percent);
        builder.element('cac:TaxScheme', nest: () {
          builder.element('cbc:ID', nest: 'VAT');
        });
      });
    });

    builder.element('cac:Price', nest: () {
      builder.element('cbc:PriceAmount',
          nest: price, attributes: {'currencyID': tax.currency});
    });
  }

  /// Converts the [InvoiceLine] instance into a JSON map.
  ///
  /// This method generates a map representation of the invoice line, which can be
  /// used for serializing the object into JSON format for APIs or storage.
  /// Example:
  /// ```json
  /// {
  ///   "id": "1",
  ///   "price": "100.00",
  ///   "quantity": "2",
  ///   "total": "200.00",
  ///   "tax": { ... } // JSON representation of TaxDetails
  /// }
  /// ```
  toJson() {
    return {
      'id': id,
      'price': price,
      'quantity': quantity,
      'total': total,
      'tax': tax.toJson() // Assuming `TaxDetails` has a `toJson` method.
    };
  }
}
