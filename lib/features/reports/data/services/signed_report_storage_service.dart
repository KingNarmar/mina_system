import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignedReportStorageService {
  SignedReportStorageService({
    SupabaseClient? supabaseClient,
    NetworkStatusService? networkStatusService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _networkStatusService = networkStatusService ?? NetworkStatusService();

  static const String custodyDocumentsBucket = 'custody-documents';

  final SupabaseClient _supabase;
  final NetworkStatusService _networkStatusService;

  Future<SignedReportUploadResult> uploadSignedReportPdf({
    required String companyId,
    required String reportType,
    required String reportNumber,
    required Uint8List pdfBytes,
  }) async {
    await _networkStatusService.ensureOnline();

    final cleanCompanyId = companyId.trim();
    final cleanReportType = reportType.trim();
    final cleanReportNumber = reportNumber.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanReportType.isEmpty) {
      throw StateError('Report type was not found.');
    }

    if (cleanReportNumber.isEmpty) {
      throw StateError('Report number was not found.');
    }

    if (pdfBytes.isEmpty) {
      throw StateError('Signed PDF bytes are empty.');
    }

    final fileHash = sha256.convert(pdfBytes).toString();
    final safeReportType = _sanitizeStorageSegment(cleanReportType);
    final safeReportNumber = _sanitizeStorageSegment(cleanReportNumber);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final fileName = '$safeReportNumber-$timestamp.pdf';
    final filePath = '$cleanCompanyId/signed-reports/$safeReportType/$fileName';

    await _supabase.storage
        .from(custodyDocumentsBucket)
        .uploadBinary(
          filePath,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: false,
          ),
        );

    return SignedReportUploadResult(
      storageBucket: custodyDocumentsBucket,
      filePath: filePath,
      fileName: fileName,
      fileSize: pdfBytes.length,
      fileHash: fileHash,
    );
  }

  Future<void> deleteSignedReportPdfIfOrphan({required String filePath}) async {
    final cleanPath = filePath.trim();

    if (cleanPath.isEmpty) {
      return;
    }

    await _supabase.storage.from(custodyDocumentsBucket).remove([cleanPath]);
  }

  Future<String> createSignedReportUrl({
    required String filePath,
    int expiresInSeconds = 60 * 10,
  }) async {
    final cleanPath = filePath.trim();

    if (cleanPath.isEmpty) {
      throw StateError('Signed report file path was not found.');
    }

    return _supabase.storage
        .from(custodyDocumentsBucket)
        .createSignedUrl(cleanPath, expiresInSeconds);
  }

  String _sanitizeStorageSegment(String value) {
    final normalized = value.trim().toLowerCase();

    final safeValue = normalized
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (safeValue.isEmpty) {
      return 'signed-report';
    }

    return safeValue;
  }
}

class SignedReportUploadResult {
  const SignedReportUploadResult({
    required this.storageBucket,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.fileHash,
  });

  final String storageBucket;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String fileHash;
}
