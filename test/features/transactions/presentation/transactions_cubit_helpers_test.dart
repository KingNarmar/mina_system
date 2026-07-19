import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit_helpers.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';

void main() {
  group('TransactionsCubitHelpers.applyApprovalRules', () {
    test('requires pending approval for lost and damaged transactions', () {
      final lost = _transaction(type: TransactionType.lost);
      final damaged = _transaction(type: TransactionType.damaged);

      final updatedLost = TransactionsCubitHelpers.applyApprovalRules(lost);
      final updatedDamaged = TransactionsCubitHelpers.applyApprovalRules(
        damaged,
      );

      expect(updatedLost.approvalRequired, isTrue);
      expect(updatedLost.approvalStatus, 'pending');
      expect(updatedDamaged.approvalRequired, isTrue);
      expect(updatedDamaged.approvalStatus, 'pending');
    });

    test('clears approval and settlement for issue and return transactions', () {
      final issue = _transaction(
        type: TransactionType.issue,
        approvalRequired: true,
        approvalStatus: 'approved',
        settlementStatus: 'settled',
      );
      final returned = _transaction(
        type: TransactionType.returnTool,
        approvalRequired: true,
        approvalStatus: 'pending',
        settlementStatus: 'pending_settlement',
      );

      final updatedIssue = TransactionsCubitHelpers.applyApprovalRules(issue);
      final updatedReturn = TransactionsCubitHelpers.applyApprovalRules(
        returned,
      );

      for (final transaction in [updatedIssue, updatedReturn]) {
        expect(transaction.approvalRequired, isFalse);
        expect(transaction.approvalStatus, 'not_required');
        expect(transaction.settlementStatus, 'not_required');
      }
    });
  });

  test('replaces only the saved transaction in a list', () {
    final first = _transaction(id: 'trx-1', code: 'TRX-001');
    final second = _transaction(id: 'trx-2', code: 'TRX-002');
    final saved = _transaction(
      id: 'trx-2',
      code: 'TRX-002',
      quantity: 3,
    );

    final result = TransactionsCubitHelpers.replaceTransactionInList(
      [first, second],
      saved,
    );

    expect(result.first, same(first));
    expect(result.last, same(saved));
  });

  test('updates transaction state and reapplies active filters', () {
    final grinder = _transaction(
      id: 'trx-1',
      code: 'TRX-001',
      toolName: 'Angle Grinder',
    );
    final drill = _transaction(
      id: 'trx-2',
      code: 'TRX-002',
      toolName: 'Drill Machine',
    );
    const state = TransactionsState(
      transactions: [],
      filteredTransactions: [],
      searchQuery: 'drill',
      custodyBalanceSearchQuery: '',
      toolSummarySearchQuery: '',
      typeFilter: TransactionTypeFilter.all,
      isLoading: true,
      errorMessage: 'old error',
    );

    final updated = TransactionsCubitHelpers.updateTransactionsList(
      state,
      [grinder, drill],
      isLoading: false,
    );

    expect(updated.transactions, [grinder, drill]);
    expect(updated.filteredTransactions, [drill]);
    expect(updated.isLoading, isFalse);
    expect(updated.errorMessage, isNull);
  });
}

TransactionModel _transaction({
  String id = 'trx-1',
  String code = 'TRX-001',
  TransactionType type = TransactionType.issue,
  double quantity = 1,
  String toolName = 'Angle Grinder',
  bool approvalRequired = false,
  String approvalStatus = 'not_required',
  String settlementStatus = 'not_required',
}) {
  return TransactionModel(
    id: id,
    companyId: 'company-1',
    transactionCode: code,
    type: type,
    workerId: 'worker-1',
    workerHrCode: 'HR-001',
    workerName: 'Mina Adly',
    toolId: 'tool-1',
    toolCode: 'TOOL-001',
    toolName: toolName,
    unit: 'No.',
    quantity: quantity,
    dateTime: DateTime.utc(2026, 1, 1),
    approvalRequired: approvalRequired,
    approvalStatus: approvalStatus,
    settlementStatus: settlementStatus,
  );
}
