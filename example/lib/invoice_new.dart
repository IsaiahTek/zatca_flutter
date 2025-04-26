import 'package:einvoice/state/store.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/model/api/compliance_invoice_response.dart';
import 'package:zatca_flutter/model/fatoora_invoice_request_api_response.dart';
import 'package:zatca_flutter/model/fatoora_qr_code_response.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/model/xml/simplified_invoice.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/qr_code/widget/qr_code_image.dart';
import 'package:zatca_flutter/service/fatoora_service.dart';
import 'package:zatca_flutter/service/util.dart';

class InvoiceNew extends StatefulWidget {
  const InvoiceNew({super.key});

  @override
  State<InvoiceNew> createState() => _InvoiceNewState();
}

class _InvoiceNewState extends State<InvoiceNew> {
  String? base64EncodedQrCode;
  String? xml;
  String? responseStatus;

  @override
  Widget build(BuildContext context) {
    String? invoiceTypeSelected;
    final List<Employee> employees = [
      Employee('12001', 'SKECHERS SHOES', '1', '100.00', '115.00', '0', '0',
          '115.00'),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 28,
                    width: 220,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(4)),
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: true,
                      underline: SizedBox(),
                      value: invoiceTypeSelected,
                      hint: Text('Type'),
                      onChanged: (String? newValue) {
                        setState(() {
                          invoiceTypeSelected = newValue;
                        });
                      },
                      items: <String>['Invoice', 'Debit Note', 'Credit Note']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 28,
                    width: 220,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(4)),
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: true,
                      underline: SizedBox(),
                      value: invoiceTypeSelected,
                      hint: Text('Invoice Type'),
                      onChanged: (String? newValue) {
                        setState(() {
                          invoiceTypeSelected = newValue;
                        });
                      },
                      items: <String>['Tax Invoice', 'Simplified Tax Invoice']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 28,
                    width: 220,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(4)),
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: true,
                      underline: SizedBox(),
                      value: invoiceTypeSelected,
                      hint: Text('Payment Mode'),
                      onChanged: (String? newValue) {
                        setState(() {
                          invoiceTypeSelected = newValue;
                        });
                      },
                      items: <String>['Credit Card', 'Cash']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    width: 220,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Dr/Cr note agaist Invoice#'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 28,
                    width: 220,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(4)),
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: true,
                      underline: SizedBox(),
                      value: invoiceTypeSelected,
                      hint: Text('Select Customer'),
                      onChanged: (String? newValue) {
                        setState(() {
                          invoiceTypeSelected = newValue;
                        });
                      },
                      items: <String>['Credit Card', 'Cash']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 28,
                    width: 220,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(4)),
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: true,
                      underline: SizedBox(),
                      value: invoiceTypeSelected,
                      hint: Text('Submit Type'),
                      onChanged: (String? newValue) {
                        setState(() {
                          invoiceTypeSelected = newValue;
                        });
                      },
                      items: <String>['Developer', 'Simulation', 'Production']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    width: 220,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Notes'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.blueGrey,
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 100,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Product Id'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 230,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Product Name'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 80,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Qty'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 100,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Price'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 100,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Price WT'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 100,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Discount%'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 150,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Discount Amnt'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 100,
                    color: Colors.white,
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                          isDense: true,
                          label: Text('Total'),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          responseStatus = "Processing...";
                          xml = "Processing...";
                          base64EncodedQrCode = "Processing...";
                        });

                        // Create the invoice object
                        SimplifiedInvoice simplifiedInvoice = SimplifiedInvoice(
                          icv: 1,
                          pih:
                              '', // Pass in an empty string like this if this is your first invoice. Otherwise, pass in the actual PIH (Previous Invoice Hash)
                          id: "INV-001",
                          uuid: generateUuid(),
                          issueDate: DateTime.now(),
                          issueTime: DateTime.now(),
                          currency: 'SAR',
                          customer: IndividualParty(
                            name: "Elizabeth",
                            taxId: "310298993344553",
                            address: "address 3az",
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
                                taxableAmount: '64',
                                code: TaxCategoryCode
                                    .standard, // Ensure taxable amount matches total
                              ),
                              name: 'Garri',
                            )
                          ],
                          tax: TaxDetails(
                            amount: "9.60", // Sum of line-level tax amounts
                            percent: "15",
                            currency: 'SAR',
                            taxableAmount: '64',
                            code: TaxCategoryCode
                                .standard, // Total taxable amount
                          ),
                          monetaryTotal: LegalMonetaryTotal(
                              lineExtensionAmount: "64", // Sum of line totals
                              taxExclusiveAmount:
                                  "64", // Same as lineExtensionAmount
                              taxInclusiveAmount:
                                  "73.60", // taxExclusiveAmount + total VAT
                              payableAmount: "73.60", // Final payable amount
                              allowanceTotalAmount: 0.0,
                              prepaidAmount: 0.0),
                        );

                        simplifiedInvoice.generateAndSaveXml(
                            'simple_invoice.xml'); // Generate and save the invoice xml data from the invoice object

                        // Sign the invoice if it's Simplified (B2C)
                        FatooraServiceResponse signRes =
                            await FatooraService.signInvoice(
                                invoiceFileName: 'simple_invoice.xml',
                                isForComplianceCheck: true);

                        // Get the XML of the signed invoice
                        xml = await getFileContentAsString(
                            'simple_invoice_signed.xml');
                        setState(() {
                          xml;
                        });

                        // Get the QR Code from the signed invoice
                        FatooraQrCodeResponse qrCodeResponse =
                            await FatooraService.generateInvoiceQRCode(
                                'simple_invoice_signed.xml');

                        setState(() {
                          base64EncodedQrCode = qrCodeResponse.qrCode;
                        });

                        debugPrint(
                            "SIGNATURE (${signRes.status.name.toUpperCase()}): ${signRes.infos?.map((d) => d.message)}");

                        // Validate signed invoice locally before doing compliance check, reporting or clearance
                        FatooraServiceResponse validationRes =
                            await FatooraService.validateInvoice(
                                invoiceFileName: 'simple_invoice_signed.xml',
                                ignoreWarningForResponseStatus: true);

                        debugPrint(
                            "VALIDATION (${validationRes.status.name.toUpperCase()}): SUCCESS (${validationRes.infos?.length}); FAILURE (${validationRes.errors?.length}) WARNING (${validationRes.warnings?.length}) ${validationRes.infos?.map((d) => d.message)}");

                        // Generate the Request API for compliance check, reporting or clearance
                        FatooraInvoiceRequestApiResponse invoiceApi =
                            await FatooraService.generateInvoiceRequestAPI(
                                invoiceFileName: 'simple_invoice_signed.xml');

                        // debugPrint("INVOICE API: ${invoiceApi.invoiceRequest?.toMap()}");

                        // Check compliance on zatca server.
                        ComplianceInvoiceCheckResponse? res = await Controller
                            .instance.request
                            .requestComplianceCheck(
                                prop: invoiceApi.invoiceRequest!);

                        if (res?.status != null) {
                          setState(() {
                            responseStatus =
                                "${res?.clearanceStatus ?? res?.reportingStatus ?? res?.status.name.toUpperCase()}\n\n${res?.validationResults?.toJson()}";
                          });
                        }
                      },
                      child: Text('Add')),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(border: Border.all(width: 0.3)),
                      child: SfDataGrid(
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
                              child: Text('Product ID',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Name',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text('Product Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Position',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text(' Qty',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Salary',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text('Price',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Salary',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text('Price WT',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Position',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text('Discount%',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Salary',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text('Discount Amnt',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: 'Salary',
                            label: Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text('Total',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sub total : 120.00'),
                      Text('Discount : 20.00'),
                      Text('VAT : 15.00'),
                      Text('Total : 115.00')
                    ],
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(width: 0.3)),
                    width: 350,
                    height: 200,
                    child: SingleChildScrollView(
                        child: Text(responseStatus ?? 'Respose here..')),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(width: 0.3)),
                    width: 450,
                    height: 200,
                    child: SingleChildScrollView(
                        child: Text(xml ?? 'Invoice XML here... ')),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(width: 0.3)),
                    width: 200,
                    height: 200,
                    child: base64EncodedQrCode != null
                        ? base64EncodedQrCode == "Processing..."
                            ? Text("Processing...")
                            : QrCodeImage(
                                base64EncodedQrCode: base64EncodedQrCode!)
                        : Center(child: Text('Qr Code')),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Save')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String position;
  final String salary;
  final String status;
  final String a;
  final String b;
  final String c;

  Employee(this.id, this.name, this.position, this.salary, this.status, this.a,
      this.b, this.c);
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
          DataGridCell<String>(columnName: 'Positi', value: employee.a),
          DataGridCell<String>(columnName: 'Sala', value: employee.b),
          DataGridCell<String>(columnName: 'Stat', value: employee.c),
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
