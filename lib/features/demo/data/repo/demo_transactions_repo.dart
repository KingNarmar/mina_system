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

    var shouldPersistNormalizedData = false;

    final normalizedTransactionsData = transactionsData
        .map((item) {
          final normalizedItem = _normalizeDemoApprovalWorkflow(item);

          if (!_areMapsShallowEqual(item, normalizedItem)) {
            shouldPersistNormalizedData = true;
          }

          return normalizedItem;
        })
        .toList(growable: false);

    if (shouldPersistNormalizedData) {
      await _storage.writeJsonList(
        key: DemoStorageKeys.transactions,
        value: normalizedTransactionsData,
      );
    }

    final transactions = normalizedTransactionsData
        .where((item) => item['company_id'] == companyId)
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

    final transactionToSave = _applyDemoApprovalDefaults(
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
    );

    final savedJson = _transactionToJson(
      transactionToSave,
      createdAt: now,
      updatedAt: now,
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.transactions,
      value: [savedJson, ...transactionsData],
    );

    return TransactionModel.fromJson(savedJson);
  }

  @override
  Future<TransactionModel> uploadApprovalDocument({
    required TransactionModel transaction,
    required String localDocumentPath,
  }) async {
    final cleanPath = localDocumentPath.trim();

    if (cleanPath.isEmpty) {
      throw StateError('Approval document path was not found.');
    }

    final now = DateTime.now();

    final updatedTransaction = transaction.copyWith(
      approvalRequired: true,
      approvalStatus: 'pending',
      approvalDocumentPath: cleanPath,
      approvalDocumentUploadedByProfileId: DemoSeedService.demoProfileId,
      approvalDocumentUploadedByProfileName: 'Demo User',
      approvalDocumentUploadedByProfileEmail: 'demo@mina-system.local',
      approvalDocumentUploadedAt: now,
      updatedByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      updatedAt: now,
    );

    return _replaceTransaction(updatedTransaction);
  }

  @override
  Future<String> createApprovalDocumentSignedUrl({
    required TransactionModel transaction,
    int expiresInSeconds = 60 * 10,
  }) async {
    final documentPath = transaction.approvalDocumentPath?.trim();

    if (documentPath == null || documentPath.isEmpty) {
      throw StateError('Signed approval document was not found.');
    }

    return documentPath;
  }

  @override
  Future<TransactionModel> approveLostDamagedTransaction({
    required TransactionModel transaction,
    String? decisionNote,
  }) async {
    final now = DateTime.now();

    final updatedTransaction = transaction.copyWith(
      approvalRequired: true,
      approvalStatus: 'approved',
      approvalDecisionNote: decisionNote,
      approvalDecidedByProfileId: DemoSeedService.demoProfileId,
      approvalDecidedByProfileName: 'Demo User',
      approvalDecidedByProfileEmail: 'demo@mina-system.local',
      approvalDecidedAt: now,
      settlementStatus: 'pending_settlement',
      updatedByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      updatedAt: now,
    );

    return _replaceTransaction(updatedTransaction);
  }

  @override
  Future<TransactionModel> rejectLostDamagedTransaction({
    required TransactionModel transaction,
    String? decisionNote,
  }) async {
    final now = DateTime.now();

    final updatedTransaction = transaction.copyWith(
      approvalRequired: true,
      approvalStatus: 'rejected',
      approvalDecisionNote: decisionNote,
      approvalDecidedByProfileId: DemoSeedService.demoProfileId,
      approvalDecidedByProfileName: 'Demo User',
      approvalDecidedByProfileEmail: 'demo@mina-system.local',
      approvalDecidedAt: now,
      settlementStatus: 'not_required',
      updatedByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      updatedAt: now,
    );

    return _replaceTransaction(updatedTransaction);
  }

  @override
  Future<TransactionModel> settleApprovedLostDamagedTransaction({
    required TransactionModel transaction,
    String? settlementNote,
  }) async {
    final now = DateTime.now();

    final updatedTransaction = transaction.copyWith(
      settlementStatus: 'settled',
      settlementNote: settlementNote,
      settledByProfileId: DemoSeedService.demoProfileId,
      settledByProfileName: 'Demo User',
      settledByProfileEmail: 'demo@mina-system.local',
      settledAt: now,
      updatedByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      updatedAt: now,
    );

    return _replaceTransaction(updatedTransaction);
  }

  @override
  Future<String> generateNextTransactionCode({
    required String companyId,
  }) async {
    final transactionsData = await _storage.readJsonList(
      DemoStorageKeys.transactions,
    );

    return _generateNextTransactionCode(transactionsData);
  }

  @override
  Future<bool> transactionCodeExists({
    required String companyId,
    required String transactionCode,
    String? ignoredTransactionId,
  }) async {
    final transactionsData = await _storage.readJsonList(
      DemoStorageKeys.transactions,
    );

    final cleanCode = transactionCode.trim().toLowerCase();

    return transactionsData.any((item) {
      if (item['company_id'] != companyId) {
        return false;
      }

      if (ignoredTransactionId != null && item['id'] == ignoredTransactionId) {
        return false;
      }

      final itemCode = item['transaction_code']
          ?.toString()
          .trim()
          .toLowerCase();

      return itemCode == cleanCode;
    });
  }

  Future<TransactionModel> _replaceTransaction(
    TransactionModel updatedTransaction,
  ) async {
    final transactionId = updatedTransaction.id?.trim();

    if (transactionId == null || transactionId.isEmpty) {
      throw StateError('Transaction ID was not found.');
    }

    final transactionsData = await _storage.readJsonList(
      DemoStorageKeys.transactions,
    );

    final now = DateTime.now().toIso8601String();

    Map<String, dynamic>? savedJson;

    final updatedTransactions = transactionsData
        .map((item) {
          if (item['id'] != transactionId) {
            return item;
          }

          final createdAt = item['created_at'] as String? ?? now;

          savedJson = _transactionToJson(
            updatedTransaction,
            createdAt: createdAt,
            updatedAt: now,
          );

          return savedJson!;
        })
        .toList(growable: false);

    if (savedJson == null) {
      throw StateError('Demo transaction was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.transactions,
      value: updatedTransactions,
    );

    return TransactionModel.fromJson(savedJson!);
  }

  TransactionModel _applyDemoApprovalDefaults(TransactionModel transaction) {
    if (!transaction.isLostOrDamaged) {
      return transaction.copyWith(
        approvalRequired: false,
        approvalStatus: 'not_required',
        settlementStatus: 'not_required',
      );
    }

    if (transaction.isApprovalApproved ||
        transaction.isApprovalRejected ||
        transaction.isApprovalPending) {
      return transaction.copyWith(approvalRequired: true);
    }

    return transaction.copyWith(
      approvalRequired: true,
      approvalStatus: 'pending',
      settlementStatus: 'not_required',
    );
  }

  Map<String, dynamic> _normalizeDemoApprovalWorkflow(
    Map<String, dynamic> transactionJson,
  ) {
    final transactionType = transactionJson['transaction_type'] as String?;

    final isLostOrDamaged =
        transactionType == 'lost' || transactionType == 'damaged';

    if (!isLostOrDamaged) {
      return {
        ...transactionJson,
        'approval_required': false,
        'approval_status': 'not_required',
        'settlement_status': 'not_required',
      };
    }

    final approvalStatus = (transactionJson['approval_status'] as String?)
        ?.trim()
        .toLowerCase();

    final hasValidApprovalStatus =
        approvalStatus == 'pending' ||
        approvalStatus == 'approved' ||
        approvalStatus == 'rejected';

    if (hasValidApprovalStatus) {
      return {...transactionJson, 'approval_required': true};
    }

    return {
      ...transactionJson,
      'approval_required': true,
      'approval_status': 'pending',
      'settlement_status': 'not_required',
    };
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
      'approval_document_uploaded_by_profile_id':
          transaction.approvalDocumentUploadedByProfileId,
      'approval_document_uploaded_by_name_snapshot':
          transaction.approvalDocumentUploadedByProfileName,
      'approval_document_uploaded_by_email_snapshot':
          transaction.approvalDocumentUploadedByProfileEmail,
      'approval_document_uploaded_at': transaction.approvalDocumentUploadedAt
          ?.toIso8601String(),
      'approval_decision_note': transaction.approvalDecisionNote,
      'approval_decided_by_profile_id': transaction.approvalDecidedByProfileId,
      'approval_decided_by_name_snapshot':
          transaction.approvalDecidedByProfileName,
      'approval_decided_by_email_snapshot':
          transaction.approvalDecidedByProfileEmail,
      'approval_decided_at': transaction.approvalDecidedAt?.toIso8601String(),
      'settlement_status': transaction.settlementStatus,
      'settlement_note': transaction.settlementNote,
      'settled_by_profile_id': transaction.settledByProfileId,
      'settled_by_name_snapshot': transaction.settledByProfileName,
      'settled_by_email_snapshot': transaction.settledByProfileEmail,
      'settled_at': transaction.settledAt?.toIso8601String(),
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

  bool _areMapsShallowEqual(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    if (first.length != second.length) {
      return false;
    }

    for (final key in first.keys) {
      if (first[key] != second[key]) {
        return false;
      }
    }

    return true;
  }
}
