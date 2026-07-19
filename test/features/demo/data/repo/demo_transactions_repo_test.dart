import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/demo/data/demo_limits.dart';
import 'package:mina_system/features/demo/data/repo/demo_transactions_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DemoTransactionsRepo', () {
    test('filters by company and sorts newest transactions first', () async {
      _seedTransactions([
        _transactionJson(
          id: 'trx-old',
          companyId: 'company-1',
          code: 'TRX-001',
          type: TransactionType.issue,
          createdAt: '2026-01-01T00:00:00.000Z',
        ),
        _transactionJson(
          id: 'trx-new',
          companyId: 'company-1',
          code: 'TRX-002',
          type: TransactionType.returnTool,
          createdAt: '2026-01-02T00:00:00.000Z',
        ),
        _transactionJson(
          id: 'trx-other',
          companyId: 'company-2',
          code: 'TRX-001',
          type: TransactionType.issue,
          createdAt: '2026-01-03T00:00:00.000Z',
        ),
      ]);

      final transactions = await DemoTransactionsRepo().getTransactions(
        companyId: 'company-1',
      );

      expect(transactions.map((transaction) => transaction.id), [
        'trx-new',
        'trx-old',
      ]);
    });

    test('generates codes and persists issue and return transactions', () async {
      _seedTransactions([
        _transactionJson(
          id: 'trx-1',
          companyId: 'company-1',
          code: 'TRX-001',
          type: TransactionType.issue,
          createdAt: '2026-01-01T00:00:00.000Z',
        ),
        _transactionJson(
          id: 'trx-9',
          companyId: 'company-1',
          code: 'TRX-009',
          type: TransactionType.returnTool,
          createdAt: '2026-01-02T00:00:00.000Z',
        ),
      ]);

      final repo = DemoTransactionsRepo();

      expect(
        await repo.generateNextTransactionCode(companyId: 'company-1'),
        'TRX-010',
      );

      final addedIssue = await repo.addTransaction(
        transaction: _transaction(
          companyId: 'company-1',
          code: '',
          type: TransactionType.issue,
        ),
      );
      final addedReturn = await repo.addTransaction(
        transaction: _transaction(
          companyId: 'company-1',
          code: 'TRX-011',
          type: TransactionType.returnTool,
        ),
      );

      expect(addedIssue.transactionCode, 'TRX-010');
      expect(addedReturn.transactionCode, 'TRX-011');
      expect(
        await repo.transactionCodeExists(
          companyId: 'company-1',
          transactionCode: ' trx-010 ',
        ),
        isTrue,
      );

      final persisted = await repo.getTransactions(companyId: 'company-1');
      expect(persisted, hasLength(4));
      expect(persisted.where((transaction) => transaction.isIssue), hasLength(2));
      expect(persisted.where((transaction) => transaction.isReturn), hasLength(2));
    });

    test('applies lost and damaged approval state transitions', () async {
      final repo = DemoTransactionsRepo();

      final lost = await repo.addTransaction(
        transaction: _transaction(
          companyId: 'company-1',
          code: 'TRX-001',
          type: TransactionType.lost,
        ),
      );

      expect(lost.approvalRequired, isTrue);
      expect(lost.approvalStatus, 'pending');
      expect(lost.settlementStatus, 'not_required');

      final withDocument = await repo.uploadApprovalDocument(
        transaction: lost,
        localDocumentPath: r'C:\temp\approval.pdf',
      );
      expect(withDocument.approvalDocumentPath, r'C:\temp\approval.pdf');
      expect(withDocument.approvalStatus, 'pending');

      final approved = await repo.approveLostDamagedTransaction(
        transaction: withDocument,
        decisionNote: 'Approved for settlement',
      );
      expect(approved.approvalStatus, 'approved');
      expect(approved.settlementStatus, 'pending_settlement');

      final settled = await repo.settleApprovedLostDamagedTransaction(
        transaction: approved,
        settlementNote: 'Recovered from payroll',
      );
      expect(settled.settlementStatus, 'settled');
      expect(settled.settlementNote, 'Recovered from payroll');

      final damaged = await repo.addTransaction(
        transaction: _transaction(
          companyId: 'company-1',
          code: 'TRX-002',
          type: TransactionType.damaged,
        ),
      );
      final rejected = await repo.rejectLostDamagedTransaction(
        transaction: damaged,
        decisionNote: 'Normal wear',
      );

      expect(rejected.approvalStatus, 'rejected');
      expect(rejected.settlementStatus, 'not_required');
    });

    test('rejects an empty approval document path', () async {
      final repo = DemoTransactionsRepo();
      final lost = await repo.addTransaction(
        transaction: _transaction(
          companyId: 'company-1',
          code: 'TRX-001',
          type: TransactionType.lost,
        ),
      );

      expect(
        repo.uploadApprovalDocument(
          transaction: lost,
          localDocumentPath: '   ',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Approval document path was not found.',
          ),
        ),
      );
    });

    test('enforces the transaction limit per company', () async {
      _seedTransactions([
        for (var index = 1; index <= DemoLimits.maxTransactions; index++)
          _transactionJson(
            id: 'trx-$index',
            companyId: 'company-1',
            code: 'TRX-${index.toString().padLeft(3, '0')}',
            type: TransactionType.issue,
            createdAt: '2026-01-01T00:00:00.000Z',
          ),
      ]);

      final repo = DemoTransactionsRepo();

      expect(
        repo.addTransaction(
          transaction: _transaction(
            companyId: 'company-1',
            code: 'TRX-051',
            type: TransactionType.issue,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            DemoLimits.transactionsLimitMessage(),
          ),
        ),
      );
    });
  });
}

void _seedTransactions(List<Map<String, dynamic>> transactions) {
  SharedPreferences.setMockInitialValues({
    DemoStorageKeys.transactions: jsonEncode(transactions),
  });
}

TransactionModel _transaction({
  required String companyId,
  required String code,
  required TransactionType type,
}) {
  return TransactionModel(
    companyId: companyId,
    transactionCode: code,
    type: type,
    workerId: 'worker-1',
    workerHrCode: 'HR-001',
    workerName: 'Mina Adly',
    workerDepartment: 'Stores',
    workerJobTitle: 'Storekeeper',
    toolId: 'tool-1',
    toolCode: 'TOOL-001',
    toolName: 'Angle Grinder',
    unit: 'No.',
    toolCategory: 'Power Tools',
    quantity: 1,
    dateTime: DateTime.utc(2026, 1, 1),
  );
}

Map<String, dynamic> _transactionJson({
  required String id,
  required String companyId,
  required String code,
  required TransactionType type,
  required String createdAt,
}) {
  return {
    'id': id,
    'company_id': companyId,
    'transaction_code': code,
    'transaction_type': _transactionTypeValue(type),
    'worker_id': 'worker-1',
    'worker_hr_code_snapshot': 'HR-001',
    'worker_name_snapshot': 'Mina Adly',
    'worker_department_snapshot': 'Stores',
    'worker_job_title_snapshot': 'Storekeeper',
    'tool_id': 'tool-1',
    'tool_code_snapshot': 'TOOL-001',
    'tool_name_snapshot': 'Angle Grinder',
    'tool_unit_snapshot': 'No.',
    'tool_category_snapshot': 'Power Tools',
    'quantity': 1,
    'created_at': createdAt,
    'updated_at': createdAt,
  };
}

String _transactionTypeValue(TransactionType type) {
  return switch (type) {
    TransactionType.issue => 'issue',
    TransactionType.returnTool => 'return',
    TransactionType.lost => 'lost',
    TransactionType.damaged => 'damaged',
  };
}
