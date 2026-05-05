import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';

class TransactionsRepo {
  TransactionsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _proofsBucket = 'transaction-proofs';

  Future<List<TransactionModel>> getTransactions({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('transactions')
        .select('''
          id,
          company_id,
          transaction_code,
          transaction_type,
          worker_id,
          worker_hr_code_snapshot,
          worker_name_snapshot,
          worker_department_snapshot,
          worker_job_title_snapshot,
          tool_id,
          tool_code_snapshot,
          tool_name_snapshot,
          tool_unit_snapshot,
          tool_category_snapshot,
          quantity,
          proof_image_path,
          note,
          approval_required,
          approval_status,
          created_by_profile_id,
          created_at,
          updated_at
        ''')
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return data.map((item) {
      return TransactionModel.fromJson(item);
    }).toList();
  }

  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  }) async {
    final transactionToInsert = await _prepareTransactionProofImage(
      transaction,
    );

    final data = await _supabase
        .from('transactions')
        .insert(transactionToInsert.toInsertJson())
        .select('''
          id,
          company_id,
          transaction_code,
          transaction_type,
          worker_id,
          worker_hr_code_snapshot,
          worker_name_snapshot,
          worker_department_snapshot,
          worker_job_title_snapshot,
          tool_id,
          tool_code_snapshot,
          tool_name_snapshot,
          tool_unit_snapshot,
          tool_category_snapshot,
          quantity,
          proof_image_path,
          note,
          approval_required,
          approval_status,
          created_by_profile_id,
          created_at,
          updated_at
        ''')
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> updateTransaction({
    required String transactionId,
    required TransactionModel transaction,
  }) async {
    final transactionToUpdate = await _prepareTransactionProofImage(
      transaction,
    );

    final data = await _supabase
        .from('transactions')
        .update(transactionToUpdate.toUpdateJson())
        .eq('id', transactionId)
        .select('''
          id,
          company_id,
          transaction_code,
          transaction_type,
          worker_id,
          worker_hr_code_snapshot,
          worker_name_snapshot,
          worker_department_snapshot,
          worker_job_title_snapshot,
          tool_id,
          tool_code_snapshot,
          tool_name_snapshot,
          tool_unit_snapshot,
          tool_category_snapshot,
          quantity,
          proof_image_path,
          note,
          approval_required,
          approval_status,
          created_by_profile_id,
          created_at,
          updated_at
        ''')
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<String> generateNextTransactionCode({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('transactions')
        .select('transaction_code')
        .eq('company_id', companyId);

    var maxNumber = 0;

    for (final item in data) {
      final transactionCode = item['transaction_code'] as String?;
      final number = _extractEndingNumber(transactionCode);

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;
    return 'TRX-${nextNumber.toString().padLeft(3, '0')}';
  }

  Future<bool> transactionCodeExists({
    required String companyId,
    required String transactionCode,
    String? ignoredTransactionId,
  }) async {
    final cleanTransactionCode = transactionCode.trim();

    if (cleanTransactionCode.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('transactions')
        .select('id, transaction_code')
        .eq('company_id', companyId);

    return data.any((item) {
      final transactionId = item['id'] as String?;
      final existingTransactionCode = item['transaction_code'] as String?;

      if (ignoredTransactionId != null &&
          transactionId == ignoredTransactionId) {
        return false;
      }

      return _isSameTransactionCode(
        existingTransactionCode,
        cleanTransactionCode,
      );
    });
  }

  Future<TransactionModel> _prepareTransactionProofImage(
    TransactionModel transaction,
  ) async {
    final companyId = transaction.companyId;
    final imagePath = transaction.imagePath;

    if (companyId == null || companyId.trim().isEmpty) {
      return transaction;
    }

    if (imagePath == null || imagePath.trim().isEmpty) {
      return transaction;
    }

    if (_isCloudStoragePath(imagePath, companyId: companyId)) {
      return transaction;
    }

    final uploadedPath = await _uploadProofImage(
      companyId: companyId,
      transactionCode: transaction.transactionCode,
      localImagePath: imagePath,
    );

    return transaction.copyWith(imagePath: uploadedPath);
  }

  Future<String> _uploadProofImage({
    required String companyId,
    required String transactionCode,
    required String localImagePath,
  }) async {
    final file = File(localImagePath);

    if (!file.existsSync()) {
      throw StateError('Proof image file was not found.');
    }

    final bytes = await file.readAsBytes();
    final extension = _getFileExtension(localImagePath);
    final contentType = _getContentType(extension);

    final filePath =
        '$companyId/transactions/$transactionCode/proof-${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from(_proofsBucket)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    return filePath;
  }

  bool _isCloudStoragePath(String path, {required String companyId}) {
    return path.trim().startsWith('$companyId/');
  }

  String _getFileExtension(String path) {
    final cleanPath = path.split('?').first;
    final parts = cleanPath.split('.');

    if (parts.length < 2) {
      return 'jpg';
    }

    return parts.last.trim().toLowerCase();
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  bool _isSameTransactionCode(String? firstValue, String secondValue) {
    if (firstValue == null) {
      return false;
    }

    return _normalizeTransactionCode(firstValue) ==
        _normalizeTransactionCode(secondValue);
  }

  String _normalizeTransactionCode(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
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
