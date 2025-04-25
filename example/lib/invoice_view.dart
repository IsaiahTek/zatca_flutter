import 'package:einvoice/invoice_new.dart';
import 'package:einvoice/state/store.dart';
// import 'package:einvoice/model/fatoora_cli_response.dart';
// import 'package:einvoice/service/fatoora_cli.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/api/invoice_clearance_response.dart';
import 'package:zatca_flutter/model/fatoora_invoice_request_api_response.dart';
import 'package:zatca_flutter/model/xml/delivery.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/model/xml/standard_invoice.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/service/fatoora_service.dart';
import 'package:zatca_flutter/service/util.dart';
// import 'package:zatca/zatca.dart';

class InvoiceView extends StatefulWidget {
  const InvoiceView({super.key});

  @override
  State<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  String? error;
  String? warning;
  String? info;

  String workingDir = "";
  String qrCode = "";

  @override
  void initState() {
    // getStorageFolderPath().then((path){
    //   Process.run("fatoora", ['-help']).then((data){
    //     Process.run("pwd", []).then((wD){
    //       setState(() {
    //         workingDir = "OUTPUT:${data.stdout}; ERROR: ${data.stderr}; WORKING DIR: ${wD.stdout} EwD: ${wD.stderr} STORAGE PATH: $path";
    //       });
    //     });
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Employee> employees = [
      Employee('12-Dec-2025', '10001', 'Invoice', 'Tax Invoice', 'Cleared'),
      Employee('12-Dec-2025', '10001', 'Invoice', 'Simplified Tax Invoice',
          'Reported'),
      Employee('12-Dec-2025', '10001', 'Credit Note', '', 'Reported'),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: Row(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            width: 200, // Set a fixed height
            color: Colors.blueGrey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvoiceNew(),
                        ),
                      );
                    },
                    label: Text('New')),
                TextButton.icon(
                    icon: Icon(Icons.add),
                    onPressed: () async {

                      StandardInvoice simplifiedInvoice = StandardInvoice(
                        icv: 1,
                        pih:'',
                        id: "INV-001",
                        uuid: generateUuid(),
                        issueDate: DateTime.now(),
                        issueTime: DateTime.now(),
                        currency: 'SAR',
                        customer: BusinessParty(
                          businessID: '1010010000',
                          address: "RRRD2929",
                          name: "Info Tech Supply LTD",
                          taxId: "399999999955553",
                          buildingNumber: "3233",
                          citySubdivision: "Al-Murabba",
                          city: "Riyadh",
                          postalZone: "23333",
                          countryCode: "SA",
                          schemeID: 'CRN'
                        ),
                        lines: [
                          InvoiceLine(
                            quantity: "1",
                            price: "64",
                            total: "64",
                            tax: TaxDetails(
                              amount: "9.60", // 64 * 15% = 9.60
                              percent: "15",
                              currency: 'SAR',
                              taxableAmount:
                                  '64', code: TaxCategoryCode.standard, // Ensure taxable amount matches total
                            ),
                            name: 'Garri',
                          )
                        ],
                        tax: TaxDetails(
                          amount: "9.60", // Sum of line-level tax amounts
                          percent: "15",
                          currency: 'SAR',
                          taxableAmount: '64', code: TaxCategoryCode.standard, // Total taxable amount
                        ),
                        monetaryTotal: LegalMonetaryTotal(
                          lineExtensionAmount: "64", // Sum of line totals
                          taxExclusiveAmount:
                              "64", // Same as lineExtensionAmount
                          taxInclusiveAmount:
                              "73.60", // taxExclusiveAmount + total VAT
                          payableAmount: "73.60", // Final payable amount
                          allowanceTotalAmount: 0.0,
                          prepaidAmount: 0.0
                        ), delivery: Delivery(actualDate: DateTime.now(), latestDate: DateTime.now()),
                        // billingReference: BillingReference(invoiceIssueDate: DateTime.now(), invoiceNumber: 1),
                        // paymentMeans: PaymentMeans(code: PaymentMeansCode.creditCard, instructionNote: "Credit card was used to make the payment"),
                      );

                      simplifiedInvoice.generateAndSaveXml('standard_invoice.xml');

                      // FatooraServiceResponse signRes = await FatooraService.signInvoice(invoiceFileName: 'note.xml', forChecks: true);
                      // debugPrint("SIGNATURE (${signRes.status.name.toUpperCase()}): ${signRes.infos?.map((d)=>d.message)}");

                      // FatooraQrCodeResponse qrCodeResponse =
                      //     await FatooraService.generateQRInvoiceCode(
                      //         'simple_invoice.xml');
                      // if (qrCodeResponse.qrCode != null ||
                      //     qrCodeResponse.status == ResponseStatus.success) {
                      //   // SimplifiedInvoice sIn = SimplifiedInvoice(id: "id", uuid: "uuid", issueDate: DateTime.now(), issueTime: DateTime.now(), typeCode: '392', currency: 'SAR',
                      //   // supplier: SupplierParty(address: "address", name: "name", taxId: "taxId", buildingNumber: "buildingNumber", citySubdivision: "citySubdivision", city: "city", postalZone: "postalZone", countryCode: "countryCode"),
                      //   // customer: Party(name: "Elizabeth", taxId: "taxId4", address: "address 3az"), lines: [InvoiceLine(quantity: "2", price: "32", total: "64", tax: TaxDetails(amount: "3", percent: "20"))], tax: TaxDetails(amount: "3", percent: "20"), monetaryTotal: LegalMonetaryTotal(lineExtensionAmount: "40", taxExclusiveAmount: "200", taxInclusiveAmount: "140", payableAmount: "42"));

                      //   // SimplifiedInvoiceToXmlConverter.saveXmlToFile(SimplifiedInvoiceToXmlConverter.generateXml(sIn), 'simple_invoice.xml');

                      //   // FatooraServiceResponse res = await FatooraService.signInvoice(invoiceFileName: "simple_invoice.xml", outputSignedInvoiceFileName: 'd.xml');

                      //   // debugPrint("RESPONSE DATA ${res.infos} ${res.warnings} ${res.errors}");
                      //   // setState(() {
                      //   //   info = (res.infos?.map((d)=>d.message)).toString();
                      //   //   warning = (res.warnings?.map((d)=>d.message)).toString();
                      //   //   error = (res.errors?.map((d)=>d.message)).toString();
                      //   // });
                      // } else {
                      //   debugPrint(
                      //       "COULDN'T GENERATE QR CODE ${qrCodeResponse.qrCode}, ${qrCodeResponse.response.errors?.map((er) => er.message)}");
                      // }

                      // FatooraServiceResponse validationRes = await FatooraService.validateInvoice(invoiceFileName: 'note_signed.xml', ignoreWarningForResponseStatus: true);
                      // debugPrint("VALIDATION (${validationRes.status.name.toUpperCase()}): SUCCESS (${validationRes.infos?.length}); FAILURE (${validationRes.errors?.length}) WARNING (${validationRes.warnings?.length}) ${validationRes.infos?.map((d)=>d.message)}");

                      // await FatooraService.signInvoice(invoiceFileName: 'note.xml', forChecks: false);

                      FatooraInvoiceRequestApiResponse invoiceApi = await FatooraService.generateInvoiceRequestAPI(invoiceFileName: 'standard_invoice.xml', forClearance: true);
                      // debugPrint("INVOICE API: ${invoiceApi.invoiceRequest?.toMap()}");
                      Controller controller = Controller.instance;
                      InvoiceClearanceResponse? res = await controller.request.requestClearance(invoiceApi.invoiceRequest!);

                      debugPrint("RESULT FROM CHECKS ${res?.statusCode} ${res?.clearanceStatus} ${res?.clearanceData?.toJson()}");

                    },
                    label: Text('Test'))
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SfDataGrid(
                  columnWidthMode: ColumnWidthMode.auto,
                  gridLinesVisibility: GridLinesVisibility.both,
                  rowHeight: 25,
                  headerRowHeight: 25,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  source: EmployeeDataSource(employees),
                  columns: [
                    GridColumn(
                      columnName: 'ID',
                      label: Container(
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GridColumn(
                      columnName: 'Name',
                      label: Container(
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text('Invoice#',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GridColumn(
                      columnName: 'Position',
                      label: Container(
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text('Type',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GridColumn(
                      columnName: 'Salary',
                      label: Container(
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text('Invoice Type',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GridColumn(
                      columnName: 'Salary',
                      label: Container(
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text('E-Status',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 50,),
                Text("${error?.length != 4 && error != null ? error : ''}"),
                Text(
                    "WARNING: ${warning?.length != 4 && warning != null ? warning : ''}"),
                Text("INFO: ${info?.length != 4 && info != null ? info : ''}"),
                Text(workingDir)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sample Employee data model
class Employee {
  final String id;
  final String name;
  final String position;
  final String salary;
  final String status;

  Employee(this.id, this.name, this.position, this.salary, this.status);
}

// Data source for the DataGrid
class EmployeeDataSource extends DataGridSource {
  final List<Employee> employees;

  EmployeeDataSource(this.employees);

  @override
  List<DataGridRow> get rows => employees
      .map(
        (employee) => DataGridRow(cells: [
          DataGridCell<String>(columnName: 'ID', value: employee.id),
          DataGridCell<String>(columnName: 'Name', value: employee.name),
          DataGridCell<String>(
              columnName: 'Position', value: employee.position),
          DataGridCell<String>(columnName: 'Salary', value: employee.salary),
          DataGridCell<String>(columnName: 'Status', value: employee.status),
        ]),
      )
      .toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          padding: EdgeInsets.all(2),
          alignment: Alignment.center,
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }
}
