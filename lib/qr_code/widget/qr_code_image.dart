import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
/// Use this widget to display the qr code as an image in your app
class QrCodeImage extends StatelessWidget {
  /// This is gotten from the fatoora service (for simplified invoice, debit note, and for credit note) or zatca clearance data (for standard [B2B] invoice, debit note, and credit note)
  final String base64EncodedQrCode;

  /// Constructor
  QrCodeImage({super.key, required this.base64EncodedQrCode});

  @override
  Widget build(BuildContext context) {
    return QrImageView(data: base64EncodedQrCode, semanticsLabel: base64EncodedQrCode,);
  }
}