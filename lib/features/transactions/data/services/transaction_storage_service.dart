import 'dart:io';
import 'dart:typed_data';

import 'package:mina_system/core/services/image_compression_service.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionStorageService {
  TransactionStorageService({
    SupabaseClient? supabaseClient,
    ImageCompressionService imageCompressionService =
        const ImageCompressionService(),
    NetworkStatusService? networkStatusService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _imageCompressionService = imageCompressionService,
       _networkStatusService = networkStatusService ?? NetworkStatusService();

  final SupabaseClient _supabase;
  final ImageCompressionService _imageCompressionService;
  final NetworkStatusService _networkStatusService;

  static const String proofsBucket = 'transaction-proofs';
  static const String approvalDocumentsBucket =
      'transaction-approval-documents';

  Future<String> uploadProofImage({
    required String companyId,
    required String transactionCode,
    required String localImagePath,
  }) async {
    await _networkStatusService.ensureOnline();

    final file = File(localImagePath);

    if (!file.existsSync()) {
      throw StateError('Proof image file was not found.');
    }

    final compressedImage = await _imageCompressionService.compressImageFile(
      file,
    );

    final filePath =
        '$companyId/transactions/$transactionCode/proof-${DateTime.now().millisecondsSinceEpoch}.${compressedImage.extension}';

    await _supabase.storage
        .from(proofsBucket)
        .uploadBinary(
          filePath,
          compressedImage.bytes,
          fileOptions: FileOptions(
            contentType: compressedImage.contentType,
            upsert: false,
          ),
        );

    return filePath;
  }

  Future<String> uploadApprovalDocumentFile({
    required String companyId,
    required String transactionCode,
    required String localDocumentPath,
  }) async {
    await _networkStatusService.ensureOnline();

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

    final ApprovalDocumentUploadData uploadData =
        await _prepareApprovalDocumentUploadData(
          file: file,
          extension: extension,
        );

    final filePath =
        '$companyId/transactions/$transactionCode/approval-document-${DateTime.now().millisecondsSinceEpoch}.${uploadData.extension}';

    await _supabase.storage
        .from(approvalDocumentsBucket)
        .uploadBinary(
          filePath,
          uploadData.bytes,
          fileOptions: FileOptions(
            contentType: uploadData.contentType,
            upsert: false,
          ),
        );

    return filePath;
  }

  Future<ApprovalDocumentUploadData> _prepareApprovalDocumentUploadData({
    required File file,
    required String extension,
  }) async {
    if (extension == 'pdf') {
      return ApprovalDocumentUploadData(
        bytes: await file.readAsBytes(),
        extension: extension,
        contentType: getContentType(extension),
      );
    }

    final compressedImage = await _imageCompressionService.compressImageFile(
      file,
    );

    return ApprovalDocumentUploadData(
      bytes: compressedImage.bytes,
      extension: compressedImage.extension,
      contentType: compressedImage.contentType,
    );
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

class ApprovalDocumentUploadData {
  const ApprovalDocumentUploadData({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
}
