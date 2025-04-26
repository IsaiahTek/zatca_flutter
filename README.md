A Flutter plugin that fully and perfectly implements with Zatca/Fatoora E-Invoicing Phase 1 & 2 requirements. It is the complete solution for creating a flutter e-invoicing desktop app (Windows & Linux) for use in Saudi Arabia.
# zatca_flutter

`zatca_flutter` is a Flutter plugin that provides seamless integration with the ZATCA (Zakat, Tax, and Customs Authority) e-invoicing system. It supports Windows and Linux environments, allowing developers to generate compliant electronic invoices efficiently.

## Features
* Setting up Business Info.
* Generating and saving CSR related files.
* Generating and saving XML files for invoices, debit notes, and credit notes.
* Generating and Displaying QR codes for invoice/note.
* Validating XML invoice/note.
* Signing and saving the signed invoices and notes.
* Generating Invoice/Note Hash Value (Typically used as PIH for next invoice)
* Generating ApiRequest for Compliance Check, Reporting and Clearance
* Generating and saving Compliance CSID and Production CSID.
* Checking invoice/note/system compliance.
* Clearing Invoice/Note.
* Reporting Invoice/Note.
* Converting and Saving Keys/Certs.
* Invoice, debit note, and credit note reporting and clearance.
<p align="center">
  <img src="https://raw.githubusercontent.com/IsaiahTek/zatca_flutter/main/images/banner.png" alt="Zatca Flutter Package Banner" />
</p>

## Installation
Add `zatca_flutter` to your `pubspec.yaml`:

Run the command below

```yaml
flutter pub add zatca_flutter
```

## Usage


### Initialization
You only have to 
The three modes acceptable are `sandbox`, `simulation`, and `production`.
Sandbox uses the developer-portal zatca server endpoint.

```dart
void main() {
    WidgetsFlutterBinding.ensureInitialized();

    // This all that is required. Switch mode as per needed.
    ZatcaFlutter.init(mode: Mode.sandbox);
    
    runApp(const App());
}
```



### Business Setup
```dart
// Just assign MyBusinessInfo model to the LocalStore `myBusinessInfo`. That automatically saves it for future reference.
LocalStore.instance.myBusinessInfo = MyBusinessInfo(
    name: _nameContr.text,
    address: _addressContr.text,
    taxId: _taxIdContr.text,
    buildingNumber: _buildingNumberContr.text,
    citySubdivision: _citySubdivisionContr.text,
    city: _cityContr.text,
    postalZone: _postalZoneContr.text,
    countryCode: _countryCodeContr.text,
    schemeID: _schemeIDContr.text,
    companyID: _companyIdContr.text,
    businessID: _businessIdContr.text
);
```
Actually, by just creating an instance of MyBusinessInfo, the business info is automatically saved and assigned to the myBusinessInfo of the LocalStore. If you are in doubt, you can still explicitly save the myBusinessInfo by calling its `save()` method which is actually called behind the scene when you just create an instance.




### CSR File Generation
```dart
CsrConfig(
    commonName: 'Your Common Name',
    serialNumber: 'SerialN',
    organizationIdentifier: '...',
    organizationUnitName:'Organization unit name',
    organizationName: 'Organization Name',
    countryName: 'Country name (SA)',
    invoiceType: 'Typically 1100',
    locationAddress: 'Business Address',
    industryBusinessCategory: 'Business Category');
```
Once an instance of `CsrConfig` is created, the `csrConfig.properties` file will automatically be save.

After creating and instance of CsrConfig file, you can await the value of the `filePath` where the file is created if you need to by just doing:
```dart
CsrConfig csrConfig = CsrConfig(
    commonName: 'Your Common Name',
    serialNumber: 'SerialN',
    organizationIdentifier: '...',
    organizationUnitName:'Organization unit name',
    organizationName: 'Organization Name',
    countryName: 'Country name (SA)',
    invoiceType: 'Typically 1100',
    locationAddress: 'Business Address',
    industryBusinessCategory: 'Business Category');

// Await the file path as shown below
String csrFilePath = await csrConfig.filePath;
```
Also, note that you could also load an already created file from the filesystem after it has been created.
```dart
CsrConfig csrConfig = await CsrConfig.load();
```


### Generate CSR file
The simplest way is to call FatooraService.generateCsr() method with the only required argument `csrConfigFile` passed in. The `outputCsrFile` and the `privateKeyFile` are optional.
```dart
FatooraServiceCsrResponse csrResponse = FatooraService.generateCsr(csrConfigFile: csrConfigFile);
```
Note: `csrConfigFile` is the file name from previous step above. See the example app for illustration or read the documentation.

The `FatooraServiceCsrResponse` has the following properties `csrOutputFileName` and `keyOutputFileName` that you can make reference to if you want to read the csr value and private key value respectively.

### Reading the Generated CSR Value and Private Key Value
Just use the utility function `getFileContentAsString(fileName)`;

Example of reading the csr value and key value from above.
```dart
String csr = getFileContentAsString(response.csrOutputFileName);
String key = getFileContentAsString(response.keyOutputFileName);
```


### Requesting CCSID from Zatca
```dart
CCSIDRequestProp prop = CCSIDRequestProp(csr: csr, otp: otp);
ComplianceCSIDResponse ccsidResponse = await ZatcaFlutter.request.requestComplianceCSID(request: prop);
```
See the documentation for properties of the `ComplianceCSIDResponse`

### Requesting PCSID from Zatca
For you to request PCSID you must have first done the CCSID request. Then do the following:

```dart
ProductionCSIDResponse response = await ZatcaFlutter.request.requestProductionCSIDOnboarding();
```
See the documentation for properties of the `ProductionCSIDResponse`

### Save the Returned Token and Key
After requesting for CCSID, if the request was successful, a binary token and a key will be returned. You can save it by doing the following:
```dart
request.convertTokenAndKeyToPemAndSaveToSDKForSigning(certAndKey: CertAndKey(cert: ccsidResponse.successData, key: key))
```
After the above steps have been completed, you can then follow the following steps for regular processes.

### Generating An Invoice/Note
There are two types of Invoices. These are `SimplifiedInvoice` and `StandardInvoice`.
There are two types of Notes. These are `Credit Note` and `Debit Note`. Each of these types of notes could either be `Simplified` or `Standard`. So that makes it a total of 6 major types of xml files you can generate with `zatca_flutter` package.
Example:
```dart
// Create the invoice object
SimplifiedInvoice simplifiedInvoice = SimplifiedInvoice(
    icv: 1,
    pih:'', // Pass in an empty string like this if this is your first invoice. Otherwise, pass in the actual PIH (Previous Invoice Hash)
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
                taxableAmount:'64',
                code: TaxCategoryCode.standard, // Ensure taxable amount matches total
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
        taxExclusiveAmount: "64", // Same as lineExtensionAmount
        taxInclusiveAmount: "73.60", // taxExclusiveAmount + total VAT
        payableAmount: "73.60", // Final payable amount
        allowanceTotalAmount: 0.0,
        prepaidAmount: 0.0
    ),
);

simplifiedInvoice.generateAndSaveXml('simple_invoice.xml');   // Generate and save the invoice xml data from the invoice object

```


### Signing An Invoice/Note
Signing an invoice requires using the necessary certificate. But you don't need to worry about that since the plugin handles that for you. However, you need to specify if the signing you are doing is for checks or not by passing in `isForComplianceCheck:true` if you want to use it for local (fatoora) validation check or server (zatca) compliance check.
If you want to use the signed document for reporting (as required for Simplified Invoice/Note reporting) then you might omit the `isForComplianceCheck` or explicitly indicate it's for reporting by passing in `isForComplianceCheck:false` to the `FatooraService.signInvoice()` method.
Example:
```dart
// Sign the invoice if it's Simplified (B2C)
FatooraServiceResponse signRes = await FatooraService.signInvoice(invoiceFileName: 'simple_invoice.xml', isForComplianceCheck: true);
// The signed invoice for the above will be simple_invoice_signed.xml
```
Note: if you do not specify the `outputSignedInvoiceFileName`, the signed invoice will have the name of the original invoice above with `_signed.xml` added as the last part.


### Generating Invoice RequestAPI `FatooraService.generateInvoiceRequestAPI`
Invoice/Note request API is the JSON data format that consist of `uuid`, `invoiceHash` and `invoice` data and is required for invoice/note compliance check, reporting, and clearance.
If you want to generate the request API for clearance, you should pass in `forClearance:true` to the `FatooraService.generateInvoiceRequestAPI()` method. Otherwise, the plugin assumes you are generating the request API for reporting.

See the documentation or example app for more usage.


## Sponsorship
Please support us to keep maintaining this package if you find it useful and love helping. Thanks

## Contributing
If you are interested in contributing to this package reach-out to me via GitHub.

## Connect With the Author
Engineer Isaiah Pius E.
I am pleased to have you use this package.
You can reach-out to me via my GitHub, Email and Linked. See my GitHub page for relevant connection links.
Thanks once again.