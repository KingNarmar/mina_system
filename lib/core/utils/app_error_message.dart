import 'dart:async';
import 'dart:io';

import 'package:mina_system/core/services/network_status_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppErrorMessage {
  static const String defaultError = 'Something went wrong. Please try again.';

  static const String noInternetConnection =
      'No internet connection. Please check your network and try again.';

  static const String networkProblem =
      'We could not connect to the server. Please check your internet connection and try again.';

  static const String slowOrUnstableConnection =
      'Your connection seems slow or unstable. Please try again.';

  static const String cloudStorageProblem =
      'We could not access cloud files right now. Please check your connection and try again.';

  static const String serverProblem =
      'The server is not reachable right now. Please try again later.';

  static String fromError(Object error, {String fallback = defaultError}) {
    if (error is NetworkUnavailableException) {
      return error.message;
    }

    if (_isTimeoutError(error)) {
      return slowOrUnstableConnection;
    }

    if (_isNetworkError(error)) {
      return networkProblem;
    }

    if (error is StorageException) {
      return _fromStorageException(error, fallback: fallback);
    }

    if (error is PostgrestException) {
      return _fromPostgrestException(error, fallback: fallback);
    }

    if (error is AuthException) {
      return _fromAuthException(error, fallback: fallback);
    }

    return fallback;
  }

  static String networkOnly(Object error, {String fallback = defaultError}) {
    if (error is NetworkUnavailableException) {
      return error.message;
    }

    if (_isTimeoutError(error)) {
      return slowOrUnstableConnection;
    }

    if (_isNetworkError(error)) {
      return networkProblem;
    }

    return fallback;
  }

  static bool _isNetworkError(Object error) {
    if (error is SocketException) {
      return true;
    }

    final message = _normalizedErrorMessage(error);

    return message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('connection failed') ||
        message.contains('connection terminated') ||
        message.contains('network is unreachable') ||
        message.contains('network error') ||
        message.contains('no address associated with hostname') ||
        message.contains('xmlhttprequest error') ||
        message.contains('failed to fetch') ||
        message.contains('host lookup failed') ||
        message.contains('software caused connection abort');
  }

  static bool _isTimeoutError(Object error) {
    if (error is TimeoutException) {
      return true;
    }

    final message = _normalizedErrorMessage(error);

    return message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('connection closed before full header was received') ||
        message.contains('connection closed while receiving data');
  }

  static String _fromAuthException(
    AuthException error, {
    required String fallback,
  }) {
    if (_isTimeoutError(error)) {
      return slowOrUnstableConnection;
    }

    if (_isNetworkError(error)) {
      return networkProblem;
    }

    final message = error.message.trim();

    if (message.isEmpty) {
      return fallback;
    }

    return message;
  }

  static String _fromPostgrestException(
    PostgrestException error, {
    required String fallback,
  }) {
    if (_isTimeoutError(error)) {
      return slowOrUnstableConnection;
    }

    if (_isNetworkError(error)) {
      return networkProblem;
    }

    return fallback;
  }

  static String _fromStorageException(
    StorageException error, {
    required String fallback,
  }) {
    if (_isTimeoutError(error)) {
      return slowOrUnstableConnection;
    }

    if (_isNetworkError(error)) {
      return networkProblem;
    }

    return cloudStorageProblem;
  }

  static String _normalizedErrorMessage(Object error) {
    return error.toString().toLowerCase().trim();
  }
}
