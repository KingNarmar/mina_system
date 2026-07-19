import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/core/realtime/realtime_diagnostics.dart';

void main() {
  group('RealtimeDiagnostics.format', () {
    test('formats known event types without record data', () {
      final message = RealtimeDiagnostics.format(
        scope: RealtimeDiagnosticScope.company,
        area: RealtimeDiagnosticArea.transactions,
        action: RealtimeDiagnosticAction.eventReceived,
        eventType: _KnownValue('PostgresChangeEvent.update'),
      );

      expect(
        message,
        '[MinaRealtime] scope=company area=transactions '
        'action=event_received event=update',
      );
      expect(message, isNot(contains('newRecord')));
      expect(message, isNot(contains('oldRecord')));
    });

    test('formats known subscription statuses safely', () {
      final message = RealtimeDiagnostics.format(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.subscription,
        action: RealtimeDiagnosticAction.statusChanged,
        status: _KnownValue('RealtimeSubscribeStatus.channelError'),
      );

      expect(message, contains('scope=user_context'));
      expect(message, contains('status=channel_error'));
    });

    test('redacts unknown event and status text', () {
      final message = RealtimeDiagnostics.format(
        scope: RealtimeDiagnosticScope.company,
        area: RealtimeDiagnosticArea.subscription,
        action: RealtimeDiagnosticAction.subscriptionFailed,
        eventType: _KnownValue(
          'insert token=secret signedUrl=https://example.com/private',
        ),
        status: _KnownValue(
          r'C:\private\worker-photo.jpg profile_id=profile-secret',
        ),
      );

      expect(message, contains('event=unknown'));
      expect(message, contains('status=unknown'));
      expect(message, isNot(contains('secret')));
      expect(message, isNot(contains('https://')));
      expect(message, isNot(contains(r'C:\private')));
      expect(message, isNot(contains('profile_id')));
    });

    test('failure categories contain no arbitrary exception payload', () {
      final message = RealtimeDiagnostics.format(
        scope: RealtimeDiagnosticScope.company,
        area: RealtimeDiagnosticArea.currentContext,
        action: RealtimeDiagnosticAction.refreshFailed,
      );

      expect(
        message,
        '[MinaRealtime] scope=company area=current_context '
        'action=refresh_failed',
      );
      expect(message, isNot(contains('error=')));
      expect(message, isNot(contains('stackTrace')));
    });
  });
}

class _KnownValue {
  const _KnownValue(this.value);

  final String value;

  @override
  String toString() => value;
}
