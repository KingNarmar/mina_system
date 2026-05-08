import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppErrorMessage {
  static const String networkProblem =
      'Network problem. Please check your internet connection and try again.';

  static const String slowOrUnstableConnection =
      'Your connection seems slow or unstable. Please try again.';

  static String fromError(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (_isNetworkError(error)) {
      return networkProblem;
    }

    if (_isTimeoutError(error)) {
      return slowOrUnstableConnection;
    }

    if (error is AuthException) {
      return error.message;
    }

    if (error is PostgrestException) {
      return _fromPostgrestException(error, fallback: fallback);
    }

    if (error is StorageException) {
      return _fromStorageException(error, fallback: fallback);
    }

    return fallback;
  }

  static bool _isNetworkError(Object error) {
    if (error is SocketException) {
      return true;
    }

    final message = error.toString().toLowerCase();

    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('network is unreachable') ||
        message.contains('no address associated with hostname') ||
        message.contains('xmlhttprequest error');
  }

  static bool _isTimeoutError(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('connection closed before full header was received');
  }

  static String _fromPostgrestException(
    PostgrestException error, {
    required String fallback,
  }) {
    final message = error.message.trim();

    if (message.isEmpty) {
      return fallback;
    }

    return message;
  }

  static String _fromStorageException(
    StorageException error, {
    required String fallback,
  }) {
    final message = error.message.trim();

    if (message.isEmpty) {
      return fallback;
    }

    return message;
  }
}
