## 0.1.6
FIXED: RoundingAmount floating number appearing as a very long value is fixed to have only 2 decimal places.

## 0.1.5
FIXED: InvoiceTypeCode element build issue fixed.

## 0.1.4
- Updated InvoiceTypeCode to match actual values for compliance.
- Added InvoiceTypeCode class with factory methods for easily composing custom InvoiceTypeCode with arbitary values if needed.
```
Represents the `<cbc:InvoiceTypeCode>` element in a ZATCA-compliant UBL invoice.

The element consists of:
- A numeric `code` (UN/CEFACT 1001 subset):
  - `388` = Tax invoice
  - `381` = Credit note
  - `383` = Debit note
  - `386` = Prepayment invoice

- A `name` attribute: a 7-character string (`NNPNESB`) that encodes invoice subtype & flags:
  1–2. `NN` = Subtype (`01` = Standard, `02` = Simplified)
  3.   `P`  = 3rd-party (0/1)
  4.   `N`  = Nominal (0/1)
  5.   `E`  = Export (0/1)
  6.   `S`  = Summary (0/1)
  7.   `B`  = Self-billed (0/1)

```
Example:
Passing in the one of the below to any Invoice would build the associated InvoiceTypeCode
```dart
InvoiceTypeCode.standardTaxInvoice()    // Factory utility

// or 
InvoiceTypeCode(code: '388', type: '0100000')   // Object Constructor

```
Produces the below:
```xml
<cbc:InvoiceTypeCode name="0100000">388</cbc:InvoiceTypeCode>
```

## 0.1.3
Updated simplified credit note xml file creation to not check for supplier info.

## 0.1.2
Minor update    <!-- dart format -->


## 0.1.0
Added the file name of the cleared invoice to the Cleared invoice response model.
Added Cleared Invoice Service for extracting the QR Code and Invoice Hash of the cleared invoice.
Removed Invoice Hash from the Cleared Invoice response model in favour of Cleared Invoice Service getInvoiceHash Method.