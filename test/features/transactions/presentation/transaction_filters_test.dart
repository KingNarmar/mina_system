import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_filters.dart';

void main() {
  final issue = _transaction(
    id: 'trx-1',
    code: 'TRX-001',
    type: TransactionType.issue,
    workerHrCode: 'HR-001',
    workerName: 'Mina Adly',
    toolCode: 'TOOL-001',
    toolName: 'Angle Grinder',
    unit: 'No.',
  );
  final returned = _transaction(
    id: 'trx-2',
    code: 'TRX-002',
    type: TransactionType.returnTool,
    workerHrCode: 'HR-002',
    workerName: 'Worker Two',
    toolCode: 'TOOL-002',
    toolName: 'Drill Machine',
    unit: 'Set',
  );

  group('filterTransactions', () {
    test('returns all transactions for empty query and all type', () {
      final result = filterTransactions(
        transactions: [issue, returned],
        query: '  ',
        typeFilter: TransactionTypeFilter.all,
      );

      expect(result, [issue, returned]);
    });

    test('searches case-insensitively across transaction fields', () {
      expect(
        filterTransactions(
          transactions: [issue, returned],
          query: 'mina',
          typeFilter: TransactionTypeFilter.all,
        ),
        [issue],
      );
      expect(
        filterTransactions(
          transactions: [issue, returned],
          query: 'tool-002',
          typeFilter: TransactionTypeFilter.all,
        ),
        [returned],
      );
      expect(
        filterTransactions(
          transactions: [issue, returned],
          query: 'return',
          typeFilter: TransactionTypeFilter.all,
        ),
        [returned],
      );
    });

    test('combines query and transaction type filter', () {
      expect(
        filterTransactions(
          transactions: [issue, returned],
          query: 'tool',
          typeFilter: TransactionTypeFilter.issue,
        ),
        [issue],
      );
      expect(
        filterTransactions(
          transactions: [issue, returned],
          query: 'mina',
          typeFilter: TransactionTypeFilter.returnTool,
        ),
        isEmpty,
      );
    });
  });

  test('filters custody balances by worker, tool, and unit fields', () {
    const first = CustodyBalanceModel(
      workerHrCode: 'HR-001',
      workerName: 'Mina Adly',
      toolCode: 'TOOL-001',
      toolName: 'Angle Grinder',
      unit: 'No.',
      balanceQuantity: 2,
    );
    const second = CustodyBalanceModel(
      workerHrCode: 'HR-002',
      workerName: 'Worker Two',
      toolCode: 'TOOL-002',
      toolName: 'Drill Machine',
      unit: 'Set',
      balanceQuantity: 1,
    );

    expect(filterCustodyBalances([first, second], 'grinder'), [first]);
    expect(filterCustodyBalances([first, second], 'set'), [second]);
    expect(filterCustodyBalances([first, second], ''), [first, second]);
  });

  test('filters tool custody summaries by code, name, and unit', () {
    const first = ToolCustodySummaryModel(
      toolCode: 'TOOL-001',
      toolName: 'Angle Grinder',
      unit: 'No.',
      issuedQuantity: 2,
      returnedQuantity: 0,
      lostQuantity: 0,
      damagedQuantity: 0,
      openCustodyQuantity: 2,
      totalMovements: 1,
    );
    const second = ToolCustodySummaryModel(
      toolCode: 'TOOL-002',
      toolName: 'Drill Machine',
      unit: 'Set',
      issuedQuantity: 1,
      returnedQuantity: 1,
      lostQuantity: 0,
      damagedQuantity: 0,
      openCustodyQuantity: 0,
      totalMovements: 2,
    );

    expect(filterToolCustodySummaries([first, second], 'tool-001'), [first]);
    expect(filterToolCustodySummaries([first, second], 'drill'), [second]);
    expect(filterToolCustodySummaries([first, second], ''), [first, second]);
  });
}

TransactionModel _transaction({
  required String id,
  required String code,
  required TransactionType type,
  required String workerHrCode,
  required String workerName,
  required String toolCode,
  required String toolName,
  required String unit,
}) {
  return TransactionModel(
    id: id,
    companyId: 'company-1',
    transactionCode: code,
    type: type,
    workerId: 'worker-1',
    workerHrCode: workerHrCode,
    workerName: workerName,
    toolId: 'tool-1',
    toolCode: toolCode,
    toolName: toolName,
    unit: unit,
    quantity: 1,
    dateTime: DateTime.utc(2026, 1, 1),
  );
}
