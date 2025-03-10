A Flutter plugin that integrates perfectly with Zatca/Fatoora E-Invoicing Phase 1 & 2 requirements. It is the complete solution for creating a flutter e-invoicing desktop app (Windows & Linux) for use in Saudi Arabia.

# zatca_flutter

`zatca_flutter` is a Flutter plugin that provides seamless integration with the ZATCA (Zakat, Tax, and Customs Authority) e-invoicing system. It supports Windows and Linux environments, allowing developers to generate compliant electronic invoices efficiently.

## Features
- Generating QR codes and CSR related files.
- Generating and validating XML invoices, debit notes, and credit notes.
- Signing and hashing invoices.
- Generating Compliance CSID and Production CSID.
- Checking compliance.
- Invoice, debit note, and credit note reporting and clearance.

## Installation
Add `zatca_flutter` to your `pubspec.yaml`:

Run the command below

```yaml
flutter pub add zatca_flutter
```

## Usage
### Signing An Invoice/Note
Signing an invoice requires using the necessary certificate. But you don't need to worry about that since the plugin handles that for you. However, you need to specify if the signing you are doing is for checks or not by passing in `forChecks:true` if you want to use it for local (fatoora) validation check or server (zatca) compliance check.
If you want to use the signed document for reporting (as required for Standard Invoice/Note reporting) then you might omit the `forChecks` or explicitly indicate it's for reporting by passing in `forChecks:false` to the `FatooraService.signInvoice()` method.

### Generating Invoice RequestAPI `FatooraService.generateInvoiceRequestAPI`
Invoice/Note request API is the JSON data format that consist of `uuid`, `invoiceHash` and `invoice` data and is required for invoice/note compliance check, reporting, and clearance.
If you want to generate the request API for clearance, you should pass in `forClearance:true` to the `FatooraService.generateInvoiceRequestAPI()` method. Otherwise, the plugin assumes you are generating the request API for reporting.


## Contributing
For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
