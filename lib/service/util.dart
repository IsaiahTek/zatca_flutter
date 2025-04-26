import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:zatca_flutter/model/invoice_request.dart';

/// Returns the base name (file name without path) from a full file path.
String _getBaseName(String fullPath) {
  String separator = Platform.pathSeparator;
  List<String> paths = fullPath.split(separator);
  return paths.isNotEmpty ? paths.last : fullPath;
}

/// Reads the content of a user-generated file as a string.
///
/// [fileName]: Name of the file to read.
/// [folder]: Optional subfolder inside storage.
///
/// Returns the file content as a string or `null` if the file does not exist or fails to read.
Future<String?> getFileContentAsString(String fileName,
    {String? folder}) async {
  return _getFileContentAsString(fileName, folder: folder);
}

Future<String?> _getFileContentAsString(String fileName,
    {String? folder}) async {
  String directory = await _getStorageFolderPath();
  final dir = Directory(
      "$directory${folder != null ? '${Platform.pathSeparator}$folder' : ''}");
  if (!(await dir.exists())) {
    await dir.create();
  }
  String? content;
  try {
    final File file = File("${dir.path}${Platform.pathSeparator}$fileName");
    content = await file.readAsString();
  } catch (e) {
    // Ignore error silently
  }
  return content;
}

/// Retrieves the base storage folder path for the app.
Future<String> getStorageFolderPath() async {
  return _getStorageFolderPath();
}

Future<String> _getStorageFolderPath() async {
  Directory appDocumentDirectory = await getApplicationDocumentsDirectory();
  String path =
      "${appDocumentDirectory.path}${Platform.pathSeparator}zatca_flutter";
  Directory dir = Directory(path);
  if (!(await dir.exists())) {
    await dir.create(recursive: true);
  }
  return dir.path;
}

/// Fetches the names of all files with the specified extension.
///
/// [extension]: Extension without the dot (e.g., 'txt').
///
/// Example:
/// ```dart
/// getAllFileNamesByExtension('example');
/// ```
Future<List<String>> getAllFileNamesByExtension(String extension) {
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

/// Loads an [InvoiceRequest] from a JSON file.
///
/// [fileName]: Name of the file to load.
/// [useAsAbsolutePath]: If true, treats [fileName] as a full absolute path.
///
/// Returns an [InvoiceRequest] object or `null` if file not found or parsing fails.
Future<InvoiceRequest?> loadInvoiceRequest(
    {required String fileName, bool useAsAbsolutePath = false}) async {
  return _loadInvoiceRequest(
      fileName: fileName, useAsAbsolutePath: useAsAbsolutePath);
}

Future<InvoiceRequest?> _loadInvoiceRequest(
    {required String fileName, bool useAsAbsolutePath = false}) async {
  String docPath = await getStorageFolderPath();
  String computedPath = useAsAbsolutePath
      ? fileName
      : "$docPath${Platform.pathSeparator}$fileName";
  final file = File(computedPath);
  if (!await file.exists()) {
    logError("File not found: $computedPath");
    return null;
  }

  String jsonString = await file.readAsString();
  Map<String, dynamic> invoiceRequestJson = jsonDecode(jsonString);
  return InvoiceRequest.fromMap(invoiceRequestJson);
}

/// Renames a file from [oldName] to [newName].
///
/// Returns `true` if successful, `false` otherwise.
Future<bool> renameFile(
    {required String oldName, required String newName}) async {
  return _renameFile(oldName: oldName, newName: newName);
}

Future<bool> _renameFile(
    {required String oldName, required String newName}) async {
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

/// Logs an error message in red color in the console.
void logError(String message) {
  log("\x1B[31m $message");
}

/// Logs an info message in green color in the console.
void logInfo(String message) {
  log("\x1b[38;5;32m $message");
}

/// Saves [content] to a file [fileName] in optional [folder].
///
/// Creates the file if it does not exist.
///
/// Returns the full path of the saved file.
Future<String> saveToFile(String content, String fileName,
    {String? folder}) async {
  final String directory = await getStorageFolderPath();
  final dir = Directory(
      "$directory${folder != null ? '${Platform.pathSeparator}$folder' : ''}");
  if (!(await dir.exists())) {
    await dir.create();
  }
  final file = File("${dir.path}${Platform.pathSeparator}$fileName");
  if (!(await file.exists())) {
    await file.create();
  }
  await file.writeAsString(content);
  return file.path;
}

/// Saves [content] to an absolute [path].
///
/// Overwrites if the file already exists.
Future<void> saveToAbsolutePath(String content, String path) async {
  File file = File(path);
  await file.writeAsString(content);
}

/// Returns the predefined PIH (Public Invoice Hash) string for the first invoice.
String getPIHForFirstInvoice() {
  return 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzIzOWRkNGU5MWI0NjcyOWQ3M2EyN2ZiNTdlOQ==';
}

/// Generates a random UUID (Universally Unique Identifier).
String generateUuid() {
  math.Random random = math.Random();
  return '${_generateHex(random, 8)}-${_generateHex(random, 4)}-${_generateHex(random, 4)}-${_generateHex(random, 4)}-${_generateHex(random, 12)}';
}

/// Internal function that generates a random hexadecimal string of given [length].
String _generateHex(math.Random random, int length) {
  final hexDigits = '0123456789abcdef';
  return List.generate(
      length, (_) => hexDigits[random.nextInt(hexDigits.length)]).join();
}

/// Returns the current date and time in the format: `yyyyMMddHHmmss`.
String getNowDateTimeYyyyMmDdHhMmSs() {
  final dT = DateTime.now();
  return '${dT.year}${dT.month}${dT.day}${dT.hour}${dT.minute}${dT.second}';
}

/// Formats a [DateTime] object into a ZATCA-compliant date string (`yyyy-MM-dd`).
String getZatcaCompliantDate(DateTime date) {
  return date.toIso8601String().split('T')[0];
}

/// Formats a [DateTime] object into a ZATCA-compliant time string (`HH:mm:ss`).
String getZatcaCompliantTime(DateTime time) {
  return time.toIso8601String().split('T')[1].split('.')[0];
}
