import 'package:flutter/animation.dart';

class CancellationToken {
  bool _isCancelled = false;
  VoidCallback? _callback;

  CancellationToken([this._callback]);

  bool get isCancelled => _isCancelled;

  void throwIfCancelled() {
    if (_isCancelled) {
      throw OperationCancelledException();
    }
  }

  void cancel() {
    _isCancelled = true;

    _callback?.call();
  }

  set cancellationCallback(VoidCallback? callback) {
    _callback = callback;
  }
}

class OperationCancelledException implements Exception {}
