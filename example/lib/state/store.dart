import 'package:flutter/material.dart';
import 'package:zatca_flutter/model/api/compliance_csid_response.dart';
import 'package:zatca_flutter/model/api/csr_request.dart';
import 'package:zatca_flutter/model/api/pcsid_request_prop.dart';
import 'package:zatca_flutter/model/api/production_csid_response.dart';
import 'package:zatca_flutter/model/cert_and_key.dart';
import 'package:zatca_flutter/request.dart';
import 'package:zatca_flutter/model/fatoora_service_response.dart';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/service/fatoora_service.dart';
import 'package:zatca_flutter/zatca_flutter.dart';

class Controller{
  Controller._();
  static Controller? _instance;
  static Controller get instance => _instance ??= Controller._();

  /// Storing CSR content value. NOTE: This is not file path.
  String? csr;

  // Private Key from CSR generation
  String? key;

  // Request prop for CCSID
  CCSIDRequestProp? ccsidRequestProp;

  // API Request prop for Compliance Check
  InvoiceRequest? invoiceRequest;

  ComplianceSuccessData? ccsidData;

  ProductionCSIDSuccessData? pcsidData;

  RequestBase request = ZatcaFlutter.request;

  Future<FatooraServiceCsrResponse> generateCsr({
  required String csrConfigFile,
  String? privateKeyFile,
  String? outputCsrFile,
}){
    return FatooraService.generateCsr(csrConfigFile: csrConfigFile, outputCsrFile: outputCsrFile, privateKeyFile:  privateKeyFile);
  }

  Future<void> generateInvoiceRequest(String invoiceFileName, String? jsonOutputFile)async{
    FatooraService.generateInvoiceRequestAPI(invoiceFileName: invoiceFileName, outputJsonFileName: jsonOutputFile);
  }

  Future<ComplianceCSIDResponse> makeCCSIDRequest(CCSIDRequestProp prop)async{
    debugPrint("REQUEST MODE WHILE MAKING CCSID Request ${request.mode.name}");
    ComplianceCSIDResponse response = await request.requestComplianceCSID(request: prop);
    ccsidData = response.successData;
    if(response.errorData != null && response.errorData!.errors.isNotEmpty) debugPrint("ERROR REQUESTING CCSID ${response.errorData?.errors.toString()}");
    if(response.failureData != null) debugPrint("FAILURE REQUESTING CCSID ${response.failureData?.message} ${response.failureData?.toJson()}");
    return response;
  }

  Future<void> checkCompliance(ComplianceSuccessData auth, InvoiceRequest requestProp)async{
    request.requestComplianceCheck(prop: requestProp);
  }

  Future<ProductionCSIDResponse> makePCSIDRequest(PCSIDRequestProp prop)async{
    ProductionCSIDResponse response = await request.requestProductionCSIDOnboarding();
    pcsidData = response.successData;
    return response;
  }

  Future<void> getCertAndSaveForSigning({required CertAndKey certAndKey})async{
    return request.convertTokenAndKeyToPemAndSaveToSDKForSigning(certAndKey: certAndKey);
  }

}