import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Use this widget to display the qr code as an image in your app
class QrCodeImage extends StatelessWidget {

  /// This is gotten from the fatoora service (for simplified invoice, debit note, and for credit note) or zatca clearance data (for standard [B2B] invoice, debit note, and credit note)
  final String base64EncodedQrCode;

  /// Constructor
  const QrCodeImage({super.key, required this.base64EncodedQrCode});

  /// Decoded value of base64 QR Code value
  Uint8List get base64DecodedQrCode{
    return base64Decode(base64EncodedQrCode);
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(base64DecodedQrCode);
  }
}