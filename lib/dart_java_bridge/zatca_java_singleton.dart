import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// This class manages a single Java process that runs the ZATCA runner.
/// It ensures that only one instance of the Java process is running at any time,
/// and provides a method to send requests to it and receive responses.
class ZatcaJavaSingleton {
  static Process? _process;
  static bool _starting = false;

  /// Initializes the Java process if it is not already running.
  /// This method is called before sending any requests to ensure that the Java process is ready to receive them.
  static Future<void> init() async {
    await _startIfNeeded();
  }

  static Future<void> _startIfNeeded() async {
    if (_process != null) return;
    if (_starting) return;

    _starting = true;

    _process = await Process.start(
      'java',
      ['-jar', 'zatca-runner.jar'],
      runInShell: true,
    );

    _process!.exitCode.then((code) {
      debugPrint("Java exited with $code");
      debugPrint("Java crashed. Restarting...");
      _process = null;
    });

    _process!.stderr.transform(utf8.decoder).listen((event) {
      debugPrint("JAVA ERROR: $event");
    });

    _starting = false;
  }

  /// Sends a request to the Java process and returns the response as a string.
  static Future<String> send(Map<String, dynamic> request) async {
    await _startIfNeeded();

    final completer = Completer<String>();

    final subscription = _process!.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((line) {
      completer.complete(line);
    });

    _process!.stdin.writeln(jsonEncode(request));

    final result = await completer.future;
    await subscription.cancel();

    return result;
  }

  /// Closes the Java process.
  static Future<void> dispose() async {
    _process?.kill();
    _process = null;
  }
}
