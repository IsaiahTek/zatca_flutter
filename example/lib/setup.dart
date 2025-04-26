import 'package:einvoice/state/store.dart';
import 'package:einvoice/tfield.dart';
import 'package:flutter/material.dart';
import 'package:zatca_flutter/enums.dart';
import 'package:zatca_flutter/local_store.dart';
import 'package:zatca_flutter/model/api/compliance_invoice_response.dart';
import 'package:zatca_flutter/model/api/csr_request.dart';
import 'package:zatca_flutter/model/api/pcsid_request_prop.dart';
import 'package:zatca_flutter/model/cert_and_key.dart';
import 'package:zatca_flutter/model/csr_config.dart';
import 'package:zatca_flutter/model/fatoora_invoice_request_api_response.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';
import 'package:zatca_flutter/model/my_business_info.dart';
import 'package:zatca_flutter/model/xml/invoice_line.dart';
import 'package:zatca_flutter/model/xml/legal_monetary_total.dart';
import 'package:zatca_flutter/model/xml/party.dart';
import 'package:zatca_flutter/model/xml/simplified_invoice.dart';
import 'package:zatca_flutter/model/xml/tax_details.dart';
import 'package:zatca_flutter/service/fatoora_service.dart';
import 'package:zatca_flutter/service/util.dart';

class Setup extends StatefulWidget {
  const Setup({super.key});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final TextEditingController _nameContr =
      TextEditingController(text: LocalStore.instance.myBusinessInfo?.name);
  final TextEditingController _addressContr =
      TextEditingController(text: LocalStore.instance.myBusinessInfo?.address);
  final TextEditingController _taxIdContr =
      TextEditingController(text: LocalStore.instance.myBusinessInfo?.taxId);
  final TextEditingController _buildingNumberContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.buildingNumber);
  final TextEditingController _citySubdivisionContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.citySubdivision);
  final TextEditingController _cityContr =
      TextEditingController(text: LocalStore.instance.myBusinessInfo?.city);
  final TextEditingController _postalZoneContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.postalZone);
  final TextEditingController _countryCodeContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.countryCode);
  final TextEditingController _schemeIDContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.schemeID.toString());
  final TextEditingController _companyIdContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.companyID);
  final TextEditingController _businessIdContr = TextEditingController(
      text: LocalStore.instance.myBusinessInfo?.businessID);

  final TextEditingController _commonNameController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _orgIdController = TextEditingController();
  final TextEditingController _orgUnitNameController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _countryNameController = TextEditingController();
  final TextEditingController _invoiceTypeController = TextEditingController();
  final TextEditingController _locationAddressController =
      TextEditingController();
  final TextEditingController _industryBusinessCategoryController =
      TextEditingController();

  final TextEditingController _generatedCsrController = TextEditingController();
  final TextEditingController _privateKeyController = TextEditingController();

  Controller controller = Controller.instance;

  void fetchAndUpdateFields() {
    CsrConfig.load().then((csr) {
      _commonNameController.text = csr?.commonName ?? "";
      _serialNumberController.text = csr?.serialNumber ?? "";
      _orgIdController.text = csr?.organizationIdentifier ?? "";
      _orgUnitNameController.text = csr?.organizationUnitName ?? "";
      _orgNameController.text = csr?.organizationName ?? "";
      _countryNameController.text = csr?.countryName ?? "";
      _invoiceTypeController.text = csr?.invoiceType ?? "";
      _locationAddressController.text = csr?.locationAddress ?? "";
      _industryBusinessCategoryController.text =
          csr?.industryBusinessCategory ?? "";
    });

    getFileContentAsString("outputCsrFile.csr").then((w) {
      _generatedCsrController.text = w ?? "";
    });

    getFileContentAsString("privateKeyFile.key").then((v) {
      _privateKeyController.text = v ?? "";
    });
  }

  TextEditingController otpController = TextEditingController();
  TextEditingController ccsidBinarySecurityTokenController =
      TextEditingController(text: LocalStore.instance.ccsid?.token);
  TextEditingController ccsidSecretController =
      TextEditingController(text: LocalStore.instance.ccsid?.secret);
  TextEditingController ccsidRequestIdController = TextEditingController(
      text: LocalStore.instance.ccsid?.requestID.toString());

  TextEditingController pcsidBinarySecurityTokenController =
      TextEditingController(text: LocalStore.instance.pcsid?.token);
  TextEditingController pcsidSecretController =
      TextEditingController(text: LocalStore.instance.pcsid?.secret);
  TextEditingController pcsidRequestIdController = TextEditingController(
      text: LocalStore.instance.pcsid?.requestID.toString());

  @override
  void initState() {
    fetchAndUpdateFields();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (tabControllercontext) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              // TabBar at the top
              Container(
                color: Colors.blueGrey[500], // Background color for the TabBar
                child: TabBar(
                  indicatorColor:
                      Colors.blueGrey[900], // Highlight indicator color
                  labelColor: Colors.white,

                  // Selected tab label color
                  unselectedLabelColor:
                      Colors.white70, // Unselected tab label color
                  tabs: [
                    Tab(
                      text: 'Business Info',
                    ),
                    Tab(
                      text: 'CSR Configuration',
                    ),
                    Tab(
                      text: 'Register Device',
                    ),
                  ],
                ),
              ),
              // TabBarView for content
              Expanded(
                child: TabBarView(
                  children: [
                    Container(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tfield(
                            label: 'Registration Name',
                            width: 830,
                            controller: _nameContr,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'Comapany ID',
                                width: 200,
                                controller: _companyIdContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'Tax Scheme ID',
                                hint: 'VAT',
                                width: 200,
                                controller: _taxIdContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'Business Identification ID',
                                width: 200,
                                controller: _businessIdContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'Scheme ID',
                                width: 200,
                                hint: 'CRN',
                                controller: _schemeIDContr,
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Tfield(
                            label: 'Street Name',
                            width: 830,
                            controller: _addressContr,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'City Subdivision Name',
                                width: 410,
                                controller: _citySubdivisionContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'City Name',
                                width: 410,
                                controller: _cityContr,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'Building Number',
                                width: 200,
                                controller: _buildingNumberContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'Postal Zone',
                                hint: '',
                                width: 200,
                                controller: _postalZoneContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'Country Identification Code',
                                width: 200,
                                hint: 'SA',
                                controller: _countryCodeContr,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'Business Category',
                                width: 200,
                                hint: '',
                                controller: _industryBusinessCategoryController,
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                LocalStore.instance.myBusinessInfo =
                                    MyBusinessInfo(
                                        name: _nameContr.text,
                                        address: _addressContr.text,
                                        taxId: _taxIdContr.text,
                                        buildingNumber:
                                            _buildingNumberContr.text,
                                        citySubdivision:
                                            _citySubdivisionContr.text,
                                        city: _cityContr.text,
                                        postalZone: _postalZoneContr.text,
                                        countryCode: _countryCodeContr.text,
                                        schemeID: _schemeIDContr.text,
                                        companyID: _companyIdContr.text,
                                        businessID: _businessIdContr.text);
                              },
                              child: Text("Save & Next"))
                        ],
                      ),
                    ),
                    Center(
                        child: Container(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Tfield(
                                label: 'CSR Industry Business Category',
                                width: 200,
                                controller: _industryBusinessCategoryController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Common Name',
                                hint: '',
                                width: 200,
                                controller: _commonNameController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Serial Number',
                                width: 410,
                                hint: '',
                                controller: _serialNumberController,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'CSR Organization Identifier',
                                width: 200,
                                controller: _orgIdController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Organization Unit Name',
                                hint: '',
                                width: 200,
                                controller: _orgUnitNameController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Organization Name',
                                width: 410,
                                hint: '',
                                controller: _orgNameController,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'CSR Country',
                                width: 200,
                                controller: _countryNameController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Invoice Type',
                                hint: '',
                                width: 200,
                                controller: _invoiceTypeController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Location Address',
                                width: 200,
                                hint: '',
                                controller: _locationAddressController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                label: 'CSR Environment Type',
                                width: 200,
                                hint: '',
                                // controller:,
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    CsrConfig csrConfig = CsrConfig(
                                        commonName:
                                            _commonNameController.value.text,
                                        serialNumber:
                                            _serialNumberController.text,
                                        organizationIdentifier:
                                            _orgIdController.value.text,
                                        organizationUnitName:
                                            _orgUnitNameController.text,
                                        organizationName:
                                            _orgNameController.text,
                                        countryName:
                                            _countryNameController.text,
                                        invoiceType:
                                            _invoiceTypeController.text,
                                        locationAddress:
                                            _locationAddressController.text,
                                        industryBusinessCategory:
                                            _industryBusinessCategoryController
                                                .text);

                                    String? filePath = await csrConfig.filePath;
                                    debugPrint(
                                        "Done Creating the csrConfig File $filePath");
                                    FatooraServiceCsrResponse response =
                                        await controller.generateCsr(
                                            csrConfigFile: filePath,
                                            privateKeyFile:
                                                "privateKeyFile.key",
                                            outputCsrFile: "outputCsrFile.csr");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "${response.response.status.name.toUpperCase()} for Generated files: (${response.csrOutputFileName.toString()} and ${response.keyOutputFileName})")));
                                    controller.csr =
                                        await getFileContentAsString(
                                            response.csrOutputFileName);
                                    _generatedCsrController.text =
                                        controller.csr.toString();
                                    if (response.response.warnings != null &&
                                        response.response.warnings!.isNotEmpty)
                                      debugPrint(
                                          "ERROR @ CSR GENERATION: ${response.response.warnings?.map((e) => e.message)}");
                                    _privateKeyController.text =
                                        (await getFileContentAsString(
                                                response.keyOutputFileName)) ??
                                            "";
                                  },
                                  child: Text('Generate CSR'))
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'Generated CSR',
                                width: 830,
                                minline: 5,
                                // readOnly: true,
                                controller: _generatedCsrController,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label:
                                    'Generated ES Secp256k1 Private Key (PEM)',
                                width: 830,
                                // readOnly: true,
                                minline: 4,
                                controller: _privateKeyController,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    debugPrint(
                                        "NEW VALUE BEFORE CCSID REQ: ${_generatedCsrController.text}");
                                    controller.csr =
                                        _generatedCsrController.text;
                                    DefaultTabController.of(
                                            tabControllercontext)
                                        .animateTo(2);
                                  },
                                  child: Text("Next")),
                            ],
                          )
                        ],
                      ),
                    )),
                    Container(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Tfield(
                                width: 200,
                                label: 'CCSID OTP',
                                controller: otpController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    CCSIDRequestProp prop = CCSIDRequestProp(
                                        csr: controller.csr ?? "",
                                        otp: otpController.text);

                                    await controller.makeCCSIDRequest(prop);

                                    if (controller.ccsidData != null) {
                                      ccsidSecretController.text =
                                          controller.ccsidData?.secret ?? "";
                                      ccsidBinarySecurityTokenController.text =
                                          controller.ccsidData
                                                  ?.binarySecurityToken ??
                                              "";
                                      ccsidRequestIdController.text = controller
                                              .ccsidData?.requestID
                                              .toString() ??
                                          "";
                                    }
                                  },
                                  child: Text('Get CCSID'))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'CCSID Binary Token',
                                controller: ccsidBinarySecurityTokenController,
                                readOnly: true,
                                width: 820,
                                minline: 3,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Tfield(
                                width: 300,
                                label: 'Token Secret',
                                readOnly: true,
                                controller: ccsidSecretController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                width: 300,
                                label: 'Request ID',
                                readOnly: true,
                                controller: ccsidRequestIdController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await controller.makePCSIDRequest(
                                        PCSIDRequestProp(
                                            binarySecurityToken: controller
                                                    .ccsidData
                                                    ?.binarySecurityToken ??
                                                "",
                                            requestId: controller
                                                    .ccsidData?.requestID
                                                    .toString() ??
                                                "",
                                            secret:
                                                controller.ccsidData?.secret ??
                                                    ""));
                                    pcsidBinarySecurityTokenController.text =
                                        controller.pcsidData
                                                ?.binarySecurityToken ??
                                            "";
                                    pcsidRequestIdController.text = controller
                                            .pcsidData?.requestID
                                            .toString() ??
                                        "";
                                    pcsidSecretController.text =
                                        controller.pcsidData?.secret ?? "";
                                  },
                                  child: Text('Get PCSID'))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Tfield(
                                label: 'PCSID Binary Token',
                                width: 820,
                                minline: 3,
                                readOnly: true,
                                controller: pcsidBinarySecurityTokenController,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Tfield(
                                width: 300,
                                label: 'PCSID Secret',
                                readOnly: true,
                                controller: pcsidSecretController,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Tfield(
                                width: 300,
                                label: 'Request Date',
                                readOnly: true,
                                controller: pcsidRequestIdController,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    await controller.getCertAndSaveForSigning(
                                        certAndKey: CertAndKey(
                                            cert:
                                                ccsidBinarySecurityTokenController
                                                    .text,
                                            key: _privateKeyController.text));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Downloaded and saved! You can start signing invoices/debit notes/credit notes")));

                                    SimplifiedInvoice simplifiedInvoice =
                                        SimplifiedInvoice(
                                      icv: 1,
                                      pih: '',
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
                                        amount:
                                            "9.60", // Sum of line-level tax amounts
                                        percent: "15",
                                        currency: 'SAR',
                                        taxableAmount: '64',
                                        code: TaxCategoryCode
                                            .standard, // Total taxable amount
                                      ),
                                      monetaryTotal: LegalMonetaryTotal(
                                          lineExtensionAmount:
                                              "64", // Sum of line totals
                                          taxExclusiveAmount:
                                              "64", // Same as lineExtensionAmount
                                          taxInclusiveAmount:
                                              "73.60", // taxExclusiveAmount + total VAT
                                          payableAmount:
                                              "73.60", // Final payable amount
                                          allowanceTotalAmount: 0.0,
                                          prepaidAmount: 0.0),
                                    );

                                    simplifiedInvoice.generateAndSaveXml(
                                        'simple_invoice.xml');

                                    FatooraServiceResponse signRes =
                                        await FatooraService.signInvoice(
                                            invoiceFileName:
                                                'simple_invoice.xml',
                                            isForComplianceCheck: true);
                                    debugPrint(
                                        "SIGNATURE (${signRes.status.name.toUpperCase()}): ${signRes.infos?.map((d) => d.message)}");

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

                                    FatooraServiceResponse validationRes =
                                        await FatooraService.validateInvoice(
                                            invoiceFileName:
                                                'simple_invoice_signed.xml',
                                            ignoreWarningForResponseStatus:
                                                true);
                                    debugPrint(
                                        "VALIDATION (${validationRes.status.name.toUpperCase()}): SUCCESS (${validationRes.infos?.length}); FAILURE (${validationRes.errors?.length}) WARNING (${validationRes.warnings?.length}) ${validationRes.infos?.map((d) => d.message)}");

                                    FatooraInvoiceRequestApiResponse
                                        invoiceApi = await FatooraService
                                            .generateInvoiceRequestAPI(
                                                invoiceFileName:
                                                    'simple_invoice_signed.xml');
                                    // debugPrint("INVOICE API: ${invoiceApi.invoiceRequest?.toMap()}");
                                    ComplianceInvoiceCheckResponse? res =
                                        await controller.request
                                            .requestComplianceCheck(
                                                prop:
                                                    invoiceApi.invoiceRequest!);

                                    debugPrint(
                                        "RESULT FROM CHECKS ${res?.statusCode} ${res?.reportingStatus} ${res?.validationResults?.infoMessages?.map((d) => d.toJson())}");
                                  },
                                  child:
                                      Text('Register & Download Certificate'))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
