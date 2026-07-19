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

  static void writeSanitizedText({
    required RealtimeDiagnosticScope scope,
    required String message,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(formatSanitizedText(scope: scope, message: message));
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

  static String formatSanitizedText({
    required RealtimeDiagnosticScope scope,
    required String message,
  }) {
    final diagnostic = _classifySanitizedText(message);

    return format(
      scope: scope,
      area: diagnostic.area,
      action: diagnostic.action,
    );
  }

  static ({
    RealtimeDiagnosticArea area,
    RealtimeDiagnosticAction action,
  }) _classifySanitizedText(String message) {
    final normalized = message.trim().toLowerCase();
    final area = _classifyArea(normalized);

    if (normalized.contains('stacktrace') ||
        normalized.contains('error') ||
        normalized.contains('failed')) {
      return (
        area: area,
        action: area == RealtimeDiagnosticArea.subscription
            ? RealtimeDiagnosticAction.subscriptionFailed
            : RealtimeDiagnosticAction.refreshFailed,
      );
    }

    if (normalized.contains('no secondary')) {
      return (area: area, action: RealtimeDiagnosticAction.noChanges);
    }

    if (normalized.contains('secondary changed')) {
      return (area: area, action: RealtimeDiagnosticAction.changesDetected);
    }

    if (normalized.contains('falling back')) {
      return (area: area, action: RealtimeDiagnosticAction.fallbackStarted);
    }

    if (normalized.contains('event')) {
      return (area: area, action: RealtimeDiagnosticAction.eventReceived);
    }

    if (normalized.contains('deferred')) {
      return (area: area, action: RealtimeDiagnosticAction.refreshDeferred);
    }

    if (normalized.contains('refreshed')) {
      return (area: area, action: RealtimeDiagnosticAction.refreshCompleted);
    }

    if (normalized.contains('refreshing') || normalized.contains('checking')) {
      return (area: area, action: RealtimeDiagnosticAction.refreshStarted);
    }

    if (normalized.contains('no active')) {
      return (area: area, action: RealtimeDiagnosticAction.unavailable);
    }

    if (normalized.contains('starting')) {
      return (area: area, action: RealtimeDiagnosticAction.starting);
    }

    if (normalized.contains('stopping')) {
      return (area: area, action: RealtimeDiagnosticAction.stopping);
    }

    if (normalized.contains('background')) {
      return (area: area, action: RealtimeDiagnosticAction.backgrounded);
    }

    if (normalized.contains('resumed')) {
      return (area: area, action: RealtimeDiagnosticAction.resumed);
    }

    if (normalized.contains('status')) {
      return (area: area, action: RealtimeDiagnosticAction.statusChanged);
    }

    return (area: area, action: RealtimeDiagnosticAction.refreshStarted);
  }

  static RealtimeDiagnosticArea _classifyArea(String normalized) {
    if (normalized.contains('transaction')) {
      return RealtimeDiagnosticArea.transactions;
    }

    if (normalized.contains('company user') ||
        normalized.contains('company member')) {
      return RealtimeDiagnosticArea.companyUsers;
    }

    if (normalized.contains('currentcontext') ||
        normalized.contains('current context')) {
      return RealtimeDiagnosticArea.currentContext;
    }

    if (normalized.contains('lookup') ||
        normalized.contains('department') ||
        normalized.contains('job title')) {
      return RealtimeDiagnosticArea.lookups;
    }

    if (normalized.contains('worker')) {
      return RealtimeDiagnosticArea.workers;
    }

    if (normalized.contains('tool')) {
      return RealtimeDiagnosticArea.tools;
    }

    if (normalized.contains('dashboard')) {
      return RealtimeDiagnosticArea.dashboard;
    }

    if (normalized.contains('resume') || normalized.contains('background')) {
      return RealtimeDiagnosticArea.appResume;
    }

    if (normalized.contains('status') || normalized.contains('subscribe')) {
      return RealtimeDiagnosticArea.subscription;
    }

    return RealtimeDiagnosticArea.sync;
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
      final isUppercase = character.toUpperCase() == character &&
          character.toLowerCase() != character;

      if (isUppercase && index > 0) {
        buffer.write('_');
      }

      buffer.write(character.toLowerCase());
    }

    return buffer.toString();
  }
}
