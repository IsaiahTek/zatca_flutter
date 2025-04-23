import 'package:xml/xml.dart';

/// Enum representing various payment means codes.
enum PaymentMeansCode {
  /// Represents a cash payment.
  cash,

  /// Represents a credit card payment.
  creditCard,

  /// Represents a debit card payment.
  debitCard,

  /// Represents a creditor's account payment.
  creditorAccount,

  /// Represents a mobile payment (e.g., via mobile apps).
  mobilePayment,

  /// Represents any other type of payment that doesn't fall under the predefined categories.
  other
}

/// A map to associate each [PaymentMeansCode] with its corresponding code value for XML.
final Map<PaymentMeansCode, String> _paymentMeansCodeValues = {
  PaymentMeansCode.cash: '10',
  PaymentMeansCode.creditCard: '30',
  PaymentMeansCode.creditorAccount: '42',
  PaymentMeansCode.debitCard: '31',
  PaymentMeansCode.mobilePayment: '48',
  PaymentMeansCode.other: 'ZZZ'
};

/// A class representing the means of payment in an invoice or transaction.
/// This includes the code representing the type of payment and an optional instruction note.
class PaymentMeans {
  /// The payment means code (e.g., credit card, cash).
  PaymentMeansCode code;

  /// An instruction note providing additional details about the payment.
  String instructionNote;

  /// Constructor to initialize the [PaymentMeans] object with a [code] and [instructionNote].
  PaymentMeans({required this.code, required this.instructionNote});

  /// Converts the [PaymentMeans] object into an XML structure.
  ///
  /// This method generates XML elements for the payment means, including:
  /// - `cbc:PaymentMeansCode`: The code for the payment means.
  /// - `cbc:InstructionNote`: A note explaining the payment method (if applicable).
  void toXml(XmlBuilder builder) {
    builder.element('cac:PaymentMeans', nest: () {
      builder.element('cbc:PaymentMeansCode',
          nest: _paymentMeansCodeValues[code]);
      builder.element('cbc:InstructionNote', nest: instructionNote);
    });
  }
}
