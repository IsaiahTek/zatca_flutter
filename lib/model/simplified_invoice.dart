import 'dart:convert';

import '../model/invoice_total.dart';

import 'invoice_item.dart';
import 'seller.dart';

class SimplifiedInvoice {
  final String invoiceNumber;
  final DateTime issueDateTime;
  final Seller seller;
  final List<InvoiceItem> items;
  final InvoiceTotal invoiceTotal;
  final String qrCode;
  final String uuid;
  final String electronicSignature;
  final String hash;
  final String cryptographicStamp;

  SimplifiedInvoice({
    required this.invoiceNumber,
    required this.issueDateTime,
    required this.seller,
    required this.items,
    required this.invoiceTotal,
    required this.qrCode,
    required this.uuid,
    required this.electronicSignature,
    required this.hash,
    required this.cryptographicStamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "invoiceNumber": invoiceNumber,
      "issueDateTime": issueDateTime.toIso8601String(),
      "seller": seller.toJson(),
      "items": items.map((item) => item.toJson()).toList(),
      "invoiceTotal": invoiceTotal.toJson(),
      "qrCode": qrCode,
      "uuid": uuid,
      "electronicSignature": electronicSignature,
      "hash": hash,
      "cryptographicStamp": cryptographicStamp,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}