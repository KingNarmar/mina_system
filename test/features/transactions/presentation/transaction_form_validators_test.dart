import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_validators.dart';

void main() {
  group('transaction form validators', () {
    test('requires text, dropdown, and selection values', () {
      expect(
        validateRequiredTransactionText('  '),
        'This field is required',
      );
      expect(
        validateRequiredTransactionDropdown(null),
        'Please select a value',
      );
      expect(
        validateRequiredTransactionSelection<Object>(null),
        'Please select a value',
      );

      expect(validateRequiredTransactionText('value'), isNull);
      expect(validateRequiredTransactionDropdown('value'), isNull);
      expect(validateRequiredTransactionSelection<Object>(Object()), isNull);
    });

    test('rejects invalid, zero, and negative quantities', () {
      expect(validateTransactionQuantity('abc'), 'Please enter a valid number');
      expect(
        validateTransactionQuantity('0'),
        'Quantity must be greater than zero',
      );
      expect(
        validateTransactionQuantity('-1'),
        'Quantity must be greater than zero',
      );
    });

    test('rejects return when no custody balance exists', () {
      expect(
        validateTransactionQuantity('1', maxReturnQuantity: 0),
        'This worker does not have this tool in custody',
      );
    });

    test('rejects return quantity above custody balance', () {
      expect(
        validateTransactionQuantity('3', maxReturnQuantity: 2),
        'Quantity cannot exceed current balance',
      );
    });

    test('accepts a positive quantity within custody balance', () {
      expect(validateTransactionQuantity('2', maxReturnQuantity: 2), isNull);
      expect(validateTransactionQuantity('1.5'), isNull);
    });
  });
}
