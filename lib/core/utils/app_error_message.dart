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

    if (error is StateError) {
      return _fromStateError(error, fallback: fallback);
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

  static String _fromStateError(StateError error, {required String fallback}) {
    final message = _cleanStateErrorMessage(error);

    if (message.isEmpty) {
      return fallback;
    }

    if (_isSafeUserFacingStateError(message)) {
      return message;
    }

    return fallback;
  }

  static String _cleanStateErrorMessage(StateError error) {
    return error.message.trim();
  }

  static bool _isSafeUserFacingStateError(String message) {
    final normalizedMessage = message.toLowerCase();

    return _isSafeFileOrImageError(normalizedMessage) ||
        _isSafeTransactionBusinessError(normalizedMessage) ||
        _isSafeMissingIdentifierError(normalizedMessage);
  }

  static bool _isSafeFileOrImageError(String message) {
    return message.contains('file was not found') ||
        message.contains('file is empty') ||
        message.contains('unable to decode image file') ||
        message.contains('unsupported image file type') ||
        message.contains('supported types are') ||
        message.contains('must be pdf') ||
        message.contains('must have an extension') ||
        message.contains('pdf files should not be image-compressed') ||
        message.contains('image compression quality') ||
        message.contains('image max dimension');
  }

  static bool _isSafeTransactionBusinessError(String message) {
    return message.contains('only lost or damaged transactions') ||
        message.contains('only pending transactions') ||
        message.contains('only approved lost or damaged transactions') ||
        message.contains('only transactions pending settlement') ||
        message.contains('signed approval document must be uploaded') ||
        message.contains('signed approval document was not found') ||
        message.contains('invalid approval document storage path') ||
        message.contains(
          'approval document can be uploaded only for lost or damaged transactions',
        ) ||
        message.contains(
          'approval document can be uploaded only while approval is pending',
        );
  }

  static bool _isSafeMissingIdentifierError(String message) {
    return message.contains('transaction id was not found') ||
        message.contains('company id was not found') ||
        message.contains('profile id was not found') ||
        message.contains('approver profile id was not found') ||
        message.contains('rejector profile id was not found') ||
        message.contains('settlement profile id was not found') ||
        message.contains('current profile is not loaded') ||
        message.contains('current company is not selected') ||
        message.contains('current user role is not loaded');
  }

  static String _normalizedErrorMessage(Object error) {
    return error.toString().toLowerCase().trim();
  }
}
