import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';

class DemoTransactionsRepo extends TransactionsRepo {
  DemoTransactionsRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  @override
  Future<List<TransactionModel>> getTransactions({
    required String companyId,
  }) async {
    final transactionsData = await _storage.readJsonList(
      DemoStorageKeys.transactions,
    );

    final transactions = transactionsData
        .where((item) {
          return item['company_id'] == companyId;
        })
        .map(TransactionModel.fromJson)
        .toList();

    transactions.sort((first, second) {
      return second.dateTime.compareTo(first.dateTime);
    });

    return transactions;
  }

  @override
  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  }) async {
    final transactionsData = await _storage.readJsonList(
      DemoStorageKeys.transactions,
    );

    final now = DateTime.now().toIso8601String();

    final transactionId = transaction.id?.trim().isNotEmpty == true
        ? transaction.id!.trim()
        : 'demo-trx-${DateTime.now().microsecondsSinceEpoch}';

    final transactionCode = transaction.transactionCode.trim().isNotEmpty
        ? transaction.transactionCode.trim()
        : _generateNextTransactionCode(transactionsData);

    final savedJson = _transactionToJson(
      transaction.copyWith(
        id: transactionId,
        companyId: transaction.companyId ?? DemoSeedService.demoCompanyId,
        transactionCode: transactionCode,
        dateTime: DateTime.parse(now),
        createdByProfileId: DemoSeedService.demoProfileId,
        createdByProfileName: 'Demo User',
        createdByProfileEmail: 'demo@mina-system.local',
        updatedAt: DateTime.parse(now),
      ),
      createdAt: now,
      updatedAt: now,
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.transactions,
      value: [savedJson, ...transactionsData],
    );

    return TransactionModel.fromJson(savedJson);
  }

  String _generateNextTransactionCode(List<Map<String, dynamic>> transactions) {
    var maxNumber = 0;

    for (final transaction in transactions) {
      final code = transaction['transaction_code'] as String?;
      final number = _extractEndingNumber(code);

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;

    return 'TRX-${nextNumber.toString().padLeft(3, '0')}';
  }

  Map<String, dynamic> _transactionToJson(
    TransactionModel transaction, {
    required String createdAt,
    required String updatedAt,
  }) {
    return {
      'id': transaction.id,
      'company_id': transaction.companyId ?? DemoSeedService.demoCompanyId,
      'transaction_code': transaction.transactionCode,
      'transaction_type': _transactionTypeToJson(transaction.type),
      'worker_id': transaction.workerId,
      'worker_hr_code_snapshot': transaction.workerHrCode,
      'worker_name_snapshot': transaction.workerName,
      'worker_department_snapshot': transaction.workerDepartment,
      'worker_job_title_snapshot': transaction.workerJobTitle,
      'tool_id': transaction.toolId,
      'tool_code_snapshot': transaction.toolCode,
      'tool_name_snapshot': transaction.toolName,
      'tool_unit_snapshot': transaction.unit,
      'tool_category_snapshot': transaction.toolCategory,
      'quantity': transaction.quantity,
      'created_at': createdAt,
      'proof_image_path': transaction.imagePath,
      'note': transaction.note,
      'approval_required': transaction.approvalRequired,
      'approval_status': transaction.approvalStatus,
      'approval_document_path': transaction.approvalDocumentPath,
      'settlement_status': transaction.settlementStatus,
      'settlement_note': transaction.settlementNote,
      'created_by_profile_id':
          transaction.createdByProfileId ?? DemoSeedService.demoProfileId,
      'created_by_name_snapshot':
          transaction.createdByProfileName ?? 'Demo User',
      'created_by_email_snapshot':
          transaction.createdByProfileEmail ?? 'demo@mina-system.local',
      'proof_image_uploaded_by_profile_id':
          transaction.proofImageUploadedByProfileId,
      'proof_image_uploaded_by_name_snapshot':
          transaction.proofImageUploadedByProfileName,
      'proof_image_uploaded_by_email_snapshot':
          transaction.proofImageUploadedByProfileEmail,
      'proof_image_uploaded_at': transaction.proofImageUploadedAt
          ?.toIso8601String(),
      'updated_by_profile_id': transaction.updatedByProfileId,
      'updated_by_name_snapshot': transaction.updatedByProfileName,
      'updated_by_email_snapshot': transaction.updatedByProfileEmail,
      'updated_at': updatedAt,
      'is_voided': transaction.isVoided,
      'voided_at': transaction.voidedAt?.toIso8601String(),
      'voided_by_profile_id': transaction.voidedByProfileId,
      'voided_by_name_snapshot': transaction.voidedByProfileName,
      'voided_by_email_snapshot': transaction.voidedByProfileEmail,
      'void_reason': transaction.voidReason,
    };
  }

  String _transactionTypeToJson(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return 'issue';
      case TransactionType.returnTool:
        return 'return';
      case TransactionType.lost:
        return 'lost';
      case TransactionType.damaged:
        return 'damaged';
    }
  }

  int _extractEndingNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }

    final match = RegExp(r'(\d+)$').firstMatch(value.trim());

    if (match == null) {
      return 0;
    }

    return int.tryParse(match.group(1) ?? '') ?? 0;
  }
}
