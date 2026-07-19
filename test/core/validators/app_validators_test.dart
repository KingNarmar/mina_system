import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/core/validators/app_validators.dart';

void main() {
  group('AppValidators', () {
    test('validates full name boundaries', () {
      expect(AppValidators.validateFullName(null), 'Full name is required');
      expect(AppValidators.validateFullName('   '), 'Full name is required');
      expect(AppValidators.validateFullName('A'), 'Full name is too short');
      expect(AppValidators.validateFullName('Mina Adly'), isNull);
    });

    test('validates email format', () {
      expect(AppValidators.validateEmail(null), 'Email is required');
      expect(AppValidators.validateEmail('invalid'), 'Enter a valid email address');
      expect(AppValidators.validateEmail('mina@example.com'), isNull);
    });

    test('requires email or username', () {
      expect(
        AppValidators.validateEmailOrUsername('  '),
        'Email or username is required',
      );
      expect(AppValidators.validateEmailOrUsername('mina'), isNull);
    });

    test('validates password minimum length', () {
      expect(AppValidators.validatePassword(null), 'Password is required');
      expect(
        AppValidators.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(AppValidators.validatePassword('123456'), isNull);
    });
  });
}
