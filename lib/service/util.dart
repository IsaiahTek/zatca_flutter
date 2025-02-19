import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zatca_flutter/model/csr_config.dart';
import 'package:zatca_flutter/model/invoice_request.dart';
import 'package:zatca_flutter/service/fatoora_service_finder.dart';

String _getBaseName(String fullPath){
  String separator = Platform.pathSeparator;
  List<String> paths = fullPath.split(separator);
  return paths.isNotEmpty?paths.last:fullPath;
}

/// Needed for reading any user generated file content as string.
Future<String> getFileContentAsString(String filePath) async {
  return _getFileContentAsString(filePath);
}
Future<String> _getFileContentAsString(String filePath) async {
  String parentDir = await _getStorageFolderPath();
  String content = "";
  try {
    File file = File("$parentDir${Platform.pathSeparator}$filePath");
    content = await file.readAsString();
  } catch (e) {
    // 
  }
  return content;
}

/// Needed for getting the package storage folder path on the user system.
Future<String> getStorageFolderPath()async{
  return _getStorageFolderPath();
}

Future<String> _getStorageFolderPath()async{
  Directory appDocumentDirectory = await getApplicationDocumentsDirectory();
  String path = "${appDocumentDirectory.path}${Platform.pathSeparator}zatca_flutter";
  Directory dir = Directory(path);
  if (!(await dir.exists())) {
    await dir.create(recursive: true);
  }
  return dir.path;
}

/// To fetch the names of all files that have an extionsion of .example call it thus:
/// ```
/// getAllFileNamesByExtension('example')
/// ```
/// 
/// Notice it doesn't require the dot to be added`
Future<List<String>> getAllFileNamesByExtension(String extension){
  return _getAllFileNamesByExtension(extension);
}

 
Future<List<String>> _getAllFileNamesByExtension(String extension) async {
    final directory = Directory(await getStorageFolderPath());
    final files = await directory.list().toList();
    final keyFiles = files
        .where((file) => file.path.endsWith('.$extension'))
        .map((file) => _getBaseName(file.path))
        .toList();
    return keyFiles;
  }

/// Generates a CSR configuration file
Future<String> createCsrConfigFile({
  required CsrConfig csrConfig,
}) async {
  return _createCsrConfigFile(csrConfig: csrConfig);
}
Future<String> _createCsrConfigFile({
  required CsrConfig csrConfig,
}) async {
  String fileName = FatooraServiceFinder.instance.csrFileName;
  final content = '''
      csr.common.name=${csrConfig.commonName}
      csr.serial.number=${csrConfig.serialNumber}
      csr.organization.identifier=${csrConfig.organizationIdentifier}
      csr.organization.unit.name=${csrConfig.organizationUnitName}
      csr.organization.name=${csrConfig.organizationName}
      csr.country.name=${csrConfig.countryName}
      csr.invoice.type=${csrConfig.invoiceType}
      csr.location.address=${csrConfig.locationAddress}
      csr.industry.business.category=${csrConfig.industryBusinessCategory}
      ''';

  try {
    String filePath = await saveToFile(content, fileName);
    debugPrint('✅ CSR config file created: $filePath');
    return fileName;
  } catch (e) {
    logError("Error Creating the config .properties file: $e");
    throw Exception("Error Creating the config .properties file: $e");
  }
}

/// loadCsr file as Future of .
/// If you make useFullPath true then the package assumes you're providing absolute path and won't prepend any directory.
Future<CsrConfig?> loadCsrConfig() async {
  return _loadCsrConfig();
}

Future<CsrConfig?> _loadCsrConfig() async {
  String fileName = FatooraServiceFinder.instance.csrFileName;
  String docPath = await getStorageFolderPath();
  String computedPath = "$docPath${Platform.pathSeparator}$fileName";
  final file = File(computedPath);
  if (!await file.exists()) {
    logError("File not found: $computedPath");
    return null;
  }

  final lines = await file.readAsLines();
  final Map<String, String> properties = {};

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith('!')) {
      continue; // Skip comments and empty lines
    }

    final separatorIndex = line.indexOf('=');
    if (separatorIndex == -1) continue; // Invalid line, skip

    final key = line.substring(0, separatorIndex).trim();
    final value = line.substring(separatorIndex + 1).trim();

    properties[key] = value;
  }

  return CsrConfig.fromMap(properties);
}

Future<InvoiceRequest?> loadInvoiceRequest({required String fileName, bool useAsAbsolutePath = false})async{
  return _loadInvoiceRequest(fileName: fileName, useAsAbsolutePath: useAsAbsolutePath);
}

Future<InvoiceRequest?> _loadInvoiceRequest({required String fileName, bool useAsAbsolutePath = false})async{
  String docPath = await getStorageFolderPath();
  String computedPath = useAsAbsolutePath ? fileName : "$docPath${Platform.pathSeparator}$fileName";
  final file = File(computedPath);
  if (!await file.exists()) {
    logError("File not found: $computedPath");
    return null;
  }

  String jsonString = await file.readAsString();

  Map<String, dynamic> invoiceRequestJson = jsonDecode(jsonString);
  return InvoiceRequest.fromMap(invoiceRequestJson);
}

/// Rename File if needed
Future<bool> renameFile({required String oldName, required String newName})async{
  return _renameFile(oldName: oldName, newName: newName);
}

Future<bool> _renameFile({required String oldName, required String newName})async{
  try {
    String oldPath = await getStorageFolderPath();
    File file = File("$oldPath${Platform.pathSeparator}$oldName");
    file = await file.rename("$oldPath${Platform.pathSeparator}$newName");
    return _getBaseName(file.path) == newName; 
  } catch (e) {
    logError("ERROR RENAMING FILE: $e");
    return false;
  }
}

void logError(String message){
  log("'$message'");
}

/// Create a file and write the string as the content to the file.
Future<String> saveToFile(String content, String fileName) async {
  final String directory = await getStorageFolderPath();
  final file = File("$directory${Platform.pathSeparator}$fileName");
  await file.writeAsString(content);
  return file.path;
}