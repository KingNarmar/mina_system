import 'package:flutter/foundation.dart';

enum RealtimeDiagnosticScope { company, userContext }

enum RealtimeDiagnosticArea {
  sync,
  appResume,
  subscription,
  transactions,
  dashboard,
  companyUsers,
  currentContext,
  workers,
  tools,
  lookups,
}

enum RealtimeDiagnosticAction {
  unavailable,
  starting,
  stopping,
  backgrounded,
  resumed,
  noChanges,
  changesDetected,
  eventReceived,
  refreshStarted,
  refreshDeferred,
  refreshCompleted,
  refreshFailed,
  fallbackStarted,
  statusChanged,
  subscriptionFailed,
}

abstract final class RealtimeDiagnostics {
  static void write({
    required RealtimeDiagnosticScope scope,
    required RealtimeDiagnosticArea area,
    required RealtimeDiagnosticAction action,
    Object? eventType,
    Object? status,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      format(
        scope: scope,
        area: area,
        action: action,
        eventType: eventType,
        status: status,
      ),
    );
  }

  static String format({
    required RealtimeDiagnosticScope scope,
    required RealtimeDiagnosticArea area,
    required RealtimeDiagnosticAction action,
    Object? eventType,
    Object? status,
  }) {
    final parts = <String>[
      '[MinaRealtime]',
      'scope=${_toSnakeCase(scope.name)}',
      'area=${_toSnakeCase(area.name)}',
      'action=${_toSnakeCase(action.name)}',
    ];

    if (eventType != null) {
      parts.add('event=${_safeEventType(eventType)}');
    }

    if (status != null) {
      parts.add('status=${_safeStatus(status)}');
    }

    return parts.join(' ');
  }

  static String _safeEventType(Object value) {
    final normalized = value.toString().trim().toLowerCase();

    for (final allowed in const ['insert', 'update', 'delete', 'all']) {
      if (normalized == allowed || normalized.endsWith('.$allowed')) {
        return allowed;
      }
    }

    return 'unknown';
  }

  static String _safeStatus(Object value) {
    final normalized = value.toString().trim().toLowerCase();

    const allowed = <String, String>{
      'subscribed': 'subscribed',
      'timedout': 'timed_out',
      'closed': 'closed',
      'channelerror': 'channel_error',
    };

    for (final entry in allowed.entries) {
      if (normalized == entry.key || normalized.endsWith('.${entry.key}')) {
        return entry.value;
      }
    }

    return 'unknown';
  }

  static String _toSnakeCase(String value) {
    final buffer = StringBuffer();

    for (var index = 0; index < value.length; index++) {
      final character = value[index];
      final isUppercase =
          character.toUpperCase() == character &&
          character.toLowerCase() != character;

      if (isUppercase && index > 0) {
        buffer.write('_');
      }

      buffer.write(character.toLowerCase());
    }

    return buffer.toString();
  }
}
