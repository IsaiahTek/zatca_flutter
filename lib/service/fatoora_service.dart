import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:zatca_flutter/model/fatoora_invoice_hash_response.dart';
import 'package:zatca_flutter/model/fatoora_invoice_request_api_response.dart';
import 'package:zatca_flutter/model/fatoora_qr_code_response.dart';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/request.dart';
import 'package:zatca_flutter/service/util.dart';
import 'package:zatca_flutter/zatca_flutter.dart';

import '../local_store.dart';
import '../model/error_model.dart';
import '../model/info_model.dart';
import 'fatoora_service_finder.dart';

import '../enums.dart';
import '../model/fatoora_service_response.dart';
import 'fatoora_service_response_parser.dart';

/// Zatca Fatoora Service has all the API for doing everything that the Zataca Java SDK provides.
///
/// These include the following:
///
/// [1] Generating CSR.
///
/// [2] Signing Invoice/Note.
///
/// [3] Validating Invoice/Note.
///
/// [4] Generating Invoice Hash.
///
/// [5] Generating Invoice QR Code.
///
/// [6] Generating Invoice Request API.
class FatooraService {
  static final FatooraServiceFinder _finder = FatooraServiceFinder.instance;
  static final String? _fatooraPath = _finder.path;

  /// Runs a Fatoora CLI command and returns the result
  static Future<FatooraServiceResponse> _runCommand(List<String> args) async {
    try {
      if (_fatooraPath != null) {
        String workingDirectory = await getStorageFolderPath();

        String command = Platform.isWindows ? 'cmd' : _fatooraPath!;
        List<String> compositeArgs =
            Platform.isWindows ? ['/C', _fatooraPath!, ...args] : args;

        ProcessResult result = await Process.run(command, compositeArgs,
            runInShell: true,
            workingDirectory: workingDirectory,
            environment: {
              'SDK_CONFIG': _finder.sdkConfig ?? "",
              'FATOORA_HOME': _finder.fatooraHome ?? ""
            });

        FatooraServiceResponse response =
            FatooraServiceResponseParser.extractResponses(result.stdout);
        logInfo("RAW OUTPUT ${result.stdout}");
        if ((result.stderr as String).isNotEmpty)
          logInfo("RAW ERROR ${result.stderr}");
        logInfo("RESPONSE STATUS: ${response.status.name.toUpperCase()}");
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
            log("\x1B[34m ZATCA/Fatoora ${element.source}: ${element.message}");
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
    await saveToFile(
        message, "fatoora-error-${getNowDateTimeYyyyMmDdHhMmSs()}.log",
        folder: 'logs');
  }

  static String? _getNewFileName(
      {required List<String> before, required List<String> after}) {
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
      String? outputCsrFile}) async {
    return _generateCsr(
        csrConfigFile: csrConfigFile,
        privateKeyFile: privateKeyFile,
        outputCsrFile: outputCsrFile);
  }

  static Future<FatooraServiceCsrResponse> _generateCsr(
      {required String csrConfigFile,
      String? privateKeyFile,
      String? outputCsrFile,
      bool getPem = false}) async {
    bool isForSimulation = ZatcaFlutter.mode == Mode.simulation;
    bool isForNoneProduction = ZatcaFlutter.mode == Mode.production;

    String csrFolder = await getStorageFolderPath();
    List<String> allPreviouslyExistingCsrFiles =
        await getAllFileNamesByExtension("csr");
    List<String> allPreviouslyExistingKeyFiles =
        await getAllFileNamesByExtension("key");

    List<String> args = [
      '-csr',
      '-csrConfig',
      "$csrFolder${Platform.pathSeparator}$csrConfigFile",
      if (getPem) '-pem',
      if (isForSimulation) '-sim',
      if (isForNoneProduction) '-nonprod'
    ];
    final result = await _runCommand(args);

    List<String> allNewlyExistingCsrFiles =
        await getAllFileNamesByExtension("csr");
    List<String> allNewlyExistingKeyFiles =
        await getAllFileNamesByExtension("key");

    String? newKeyFileName = _getNewFileName(
        before: allPreviouslyExistingKeyFiles, after: allNewlyExistingKeyFiles);
    String? newCsrFileName = _getNewFileName(
        before: allPreviouslyExistingCsrFiles, after: allNewlyExistingCsrFiles);

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
      String? outputSignedInvoiceFileName,
      bool isForComplianceCheck = false}) async {
    return _signInvoice(
        invoiceFileName: invoiceFileName,
        outputSignedInvoiceFileName: outputSignedInvoiceFileName,
        isForComplianceCheck: isForComplianceCheck);
  }

  static Future<FatooraServiceResponse> _signInvoice(
      {required String invoiceFileName,
      String? outputSignedInvoiceFileName,
      bool isForComplianceCheck = false}) async {
    // A signed invoice could be used for either compliance check or for reporting/clearance.
    // Compliance Check Invoice requires CCSID while reporting/clearance requires PCSID.
    await LocalStore.instance.switchCertInSDK(usePCSID: !isForComplianceCheck);

    final result = await _runCommand([
      '-sign',
      '-invoice',
      invoiceFileName,
      if (outputSignedInvoiceFileName != null) '-signedInvoice',
      if (outputSignedInvoiceFileName != null) outputSignedInvoiceFileName
    ]);

    return result;
  }

  /// Validates an invoice XML file using Fatoora CLI.
  ///
  /// If `ignoreWarningForResponseStatus` is set to true the response status will return the global validation result instead.
  /// That means, if the GLOBAL VALIDATION RESULT IS PASSED then the response status will be SUCCESS regardles of any warning that might be available.
  /// This ignoreWarningForResponseStatus flag is added because the service could return GLOBAL VALIDATION RESULT = PASSED if there isn't a critical error.
  static Future<FatooraServiceResponse> validateInvoice(
      {required String invoiceFileName,
      bool ignoreWarningForResponseStatus = false}) async {
    return _validateInvoice(
        invoiceFileName: invoiceFileName,
        ignoreWarningForResponseStatus: ignoreWarningForResponseStatus);
  }

  static Future<FatooraServiceResponse> _validateInvoice(
      {required String invoiceFileName,
      bool ignoreWarningForResponseStatus = false}) async {
    final result =
        await _runCommand(['-validate', '-invoice', invoiceFileName]);

    if (result.infos != null &&
        result.infos!.isNotEmpty &&
        result.infos!.last.message
            .contains('GLOBAL VALIDATION RESULT = PASSED') &&
        ignoreWarningForResponseStatus) {
      result.status = ResponseStatus.success;
    }
    return result;
  }

  /// Generate Invoice Hash. Just pass in the name of the invoice/note file you want to generate hash from
  static Future<FatooraInvoiceHashResponse> generateInvoiceHash(
      String invoiceFileName) async {
    return _generateInvoiceHash(invoiceFileName);
  }

  static Future<FatooraInvoiceHashResponse> _generateInvoiceHash(
      String invoiceFileName) async {
    final res =
        await _runCommand(['-generateHash', '-invoice', invoiceFileName]);
    String? extractHash(String raw) {
      RegExp regex = RegExp(r'INVOICE HASH = (.+)');
      Match? match = regex.firstMatch(raw);
      return match?.group(1);
    }

    String? hashValue;
    ResponseStatus status = ResponseStatus.failure;
    if (res.infos != null) {
      for (var element in res.infos!) {
        hashValue = extractHash(element.message);
        if (hashValue != null) {
          status = ResponseStatus.success;
          break;
        }
      }
    }
    logInfo(
        "HASH VALUE AFTER GENERATION = $hashValue AND STATUS = ${status.name.toUpperCase()}");
    return FatooraInvoiceHashResponse(
        hashValue: hashValue, response: res, status: status);
  }

  /// Generates a QR code for the invoice.
  ///
  /// This method generates a QR code based on the provided invoice XML file.
  /// The QR code is returned as part of the `FatooraQrCodeResponse` object.
  static Future<FatooraQrCodeResponse> generateInvoiceQRCode(
      String invoiceFileName) async {
    return _generateInvoiceQRCode(invoiceFileName);
  }

  static Future<FatooraQrCodeResponse> _generateInvoiceQRCode(
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

  /// Generates an Invoice Request API for a given invoice.
  ///
  /// This method generates an API request for a given invoice XML file and returns
  /// the response as a `FatooraInvoiceRequestApiResponse`. You can optionally
  /// provide a file name for the output JSON file and specify whether the request
  /// is for clearance.
  static Future<FatooraInvoiceRequestApiResponse> generateInvoiceRequestAPI(
      {required String invoiceFileName,
      String? outputJsonFileName,
      bool forClearance = false}) async {
    return _generateInvoiceRequestAPI(
        invoiceFileName: invoiceFileName,
        outputJsonFileName: outputJsonFileName,
        forClearance: forClearance);
  }

  static Future<FatooraInvoiceRequestApiResponse> _generateInvoiceRequestAPI(
      {required String invoiceFileName,
      String? outputJsonFileName,
      bool forClearance = false}) async {
    List<String> allJsonFilesBeforeExecution =
        await getAllFileNamesByExtension('json');
    FatooraServiceResponse response = await _runCommand([
      '-invoice',
      invoiceFileName,
      '-invoiceRequest',
      if (outputJsonFileName != null) '-apiRequest',
      if (outputJsonFileName != null) outputJsonFileName
    ]);

    InvoiceRequest? invoiceRequest;
    ResponseStatus status = ResponseStatus.failure;

    if (response.status == ResponseStatus.success &&
        response.infos != null &&
        response.infos!.isNotEmpty) {
      status = ResponseStatus.success;
      List<String> allJsonFilesAfterExecution =
          await getAllFileNamesByExtension('json');
      String? newGeneratedFile = _getNewFileName(
          before: allJsonFilesBeforeExecution,
          after: allJsonFilesAfterExecution);

      String finalOutputFileName = outputJsonFileName != null &&
              newGeneratedFile != null &&
              await renameFile(
                  oldName: newGeneratedFile, newName: outputJsonFileName)
          ? outputJsonFileName
          : newGeneratedFile ?? "";
      String? raw = await getFileContentAsString(finalOutputFileName);
      if (raw != null) {
        invoiceRequest = InvoiceRequest.fromMap(jsonDecode(raw));
        // If the API is generated for clearance (i.e. the input file is a standard invoice/note),
        // there's a need to generate and assign the invoice hash because it is not handled by ZATCA SDK
        if (forClearance) {
          final res = await generateInvoiceHash(invoiceFileName);
          if (res.hashValue != null) {
            final newIR = InvoiceRequest(
                invoice: invoiceRequest.invoice,
                invoiceHash: res.hashValue!,
                uuid: invoiceRequest.uuid);
            saveToFile(jsonEncode(newIR.toMap()), finalOutputFileName);
            invoiceRequest = newIR;
          }
        }
      }
    }
    // response.infos.first.
    return FatooraInvoiceRequestApiResponse(
        status: status, invoiceRequest: invoiceRequest, response: response);
  }

  /// Provides help information for using the Fatoora CLI.
  ///
  /// This method returns a response from the `-help` command, useful for testing the
  /// SDK installation and for general reference.
  static Future<FatooraServiceResponse> getHelp() async {
    return _getHelp();
  }

  static Future<FatooraServiceResponse> _getHelp() async {
    return await _runCommand(['-help']);
  }
}
