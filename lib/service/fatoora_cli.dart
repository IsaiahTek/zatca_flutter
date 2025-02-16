import 'dart:developer';
import 'dart:io';
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

  /// Generates a CSR configuration file
  Future<void> generateCsrConfig({
    required String filePath,
    required String commonName,
    required String serialNumber,
    required String organizationIdentifier,
    required String organizationUnitName,
    required String organizationName,
    required String countryName,
    required String invoiceType,
    required String locationAddress,
    required String industryBusinessCategory,
  }) async {
    final file = File(filePath);
    final content = '''
commonName=$commonName
serialNumber=$serialNumber
organizationIdentifier=$organizationIdentifier
organizationUnitName=$organizationUnitName
organizationName=$organizationName
countryName=$countryName
invoiceType=$invoiceType
locationAddress=$locationAddress
industryBusinessCategory=$industryBusinessCategory
''';

    await file.writeAsString(content);
  }

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
      File logFile = File("$storagePath/fatoora-error-${DateTime.now()}.log");
      logFile.writeAsStringSync(message);
  }


  /// Generates a CSR file using Fatoora CLI
  static Future<FatooraCliCsrResponse> generateCsr({
    required String csrConfigFile,
    required String privateKeyFile,
    required String outputCsrFile,
  }) async {
    String csrFolder = await getStorageFolderPath();
    List<String> allPreviouslyExistingCsrFiles = await getAllFileNamesByExtension("csr");
    List<String> allPreviouslyExistingKeyFiles = await getAllFileNamesByExtension("key");

    final result = await _runCommand([
      '-csr',
      '-csrConfig', "$csrFolder/$csrConfigFile",
      // '-privateKey', privateKeyFile,
      // '-generatedCsr', outputCsrFile,
      // '-pem'
    ]);

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
    return FatooraCliCsrResponse(
        csrOutputFileName: newCsrFileName ?? "",
        keyOutputFileName: newKeyFileName ?? "",
        response: result);
  }

  /// Signs an invoice XML file using Fatoora CLI
  static Future<FatooraCliResponse> signInvoice({
    required String invoiceXml,
    required String privateKeyFile,
    required String outputSignedXml,
  }) async {
    final result = await _runCommand([
      '-sign',
      '-invoice',
      invoiceXml,
      '-privateKey',
      privateKeyFile,
      '-output',
      outputSignedXml
    ]);

    return result;
  }

  /// Validates an invoice XML file using Fatoora CLI
  static Future<FatooraCliResponse> validateInvoice({
    required String invoiceXml,
  }) async {
    final result = await _runCommand(['-validate', '-invoice', invoiceXml]);

    return result;
  }

  static Future<FatooraCliResponse> getHelp() async {
    return await _runCommand(['-help']);
  }
}
