import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// This class manages a single Java process that runs the ZATCA runner.
/// It ensures that only one instance of the Java process is running at any time,
/// and provides a method to send requests to it and receive responses.
class ZatcaJavaSingleton {
  static Process? _process;
  static bool _starting = false;

  static Completer<String>? _responseCompleter;
  static StreamSubscription<String>? _stdoutSub;

  /// Initializes the Java process if it is not already running.
  /// This method is called before sending any requests to ensure that the Java process is ready to receive them.
  static Future<void> init() async {
    await _startIfNeeded();
  }

  static String? _cachedJarPath;

  static Future<String> _extractRunnerJar() async {
    if (_cachedJarPath != null) return _cachedJarPath!;

    final byteData = await rootBundle.load(
      'packages/zatca_flutter/bin/zatca-runner.jar',
    );

    final tempDir = await getTemporaryDirectory();

    final file = File('${tempDir.path}/zatca-runner.jar');

    await file.writeAsBytes(
      byteData.buffer.asUint8List(),
      flush: true,
    );

    _cachedJarPath = file.path;

    return _cachedJarPath!;
  }

  static Future<void> _startIfNeeded() async {
    if (_process != null || _starting) return;

    _starting = true;

    try {
      final jarPath = await _extractRunnerJar();

      _process = await Process.start(
        'java',
        ['-jar', jarPath],
        runInShell: true,
      );

      _stdoutSub = _process!.stdout
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) {
        if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
          _responseCompleter!.complete(line);
        }
      });

      _process!.stderr.transform(utf8.decoder).listen((event) {
        debugPrint("JAVA ERROR: $event");
      });

      _process!.exitCode.then((code) {
        debugPrint("Java exited with $code");
        _process = null;
      });
    } finally {
      _starting = false;
    }
  }

  /// Sends a request to the Java process and returns the response as a string.
  static Future<String> send(Map<String, dynamic> request) async {
    await _startIfNeeded();

    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      throw Exception("Previous request still in progress");
    }

    _responseCompleter = Completer<String>();

    _process!.stdin.writeln(jsonEncode(request));

    final result = await _responseCompleter!.future;

    _responseCompleter = null;

    return result;
  }

  /// Closes the Java process.
  static Future<void> dispose() async {
    _process?.kill();
    _process = null;
  }
}
