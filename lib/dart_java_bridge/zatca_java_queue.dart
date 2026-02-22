import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:zatca_flutter/dart_java_bridge/zatca_java_singleton.dart';

/// This class manages a queue of requests to the Java process, ensuring that they are processed one at a time in the order they were received. It uses the
/// ZatcaJavaSingleton to send requests to the Java process and receive responses, and it uses a Completer to manage the asynchronous nature of the requests and responses.
class ZatcaJavaQueue {
  static final Queue<_Request> _queue = Queue();
  static bool _processing = false;

  /// Sends a request to the Java process and returns the response as a string. The request is added to a queue and processed in order, ensuring that only one request is sent to the Java process at a time.
  static Future<String> send(Map<String, dynamic> request) {
    final completer = Completer<String>();
    _queue.add(_Request(request, completer));
    _processQueue();
    return completer.future;
  }

  static void _processQueue() async {
    if (_processing || _queue.isEmpty) return;

    _processing = true;

    final req = _queue.removeFirst();
    try {
      debugPrint("Processing request: ${req.data}");
      final result = await ZatcaJavaSingleton.send(req.data);
      req.completer.complete(result);
    } catch (e) {
      req.completer.completeError(e);
    }

    _processing = false;
    _processQueue();
  }
}

class _Request {
  final Map<String, dynamic> data;
  final Completer<String> completer;

  _Request(this.data, this.completer);
}