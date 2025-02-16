import 'buyer.dart';
import 'invoice_item.dart';
import 'invoice_total.dart';
import 'seller.dart';

class StandardInvoice {
  final String invoiceType;
  final String invoiceNumber;
  final DateTime issueDateTime;
  final Seller seller;
  final Buyer buyer;
  final List<InvoiceItem> items;
  final InvoiceTotal invoiceTotal;
  final String paymentTerms;
  final String currency;
  final String uuid;
  final String electronicSignature;
  final String hash;
  final String cryptographicStamp;

  StandardInvoice({
    required this.invoiceType,
    required this.invoiceNumber,
    required this.issueDateTime,
    required this.seller,
    required this.buyer,
    required this.items,
    required this.invoiceTotal,
    required this.paymentTerms,
    required this.currency,
    required this.uuid,
    required this.electronicSignature,
    required this.hash,
    required this.cryptographicStamp,
  });

  Map<String, dynamic> toJson() => {
        "invoiceType": invoiceType,
        "invoiceNumber": invoiceNumber,
        "issueDateTime": issueDateTime.toIso8601String(),
        "seller": seller.toJson(),
        "buyer": buyer.toJson(),
        "items": items.map((item) => item.toJson()).toList(),
        "invoiceTotal": invoiceTotal.toJson(),
        "paymentTerms": paymentTerms,
        "currency": currency,
        "uuid": uuid,
        "electronicSignature": electronicSignature,
        "hash": hash,
        "cryptographicStamp": cryptographicStamp,
      };
}
