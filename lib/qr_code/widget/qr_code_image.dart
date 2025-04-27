import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A widget to display a QR code as an image in your app.
///
/// This widget renders a QR code using the data provided in [base64EncodedQrCode],
/// which is typically obtained from the Fatoora service (for simplified invoices, debit notes,
/// and credit notes) or from the ZATCA clearance data (for standard [B2B] invoices, debit notes,
/// and credit notes).
class QrCodeImage extends StatelessWidget {
  /// The base64 encoded QR code string, usually fetched from the Fatoora or ZATCA services.
  ///
  /// This is the data to be displayed as a QR code.
  final String base64EncodedQrCode;

  /// Constructor for [QrCodeImage].
  ///
  /// - [base64EncodedQrCode]: The base64 encoded QR code string to display.
  /// - [key]: An optional key used for managing widget state (from the parent class).
  const QrCodeImage({super.key, required this.base64EncodedQrCode});

  @override
  Widget build(BuildContext context) {
    // Returns the QR code image rendered from the base64EncodedQrCode string.
    return QrImageView(
      data: base64EncodedQrCode,
      semanticsLabel: base64EncodedQrCode, // For accessibility purposes
    );
  }
}
