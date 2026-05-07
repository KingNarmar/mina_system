import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionStorageService {
  TransactionStorageService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String proofsBucket = 'transaction-proofs';
  static const String approvalDocumentsBucket =
      'transaction-approval-documents';

  Future<String> uploadProofImage({
    required String companyId,
    required String transactionCode,
    required String localImagePath,
  }) async {
    final file = File(localImagePath);

    if (!file.existsSync()) {
      throw StateError('Proof image file was not found.');
    }

    final extension = getFileExtension(localImagePath);

    validateAllowedExtension(
      extension: extension,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      errorMessage: 'Proof image must be JPG, JPEG, PNG, or WEBP.',
    );

    final bytes = await file.readAsBytes();
    final contentType = getContentType(extension);

    final filePath =
        '$companyId/transactions/$transactionCode/proof-${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from(proofsBucket)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    return filePath;
  }

  Future<String> uploadApprovalDocumentFile({
    required String companyId,
    required String transactionCode,
    required String localDocumentPath,
  }) async {
    final file = File(localDocumentPath);

    if (!file.existsSync()) {
      throw StateError('Approval document file was not found.');
    }

    final extension = getFileExtension(localDocumentPath);

    validateAllowedExtension(
      extension: extension,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      errorMessage: 'Approval document must be PDF, JPG, JPEG, PNG, or WEBP.',
    );

    final bytes = await file.readAsBytes();
    final contentType = getContentType(extension);

    final filePath =
        '$companyId/transactions/$transactionCode/approval-document-${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from(approvalDocumentsBucket)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    return filePath;
  }

  bool isCloudStoragePath(String path, {required String companyId}) {
    return path.trim().startsWith('$companyId/');
  }

  void validateAllowedExtension({
    required String extension,
    required List<String> allowedExtensions,
    required String errorMessage,
  }) {
    if (!allowedExtensions.contains(extension.toLowerCase())) {
      throw StateError(errorMessage);
    }
  }

  String getFileExtension(String path) {
    final cleanPath = path.split('?').first;
    final parts = cleanPath.split('.');

    if (parts.length < 2) {
      return 'jpg';
    }

    return parts.last.trim().toLowerCase();
  }

  String getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
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

  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    return _supabase.storage
        .from(bucket)
        .createSignedUrl(path, expiresInSeconds);
  }
}
