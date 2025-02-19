import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:zatca_flutter/model/fatoora_invoice_request_api_response.dart';
import 'package:zatca_flutter/model/fatoora_qr_code_response.dart';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/service/util.dart';

import '../model/error_model.dart';
import '../model/info_model.dart';
import 'fatoora_service_finder.dart';

import '../enums.dart';
import '../model/fatoora_service_response.dart';
import 'fatoora_service_response_parser.dart';
import 'package:flutter/material.dart';

class FatooraService {
  static final String? _fatooraPath = FatooraServiceFinder.instance.path;

  /// Runs a Fatoora CLI command and returns the result
  static Future<FatooraServiceResponse> _runCommand(List<String> args) async {
    try {
      if (_fatooraPath != null) {
        String workingDirectory = await getStorageFolderPath();
        ProcessResult result = await Process.run(_fatooraPath!, args,
            workingDirectory: workingDirectory);

        FatooraServiceResponse response =
            FatooraServiceResponseParser.extractResponses(result.stdout);
        debugPrint("RESPONSE STATUS: ${response.status.name.toUpperCase()}");
        if (response.status == ResponseStatus.failure) {
          logError(
              "ZATCA/Fatoora Execution Failed (${response.errors?.length}):");
          for (ErrorModel element in response.errors ?? []) {
            logError("ZATCA/Fatoora ${element.source}: ${element.message}");
          }
          String? errors = response.errors
              ?.map((d) => "${d.source}: ${d.message}")
              .join("\n");
          _writeLogToFile("ERRORS:\n$errors");
        } else {
          log("\x1B[32m ZATCA/Fatoora (${args.first}) Execution Successful(${response.infos?.length ?? 0}), Warning(${response.warnings?.length ?? 0}):");
          for (InfoModel element in response.infos ?? []) {
            log("\x1B[34mZATCA/Fatoora ${element.source}: ${element.message}");
          }
        }

        return response;
      } else {
        _writeLogToFile(
            "FATOORA PATH WASN'T FOUND. Set the path manually if you've already installed zatca/fatoora. Or install it and restart the application");
        throw Exception(
            "FATOORA PATH WASN'T FOUND. Set the path manually if you've already installed zatca/fatoora. Or install it and restart the application");
      }
    } catch (e) {
      _writeLogToFile("Error running Fatoora CLI: $e");
      throw Exception("Error running Fatoora CLI: $e");
    }
  }

  static _writeLogToFile(String message) async {
    String? storagePath = await getStorageFolderPath();
    File logFile = File(
        "$storagePath${Platform.pathSeparator}fatoora-error-${DateTime.now()}.log");
    logFile.writeAsStringSync(message);
  }

  static String? _getNewFileName({required List<String> before, required List<String> after}){
    for (var fileName in after) {
      if (!before.contains(fileName)) {
        return fileName;
      }
    }
    return null;
  }

  /// This method generates a CSR file using Fatoora CLI
  /// Note: Because providing file name for generated private key and csr file makes the result not accurate, we have disabled it and used a work-aroud for providing the name of the generated csr and key files accordingly in a way that is more reliable. That means you can provide what you want the generated csr and key file to be named and it will be renamed to those you provide.
  ///
  /// More importantly, ensure you don't alter the sdk folder structure of fatoora.
  /// The package updates the cert and key file contents each time you call this method.
  /// This is to eliminate manual update as required by the SDK documentation
  ///
  /// The method returns a Future of `FatooraServiceCsrResponse` which includes:
  /// ```
  /// FatooraServiceResponse response;
  /// String csrOutputFileName;
  /// String keyOutputFileName;
  /// ```
  ///
  /// The `FatooraServiceResponse` is a model composed of:
  /// ```
  /// ResponseStatus status;
  /// List<ErrorModel>? errors;
  /// List<WarningModel>? warnings;
  /// List<InfoModel>? infos;
  /// ```
  /// Which contains a list of errors/warnings/infos if present otherwise null.
  /// For more information, read the documentation.
  static Future<FatooraServiceCsrResponse> generateCsr(
      {required String csrConfigFile,
      String? privateKeyFile,
      String? outputCsrFile,
      bool getPem = false,
      bool isForSimulation = false,
      bool isForNoneProduction = false}) async {
    String csrFolder = await getStorageFolderPath();
    List<String> allPreviouslyExistingCsrFiles =
        await getAllFileNamesByExtension("csr");
    List<String> allPreviouslyExistingKeyFiles =
        await getAllFileNamesByExtension("key");

    List<String> args = [
      '-csr',
      '-csrConfig', "$csrFolder${Platform.pathSeparator}$csrConfigFile",
      // '-privateKey', privateKeyFile,
      // '-generatedCsr', outputCsrFile,
      if(getPem)'-pem',
      if (isForSimulation) '-sim',
      if (isForNoneProduction) '-nonprod'
    ];
    final result = await _runCommand(args);

    List<String> allNewlyExistingCsrFiles =
        await getAllFileNamesByExtension("csr");
    List<String> allNewlyExistingKeyFiles =
        await getAllFileNamesByExtension("key");

    String? newKeyFileName = _getNewFileName(before: allPreviouslyExistingKeyFiles, after: allNewlyExistingKeyFiles);
    String? newCsrFileName = _getNewFileName(before: allPreviouslyExistingCsrFiles, after: allNewlyExistingCsrFiles);

    String finalCsrFileName = outputCsrFile != null &&
            newCsrFileName != null &&
            await renameFile(oldName: newCsrFileName, newName: outputCsrFile)
        ? outputCsrFile
        : newCsrFileName ?? "";

    String finalKeyFileName = privateKeyFile != null &&
            newKeyFileName != null &&
            await renameFile(oldName: newKeyFileName, newName: privateKeyFile)
        ? privateKeyFile
        : newKeyFileName ?? "";

    return FatooraServiceCsrResponse(
        csrOutputFileName: finalCsrFileName,
        keyOutputFileName: finalKeyFileName,
        response: result);
  }

  /// Signs an invoice XML file using Fatoora CLI
  static Future<FatooraServiceResponse> signInvoice(
      {required String invoiceFileName,
      String? outputSignedInvoiceFileName}) async {
    final result = await _runCommand([
      '-sign',
      '-invoice',
      invoiceFileName,
      if (outputSignedInvoiceFileName != null) '-signedInvoice',
      if (outputSignedInvoiceFileName != null) outputSignedInvoiceFileName
    ]);

    return result;
  }

  /// Validates an invoice XML file using Fatoora CLI
  static Future<FatooraServiceResponse> validateInvoice({
    required String invoiceFileName,
  }) async {
    final result =
        await _runCommand(['-validate', '-invoice', invoiceFileName]);

    return result;
  }

  /// Generate Invoice Hash
  static generateInvoiceHash(String invoiceFileName) {
    return _runCommand(['-generateHash', '-invoice', invoiceFileName]);
  }

  /// Generate QR Code
  static Future<FatooraQrCodeResponse> generateQRInvoiceCode(
      String invoiceFileName) async {
    FatooraServiceResponse response =
        await _runCommand(['-qr', '-invoice', invoiceFileName]);
    String? extractQrCode(String log) {
      RegExp regex = RegExp(r'QR code = (.+)');
      Match? match = regex.firstMatch(log);
      return match?.group(1);
    }

    String? qrCode;
    ResponseStatus status = ResponseStatus.failure;
    if (response.infos != null) {
      for (var element in response.infos!) {
        qrCode = extractQrCode(element.message);
        if (qrCode != null) {
          status = ResponseStatus.success;
          break;
        }
      }
    }
    return FatooraQrCodeResponse(
        qrCode: qrCode, response: response, status: status);
  }

  /// Generate Invoice Request API
  static Future<FatooraInvoiceRequestApiResponse> generateInvoiceRequestAPI(
      {required String invoiceFileName, String? outputJsonFileName}) async {
        List<String> allJsonFilesBeforeExecution = await getAllFileNamesByExtension('json');
    FatooraServiceResponse response = await _runCommand([
      '-invoice',
      invoiceFileName,
      '-invoiceRequest',
      if (outputJsonFileName != null) '-apiRequest',
      if (outputJsonFileName != null) outputJsonFileName
    ]);

    InvoiceRequest? invoiceRequest;
    ResponseStatus status = ResponseStatus.failure;

    if(response.status == ResponseStatus.success && response.infos != null && response.infos!.isNotEmpty){
      status = ResponseStatus.success;
      List<String> allJsonFilesAfterExecution = await getAllFileNamesByExtension('json');
      String? newGeneratedFile = _getNewFileName(before: allJsonFilesBeforeExecution, after: allJsonFilesAfterExecution);

      String finalOutputFileName = outputJsonFileName != null &&
            newGeneratedFile != null &&
            await renameFile(oldName: newGeneratedFile, newName: outputJsonFileName)
        ? outputJsonFileName
        : newGeneratedFile ?? "";
      
      invoiceRequest = InvoiceRequest.fromMap(jsonDecode(await getFileContentAsString(finalOutputFileName)));
    }
    // response.infos.first.
    return FatooraInvoiceRequestApiResponse(status: status, invoiceRequest: invoiceRequest, response: response);
  }

  static Future<FatooraServiceResponse> getHelp() async {
    return await _runCommand(['-help']);
  }
}
