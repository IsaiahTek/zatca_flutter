import 'package:zatca_flutter/model/fatoora_invoice_hash_response.dart';
import 'package:zatca_flutter/model/fatoora_qr_code_response.dart';
import 'package:zatca_flutter/service/fatoora_service.dart';

/// A service for handling operations related to cleared invoices,
/// such as extracting QR codes and invoice hashes.
class ClearedInvoiceService {
  /// Retrieves the QR code for a cleared invoice based on the [filename].
  ///
  /// This method internally calls [_getQrCode].
  ///
  /// Returns the QR code string if successful, otherwise `null`.
  static Future<String?> getQrCode(String filename) async =>
      _getQrCode(filename);

  /// Internal helper to generate a QR code from an invoice file.
  ///
  /// [filename]: The name of the invoice file under the `standard/` directory.
  ///
  /// Returns the QR code string.
  static Future<String?> _getQrCode(String filename) async {
    String filePath = "standard/$filename";
    FatooraQrCodeResponse res =
        await FatooraService.generateInvoiceQRCode(filePath);
    return res.qrCode;
  }

  /// Retrieves the hash value of a cleared invoice based on the [filename].
  ///
  /// This method internally calls [_getInvoiceHash].
  ///
  /// Returns the hash string if successful, otherwise `null`.
  static Future<String?> getInvoiceHash(String filename) async =>
      _getInvoiceHash(filename);

  /// Internal helper to generate a hash from an invoice file.
  ///
  /// [filename]: The name of the invoice file under the `standard/` directory.
  ///
  /// Returns the hash string.
  static Future<String?> _getInvoiceHash(String filename) async {
    String filePath = "standard/$filename";
    FatooraInvoiceHashResponse res =
        await FatooraService.generateInvoiceHash(filePath);
    return res.hashValue;
  }
}
