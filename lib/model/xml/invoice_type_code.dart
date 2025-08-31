import 'package:xml/xml.dart';

/// Represents the `<cbc:InvoiceTypeCode>` element in a ZATCA-compliant UBL invoice.
///
/// The element consists of:
/// - A numeric `code` (UN/CEFACT 1001 subset):
///   - `388` = Tax invoice
///   - `381` = Credit note
///   - `383` = Debit note
///   - `386` = Prepayment invoice
///
/// - A `name` attribute: a 7-character string (`NNPNESB`) that encodes invoice subtype & flags:
///   1–2. `NN` = Subtype (`01` = Standard, `02` = Simplified)
///   3.   `P`  = 3rd-party (0/1)
///   4.   `N`  = Nominal (0/1)
///   5.   `E`  = Export (0/1)
///   6.   `S`  = Summary (0/1)
///   7.   `B`  = Self-billed (0/1)
///
/// Example:
/// ```xml
/// <cbc:InvoiceTypeCode name="0100000">388</cbc:InvoiceTypeCode>
/// ```
class InvoiceTypeCode {
  /// name attribute
  final String type;

  /// element value
  final String code;

  /// InvoiceTypeCode constructor
  InvoiceTypeCode({required this.code, required this.type});

  /// Used internally for building the xml element for cbc:InvoiceTypeCode
  void toXml(XmlBuilder builder) {
    builder.element(
      'cbc:InvoiceTypeCode',
      nest: code,
      attributes: {'name': type},
    );
  }

  // ==========================================================================
  // Factories for STANDARD (01) invoices
  // ==========================================================================

  /// Utility for composing InvoiceTypeCode with values for Standard Invoice
  factory InvoiceTypeCode.standardTaxInvoice({
    bool thirdParty = false,
    bool nominal = false,
    bool export = false,
    bool summary = false,
    bool selfBilled = false,
  }) {
    return _build(
      subtype: '01',
      code: '388',
      thirdParty: thirdParty,
      nominal: nominal,
      export: export,
      summary: summary,
      selfBilled: selfBilled,
    );
  }

  /// Utility for composing InvoiceTypeCode with values for Standard Credit Note
  factory InvoiceTypeCode.standardCreditNote() {
    return InvoiceTypeCode(code: '381', type: '0100000');
  }

  /// Utility for composing InvoiceTypeCode with values for Standard Debit Note
  factory InvoiceTypeCode.standardDebitNote() {
    return InvoiceTypeCode(code: '383', type: '0100000');
  }

  /// Utility for composing InvoiceTypeCode with values for Standard Prepayment Invoice
  factory InvoiceTypeCode.standardPrepaymentInvoice() {
    return InvoiceTypeCode(code: '386', type: '0100000');
  }

  // ==========================================================================
  // Factories for SIMPLIFIED (02) invoices
  // ==========================================================================

  /// Utility for composing InvoiceTypeCode with values for Simplified Invoice
  factory InvoiceTypeCode.simplifiedTaxInvoice({
    bool thirdParty = false,
    bool nominal = false,
    bool export = false,
    bool summary = false,
    bool selfBilled = false,
  }) {
    return _build(
      subtype: '02',
      code: '388',
      thirdParty: thirdParty,
      nominal: nominal,
      export: export,
      summary: summary,
      selfBilled: selfBilled,
    );
  }

  /// Utility for composing InvoiceTypeCode with values for Simplified Credit Note
  factory InvoiceTypeCode.simplifiedCreditNote() {
    return InvoiceTypeCode(code: '381', type: '0200000');
  }

  /// Utility for composing InvoiceTypeCode with values for Simplified Debit Note
  factory InvoiceTypeCode.simplifiedDebitNote() {
    return InvoiceTypeCode(code: '383', type: '0200000');
  }

  /// Utility for composing InvoiceTypeCode with values for Simplified Prepayment Invoice
  factory InvoiceTypeCode.simplifiedPrepaymentInvoice() {
    return InvoiceTypeCode(code: '386', type: '0200000');
  }

  // ==========================================================================
  // Internal helpers
  // ==========================================================================

  static InvoiceTypeCode _build({
    required String subtype, // "01" or "02"
    required String code,
    bool thirdParty = false,
    bool nominal = false,
    bool export = false,
    bool summary = false,
    bool selfBilled = false,
  }) {
    // Business rule validation
    if (export && selfBilled) {
      throw ArgumentError(
          'Invalid InvoiceTypeCode: Export invoices cannot be self-billed (E=1, B=1).');
    }

    final type = [
      subtype, // NN
      thirdParty ? '1' : '0', // P
      nominal ? '1' : '0', // N
      export ? '1' : '0', // E
      summary ? '1' : '0', // S
      selfBilled ? '1' : '0', // B
    ].join();

    return InvoiceTypeCode(code: code, type: type);
  }
}
