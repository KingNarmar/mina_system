import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/data/models/signed_report_model.dart';
import 'package:mina_system/features/reports/data/repo/signed_reports_repo.dart';
import 'package:path_provider/path_provider.dart';

class DemoSignedReportsRepo extends SignedReportsRepo {
  DemoSignedReportsRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  static const String _storageBucket = 'demo_local_signed_reports';

  @override
  Future<List<SignedReportModel>> getSignedReports({
    required String companyId,
    String? searchTerm,
    String? reportType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 200,
  }) async {
    final metadata = await _storage.readJsonList(
      DemoStorageKeys.signedReportsMetadata,
    );

    final cleanCompanyId = companyId.trim();
    final cleanSearchTerm = searchTerm?.trim().toLowerCase();
    final cleanReportType = reportType?.trim();

    final reports = metadata
        .where((item) => item['company_id'] == cleanCompanyId)
        .where((item) {
          if (cleanReportType == null || cleanReportType.isEmpty) {
            return true;
          }

          return item['report_type'] == cleanReportType;
        })
        .where((item) {
          if (dateFrom == null && dateTo == null) {
            return true;
          }

          final signedAt = DateTime.tryParse(
            item['signed_at']?.toString() ?? '',
          );

          if (signedAt == null) {
            return false;
          }

          if (dateFrom != null && signedAt.isBefore(_startOfDay(dateFrom))) {
            return false;
          }

          if (dateTo != null && signedAt.isAfter(_endOfDay(dateTo))) {
            return false;
          }

          return true;
        })
        .map(SignedReportModel.fromJson)
        .where((report) {
          if (cleanSearchTerm == null || cleanSearchTerm.isEmpty) {
            return true;
          }

          return _matchesSearchTerm(
            report: report,
            searchTerm: cleanSearchTerm,
          );
        })
        .toList();

    reports.sort((first, second) {
      return second.signedAt.compareTo(first.signedAt);
    });

    return reports.take(limit).toList(growable: false);
  }

  @override
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
    final cleanCompanyId = companyId.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    final reportTypeValue = SignedReportModel.reportTypeToDatabaseValue(
      reportType,
    );

    final directory = await _getDemoSignedReportsDirectory(
      companyId: cleanCompanyId,
    );

    final fileName = '${_sanitizeFileName(reportNumber)}.pdf';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(signedPdfBytes, flush: true);

    final fileHash = sha256.convert(signedPdfBytes).toString();
    final now = DateTime.now();

    final signedReportJson = <String, dynamic>{
      'id': 'demo-signed-report-${now.microsecondsSinceEpoch}',
      'company_id': cleanCompanyId,
      'transaction_id': transactionId,
      'worker_id': workerId,
      'report_type': reportTypeValue,
      'report_number': reportNumber,
      'storage_bucket': _storageBucket,
      'file_path': file.path,
      'file_name': fileName,
      'file_size': signedPdfBytes.length,
      'file_hash': fileHash,
      'signed_by_name': signedByName.trim(),
      'signed_at': signedAt.toIso8601String(),
      'signature_input_method': signatureInputMethod,
      'signature_platform': signaturePlatform,
      'worker_name_snapshot': filters.worker?.name,
      'worker_hr_code_snapshot': filters.worker?.hrCode,
      'transaction_code_snapshot': null,
      'filters_snapshot': _buildFiltersSnapshot(filters),
      'transaction_ids_snapshot': transactionIds,
      'created_by_profile_id': DemoSeedService.demoProfileId,
      'created_by_name_snapshot': 'Demo User',
      'created_by_email_snapshot': 'demo@mina-system.local',
      'created_at': now.toIso8601String(),
    };

    final metadata = await _storage.readJsonList(
      DemoStorageKeys.signedReportsMetadata,
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.signedReportsMetadata,
      value: [signedReportJson, ...metadata],
    );

    return SignedReportModel.fromJson(signedReportJson);
  }

  @override
  Future<String> createSignedReportSignedUrl({
    required SignedReportModel signedReport,
    int expiresInSeconds = 60 * 10,
  }) async {
    final file = File(signedReport.filePath);

    if (!await file.exists()) {
      throw StateError('Demo signed PDF file was not found on this device.');
    }

    return file.uri.toString();
  }

  Future<Uint8List> readSignedReportBytes(
    SignedReportModel signedReport,
  ) async {
    final file = File(signedReport.filePath);

    if (!await file.exists()) {
      throw StateError('Demo signed PDF file was not found on this device.');
    }

    return file.readAsBytes();
  }

  Future<void> clearSignedReportFiles({required String companyId}) async {
    final directory = await _getDemoSignedReportsDirectory(
      companyId: companyId,
    );

    if (!await directory.exists()) {
      return;
    }

    await directory.delete(recursive: true);
  }

  Future<Directory> _getDemoSignedReportsDirectory({
    required String companyId,
  }) async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();

    final directory = Directory(
      '${appDocumentsDirectory.path}/mina_system_demo/$companyId/signed_reports',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
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

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
  }

  String _sanitizeFileName(String value) {
    final sanitizedValue = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    if (sanitizedValue.isEmpty) {
      return 'demo-signed-report';
    }

    return sanitizedValue;
  }
}
