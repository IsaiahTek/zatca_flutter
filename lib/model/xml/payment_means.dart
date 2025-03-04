import 'package:xml/xml.dart';
enum PaymentMeansCode{
  cash,
  creditCard,
  debitCard,
  creditorAccount,
  mobilePayment,
  other
}

final Map<PaymentMeansCode, String> _paymentMeansCodeValues = {
  PaymentMeansCode.cash:'10',
  PaymentMeansCode.creditCard: '30',
  PaymentMeansCode.creditorAccount: '42',
  PaymentMeansCode.debitCard: '31',
  PaymentMeansCode.mobilePayment: '48',
  PaymentMeansCode.other: 'ZZZ'
};

class PaymentMeans {

  PaymentMeansCode code;
  String instructionNote;


  PaymentMeans({required this.code, required this.instructionNote});

  toXml(XmlBuilder builder){
    builder.element('cac:PaymentMeans', nest: (){
      builder.element('cbc:PaymentMeansCode', nest: _paymentMeansCodeValues[code]);
      builder.element('cbc:InstructionNote', nest: instructionNote);
    });
  }
}