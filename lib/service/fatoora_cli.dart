import 'dart:developer';
import 'dart:io';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/service/util.dart';

import '../model/error_model.dart';
import '../model/info_model.dart';
import '../service/fatoora_path_finder.dart';

import '../enums.dart';
import '../model/fatoora_cli_response.dart';
import '../service/fatoora_cli_response_parser.dart';
import 'package:flutter/material.dart';

class FatooraCli {
  static final String? _fatooraPath = FatooraPathFinder.instance.path;

  /// Runs a Fatoora CLI command and returns the result
  static Future<FatooraCliResponse> _runCommand(List<String> args) async {
    try {
      if (_fatooraPath != null) {
        String workingDirectory = await getStorageFolderPath();
        ProcessResult result =
            await Process.run(_fatooraPath!, args, workingDirectory: workingDirectory);

        FatooraCliResponse response =
            FatooraCliResponseParser.extractResponses(result.stdout);
        debugPrint("RESPONSE STATUS: ${response.status.name.toUpperCase()}");
        if (response.status == ResponseStatus.failure) {
          log("\x1B[31m ZATCA/Fatoora Execution Failed (${response.errors?.length}):");
          for (ErrorModel element in response.errors ?? []) {
            log("\x1B[31m ZATCA/Fatoora ${element.source}: ${element.message}");
          }
          String? errors = response.errors?.map((d)=>"${d.source}: ${d.message}").join("\n");
          _writeLogToFile("ERRORS:\n$errors");
        } else {
          log("\x1B[32m ZATCA/Fatoora (${args.first}) Execution Successful(${response.infos?.length??0}), Warning(${response.warnings?.length ?? 0}):");
          for (InfoModel element in response.infos ?? []) {
            log("\x1B[34mZATCA/Fatoora ${element.source}: ${element.message}");
          }
        }

        return response;
      } else {
        _writeLogToFile("FATOORA PATH WASN'T FOUND. Set the path manually if you've already installed zatca/fatoora. Or install it and restart the application");
        throw Exception(
            "FATOORA PATH WASN'T FOUND. Set the path manually if you've already installed zatca/fatoora. Or install it and restart the application");
      }
    } catch (e) {
      _writeLogToFile("Error running Fatoora CLI: $e");
      throw Exception("Error running Fatoora CLI: $e");
    }
  }

  static _writeLogToFile(String message)async{
    String? storagePath = await getStorageFolderPath();
      File logFile = File("$storagePath${Platform.pathSeparator}fatoora-error-${DateTime.now()}.log");
      logFile.writeAsStringSync(message);
  }


  /// Generates a CSR file using Fatoora CLI
  /// Note: Because providing file name for generated private key and csr file makes the result not accurate, we have disabled it and used a work-aroud for providing the name of the generated csr and key files accordingly in a way that is more reliable. That means you can provide what you want the generated csr and key file to be named and it will be renamed to those you provide.
  static Future<FatooraCliCsrResponse> generateCsr({
    required String csrConfigFile,
    String? privateKeyFile,
    String? outputCsrFile,
    bool isForSimulation = false,
    bool isForNoneProduction = false
  }) async {
    String csrFolder = await getStorageFolderPath();
    List<String> allPreviouslyExistingCsrFiles = await getAllFileNamesByExtension("csr");
    List<String> allPreviouslyExistingKeyFiles = await getAllFileNamesByExtension("key");

    List<String> args = [
      '-csr',
      '-csrConfig', "$csrFolder${Platform.pathSeparator}$csrConfigFile",
      // '-privateKey', privateKeyFile,
      // '-generatedCsr', outputCsrFile,
      // '-pem'
      if(isForSimulation)'-sim',
      if(isForNoneProduction)'-nonprod'
    ];
    final result = await _runCommand(args);

    List<String> allNewlyExistingCsrFiles = await getAllFileNamesByExtension("csr");
    List<String> allNewlyExistingKeyFiles = await getAllFileNamesByExtension("key");

    String? newKeyFileName;
    String? newCsrFileName;

    for (var fileName in allNewlyExistingKeyFiles) {
      if (!allPreviouslyExistingKeyFiles.contains(fileName)) {
        newKeyFileName = fileName;
      }
    }
    for (var fileName in allNewlyExistingCsrFiles) {
      if (!allPreviouslyExistingCsrFiles.contains(fileName)) {
        newCsrFileName = fileName;
      }
    }
    String finalCsrFileName = outputCsrFile != null && newCsrFileName != null && await renameFile(oldName: newCsrFileName, newName: outputCsrFile) ? outputCsrFile : newCsrFileName??"";


    String finalKeyFileName = privateKeyFile != null && newKeyFileName != null && await renameFile(oldName: newKeyFileName, newName: privateKeyFile) ? privateKeyFile : newKeyFileName??"";

    return FatooraCliCsrResponse(
        csrOutputFileName: finalCsrFileName,
        keyOutputFileName: finalKeyFileName,
        response: result);
  }

  /// Signs an invoice XML file using Fatoora CLI
  static Future<FatooraCliResponse> signInvoice({
    required String invoiceFileName, String? outputSignedInvoiceFileName
  }) async {
    final result = await _runCommand([
      '-sign',
      '-invoice',
      invoiceFileName,
       if(outputSignedInvoiceFileName != null)'-signedInvoice', if(outputSignedInvoiceFileName != null)outputSignedInvoiceFileName
    ]);

    return result;
  }

  /// Validates an invoice XML file using Fatoora CLI
  static Future<FatooraCliResponse> validateInvoice({
    required String invoiceFileName,
  }) async {
    final result = await _runCommand(['-validate', '-invoice', invoiceFileName]);

    return result;
  }

  /// Generate Invoice Hash
  static generateInvoiceHash(String invoiceFileName){
    return _runCommand(['-generateHash', '-invoice', invoiceFileName]);
  }

  /// Generate QR Code
  static Future<void> generateQRInvoiceCode(String invoiceFileName){
    return _runCommand(['-qr', '-invoice', invoiceFileName]);
  }

  /// Generate Invoice Request API
  static Future<InvoiceRequest?> generateInvoiceRequestAPI({required String invoiceFileName, String? outputJsonFileName})async{
    FatooraCliResponse response = await _runCommand(['-invoice', invoiceFileName, '-invoiceRequest', if(outputJsonFileName != null)'-apiRequest', if(outputJsonFileName != null)outputJsonFileName]);
    // response.infos.first.
    // return;
  }

  static Future<FatooraCliResponse> getHelp() async {
    return await _runCommand(['-help']);
  }
}
