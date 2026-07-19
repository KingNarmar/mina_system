import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/core/realtime/realtime_diagnostics.dart';

void main() {
  group('RealtimeDiagnostics.format', () {
    test('formats known event types without record data', () {
      final message = RealtimeDiagnostics.format(
        scope: RealtimeDiagnosticScope.company,
        area: RealtimeDiagnosticArea.transactions,
        action: RealtimeDiagnosticAction.eventReceived,
        eventType: const _KnownValue('PostgresChangeEvent.update'),
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
        status: const _KnownValue('RealtimeSubscribeStatus.channelError'),
      );

      expect(message, contains('scope=user_context'));
      expect(message, contains('status=channel_error'));
    });

    test('redacts unknown event and status text', () {
      final message = RealtimeDiagnostics.format(
        scope: RealtimeDiagnosticScope.company,
        area: RealtimeDiagnosticArea.subscription,
        action: RealtimeDiagnosticAction.subscriptionFailed,
        eventType: const _KnownValue(
          'insert token=secret signedUrl=https://example.com/private',
        ),
        status: const _KnownValue(
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

  group('RealtimeDiagnostics.formatSanitizedText', () {
    test('classifies a payload event without retaining record values', () {
      final message = RealtimeDiagnostics.formatSanitizedText(
        scope: RealtimeDiagnosticScope.company,
        message:
            'TRANSACTIONS EVENT => event=update, '
            'new={worker_name: Private Worker, token: secret}, '
            'old={signed_url: https://example.com/private}',
      );

      expect(
        message,
        '[MinaRealtime] scope=company area=transactions '
        'action=event_received',
      );
      expect(message, isNot(contains('Private Worker')));
      expect(message, isNot(contains('secret')));
      expect(message, isNot(contains('https://')));
      expect(message, isNot(contains('new=')));
      expect(message, isNot(contains('old=')));
    });

    test('classifies identifiers and roles without retaining them', () {
      final message = RealtimeDiagnostics.formatSanitizedText(
        scope: RealtimeDiagnosticScope.userContext,
        message:
            'CurrentContext refreshed. '
            'newCompanyId=company-secret, newRole=owner',
      );

      expect(
        message,
        '[MinaRealtime] scope=user_context area=current_context '
        'action=refresh_completed',
      );
      expect(message, isNot(contains('company-secret')));
      expect(message, isNot(contains('owner')));
    });

    test('classifies arbitrary errors without retaining exception text', () {
      final message = RealtimeDiagnostics.formatSanitizedText(
        scope: RealtimeDiagnosticScope.company,
        message:
            r'Workers realtime refresh error: token=secret '
            r'path=C:\private\worker.pdf',
      );

      expect(
        message,
        '[MinaRealtime] scope=company area=workers action=refresh_failed',
      );
      expect(message, isNot(contains('secret')));
      expect(message, isNot(contains(r'C:\private')));
      expect(message, isNot(contains('error:')));
    });
  });
}

class _KnownValue {
  const _KnownValue(this.value);

  final String value;

  @override
  String toString() => value;
}
