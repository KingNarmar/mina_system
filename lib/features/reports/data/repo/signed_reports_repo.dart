import 'dart:typed_data';

import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/data/models/signed_report_model.dart';
import 'package:mina_system/features/reports/data/services/signed_report_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignedReportsRepo {
  SignedReportsRepo({
    SupabaseClient? supabaseClient,
    SignedReportStorageService? storageService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _storageService =
           storageService ??
           SignedReportStorageService(
             supabaseClient: supabaseClient ?? Supabase.instance.client,
           );

  final SupabaseClient _supabase;
  final SignedReportStorageService _storageService;

  static const String _signedReportSelectColumns = '''
    id,
    company_id,
    transaction_id,
    worker_id,
    report_type,
    report_number,
    storage_bucket,
    file_path,
    file_name,
    file_size,
    file_hash,
    signed_by_name,
    signed_at,
    signature_input_method,
    signature_platform,
    worker_name_snapshot,
    worker_hr_code_snapshot,
    transaction_code_snapshot,
    filters_snapshot,
    transaction_ids_snapshot,
    created_by_profile_id,
    created_by_name_snapshot,
    created_by_email_snapshot,
    created_at
  ''';

  Future<List<SignedReportModel>> getSignedReports({
    required String companyId,
    String? searchTerm,
    String? reportType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 200,
  }) async {
    final cleanCompanyId = companyId.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    dynamic query = _supabase
        .from('signed_reports')
        .select(_signedReportSelectColumns)
        .eq('company_id', cleanCompanyId);

    final cleanReportType = reportType?.trim();

    if (cleanReportType != null && cleanReportType.isNotEmpty) {
      query = query.eq('report_type', cleanReportType);
    }

    if (dateFrom != null) {
      query = query.gte('signed_at', dateFrom.toUtc().toIso8601String());
    }

    if (dateTo != null) {
      final inclusiveDateTo = DateTime(
        dateTo.year,
        dateTo.month,
        dateTo.day,
        23,
        59,
        59,
        999,
      );

      query = query.lte('signed_at', inclusiveDateTo.toUtc().toIso8601String());
    }

    final data = await query.order('signed_at', ascending: false).limit(limit);

    final reports = (data as List).map((item) {
      return SignedReportModel.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();

    final cleanSearchTerm = searchTerm?.trim().toLowerCase();

    if (cleanSearchTerm == null || cleanSearchTerm.isEmpty) {
      return reports;
    }

    return reports.where((report) {
      return _matchesSearchTerm(report: report, searchTerm: cleanSearchTerm);
    }).toList();
  }

  Future<SignedReportModel> createSignedReport({
    required String companyId,
    required ReportType reportType,
    required String reportNumber,
    required Uint8List signedPdfBytes,
    required String signedByName,
    required DateTime signedAt,
    required ReportFilterModel filters,
    String? workerId,
    String? transactionId,
    List<String> transactionIds = const [],
    String? signatureInputMethod,
    String? signaturePlatform,
  }) async {
    final reportTypeValue = SignedReportModel.reportTypeToDatabaseValue(
      reportType,
    );

    final uploadResult = await _storageService.uploadSignedReportPdf(
      companyId: companyId,
      reportType: reportTypeValue,
      reportNumber: reportNumber,
      pdfBytes: signedPdfBytes,
    );

    try {
      final rpcResult = await _supabase.rpc(
        'create_signed_report_metadata',
        params: {
          'p_company_id': companyId,
          'p_report_type': reportTypeValue,
          'p_report_number': reportNumber,
          'p_storage_bucket': uploadResult.storageBucket,
          'p_file_path': uploadResult.filePath,
          'p_file_name': uploadResult.fileName,
          'p_file_size': uploadResult.fileSize,
          'p_file_hash': uploadResult.fileHash,
          'p_signed_by_name': signedByName.trim(),
          'p_signed_at': signedAt.toUtc().toIso8601String(),
          'p_worker_id': workerId,
          'p_transaction_id': transactionId,
          'p_filters_snapshot': _buildFiltersSnapshot(filters),
          'p_transaction_ids_snapshot': transactionIds,
          'p_signature_input_method': signatureInputMethod,
          'p_signature_platform': signaturePlatform,
        },
      );

      final signedReportId = _readCreatedSignedReportId(rpcResult);

      return _fetchSignedReportById(
        companyId: companyId,
        signedReportId: signedReportId,
      );
    } catch (_) {
      await _deleteUploadedSignedReportIfUnlinked(uploadResult.filePath);
      rethrow;
    }
  }

  Future<String> createSignedReportSignedUrl({
    required SignedReportModel signedReport,
    int expiresInSeconds = 60 * 10,
  }) async {
    if (signedReport.storageBucket !=
        SignedReportStorageService.custodyDocumentsBucket) {
      throw StateError('Invalid signed report storage bucket.');
    }

    return _storageService.createSignedReportUrl(
      filePath: signedReport.filePath,
      expiresInSeconds: expiresInSeconds,
    );
  }

  Future<SignedReportModel> _fetchSignedReportById({
    required String companyId,
    required String signedReportId,
  }) async {
    final data = await _supabase
        .from('signed_reports')
        .select(_signedReportSelectColumns)
        .eq('id', signedReportId)
        .eq('company_id', companyId)
        .single();

    return SignedReportModel.fromJson(data);
  }

  Future<void> _deleteUploadedSignedReportIfUnlinked(String filePath) async {
    try {
      await _storageService.deleteSignedReportPdfIfOrphan(filePath: filePath);
    } catch (_) {
      // Best-effort cleanup must not hide the original metadata/RPC error.
    }
  }

  Map<String, dynamic> _buildFiltersSnapshot(ReportFilterModel filters) {
    return {
      'worker_id': filters.worker?.id,
      'worker_name': filters.worker?.name,
      'worker_hr_code': filters.worker?.hrCode,
      'tool_id': filters.tool?.id,
      'tool_name': filters.tool?.toolName,
      'tool_code': filters.tool?.toolCode,
      'transaction_type': filters.transactionType?.name,
      'approval_status': filters.approvalStatus,
      'date_from': filters.dateFrom?.toIso8601String(),
      'date_to': filters.dateTo?.toIso8601String(),
    };
  }

  bool _matchesSearchTerm({
    required SignedReportModel report,
    required String searchTerm,
  }) {
    final searchableValues = <String>[
      report.reportNumber,
      report.reportTypeLabel,
      report.signedByName,
      report.workerNameSnapshot ?? '',
      report.workerHrCodeSnapshot ?? '',
      report.transactionCodeSnapshot ?? '',
      report.createdByDisplayName,
      report.fileName,
    ];

    return searchableValues.any((value) {
      return value.toLowerCase().contains(searchTerm);
    });
  }

  String _readCreatedSignedReportId(dynamic rpcResult) {
    if (rpcResult is String && rpcResult.trim().isNotEmpty) {
      return rpcResult.trim();
    }

    if (rpcResult is List && rpcResult.isNotEmpty) {
      final firstItem = rpcResult.first;

      if (firstItem is String && firstItem.trim().isNotEmpty) {
        return firstItem.trim();
      }

      if (firstItem is Map<String, dynamic>) {
        final signedReportId =
            firstItem['create_signed_report_metadata'] as String? ??
            firstItem['signed_report_id'] as String? ??
            firstItem['id'] as String?;

        if (signedReportId != null && signedReportId.trim().isNotEmpty) {
          return signedReportId.trim();
        }
      }
    }

    if (rpcResult is Map<String, dynamic>) {
      final signedReportId =
          rpcResult['create_signed_report_metadata'] as String? ??
          rpcResult['signed_report_id'] as String? ??
          rpcResult['id'] as String?;

      if (signedReportId != null && signedReportId.trim().isNotEmpty) {
        return signedReportId.trim();
      }
    }

    throw StateError('Signed report ID was not returned.');
  }
}
