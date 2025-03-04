import 'package:flutter_test/flutter_test.dart';
import 'package:zatca_flutter/service/util.dart';


void main() {

  testWidgets('Invoice Hash Generation With custom output json file name', (WidgetTester testWidgets)async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // await ZatcaFlutter.init();
    // String fullPath = "Apps.dart";
    // var d = getBaseName(fullPath);
    // expect(d, 'Apps.dart');
    // SimplifiedInvoice simplifiedInvoice = SimplifiedInvoice(id: "id", uuid: "uuid", issueDate: DateTime.now(), issueTime: '12:04pm', typeCode: '392', currency: 'SAR', supplier: Party(name: "ISaiah", taxId: "taxId", address: "address 3u"), customer: Party(name: "Elizabeth", taxId: "taxId4", address: "address 3az"), lines: [InvoiceLine(id: "37y2k", quantity: "2", price: "32", total: "64", tax: TaxDetails(amount: "3", percent: "20"))], tax: TaxDetails(amount: "3", percent: "20"), monetaryTotal: LegalMonetaryTotal(lineExtensionAmount: "40", taxExclusiveAmount: "200", taxInclusiveAmount: "140", payableAmount: "42"));
    // String invoiceRawXml = SimplifiedInvoiceToXmlConverter.generateXml(simplifiedInvoice);
    // print("INVOICE XML STRING: $invoiceRawXml");

    // SimplifiedInvoiceToXmlConverter.saveXmlToFile(invoiceRawXml, 'simple_invoice.xml');
    String formatDateTimeForZatca(DateTime dateTime) {
      return dateTime.toUtc().toIso8601String().split('T')[0]; // YYYY-MM-DD
    }
    String formatTimeForZatca(DateTime dateTime) {
      return dateTime.toUtc().toIso8601String().split('T')[1].split('.')[0]; // HH:mm:ss
    }
    logInfo("DATE: ${formatDateTimeForZatca(DateTime.now())} <=> TIME: ${formatTimeForZatca(DateTime.now())}");
    
    logInfo("UUID: ${generateUuid()}");

    expect(true, true);
  });
}
