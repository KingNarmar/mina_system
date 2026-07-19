import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/workers/presentation/functions/worker_form_validators.dart';

void main() {
  group('WorkerFormValidators', () {
    test('requires worker text and dropdown values', () {
      expect(
        WorkerFormValidators.requiredWorkerTextValidator('  '),
        'This field is required',
      );
      expect(
        WorkerFormValidators.requiredWorkerDropdownValidator(null),
        'Please select a value',
      );
      expect(
        WorkerFormValidators.requiredWorkerTextValidator('Worker'),
        isNull,
      );
      expect(
        WorkerFormValidators.requiredWorkerDropdownValidator('Stores'),
        isNull,
      );
    });

    test('passes trimmed HR code and ignored value to duplicate check', () {
      String? receivedHrCode;
      String? receivedIgnoredHrCode;

      final result = WorkerFormValidators.hrCodeValidator(
        ' HR-001 ',
        isHrCodeAlreadyUsed: (hrCode, {ignoredHrCode}) {
          receivedHrCode = hrCode;
          receivedIgnoredHrCode = ignoredHrCode;
          return true;
        },
        initialHrCode: 'HR-001',
      );

      expect(receivedHrCode, 'HR-001');
      expect(receivedIgnoredHrCode, 'HR-001');
      expect(result, 'HR Code already exists');
    });

    test('passes trimmed worker name and ignored id to duplicate check', () {
      String? receivedName;
      String? receivedIgnoredId;

      final result = WorkerFormValidators.workerNameValidator(
        ' Mina Adly ',
        isWorkerNameAlreadyUsed: (name, {ignoredWorkerId}) {
          receivedName = name;
          receivedIgnoredId = ignoredWorkerId;
          return true;
        },
        initialWorkerId: 'worker-1',
      );

      expect(receivedName, 'Mina Adly');
      expect(receivedIgnoredId, 'worker-1');
      expect(result, 'Worker name already exists');
    });

    test('accepts unique HR code and worker name', () {
      expect(
        WorkerFormValidators.hrCodeValidator(
          'HR-002',
          isHrCodeAlreadyUsed: (_, {ignoredHrCode}) => false,
          initialHrCode: null,
        ),
        isNull,
      );
      expect(
        WorkerFormValidators.workerNameValidator(
          'Worker Two',
          isWorkerNameAlreadyUsed: (_, {ignoredWorkerId}) => false,
          initialWorkerId: null,
        ),
        isNull,
      );
    });
  });
}
