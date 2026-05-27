import 'package:mina_system/features/reports/data/models/report_option_model.dart';

class SignedReportModel {
  const SignedReportModel({
    required this.id,
    required this.companyId,
    this.transactionId,
    this.workerId,
    required this.reportType,
    required this.reportNumber,
    required this.storageBucket,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.fileHash,
    required this.signedByName,
    required this.signedAt,
    this.signatureInputMethod,
    this.signaturePlatform,
    this.workerNameSnapshot,
    this.workerHrCodeSnapshot,
    this.transactionCodeSnapshot,
    required this.filtersSnapshot,
    required this.transactionIdsSnapshot,
    required this.createdByProfileId,
    this.createdByNameSnapshot,
    this.createdByEmailSnapshot,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String? transactionId;
  final String? workerId;

  final String reportType;
  final String reportNumber;

  final String storageBucket;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String fileHash;

  final String signedByName;
  final DateTime signedAt;

  final String? signatureInputMethod;
  final String? signaturePlatform;

  final String? workerNameSnapshot;
  final String? workerHrCodeSnapshot;
  final String? transactionCodeSnapshot;

  final Map<String, dynamic> filtersSnapshot;
  final List<dynamic> transactionIdsSnapshot;

  final String createdByProfileId;
  final String? createdByNameSnapshot;
  final String? createdByEmailSnapshot;
  final DateTime createdAt;

  String get reportTypeLabel {
    switch (reportType) {
      case 'worker_custody_report':
        return 'Worker Custody Report';
      case 'tool_history_report':
        return 'Tool History Report';
      case 'transactions_report':
        return 'Transactions Report';
      case 'lost_damaged_report':
        return 'Lost & Damaged Report';
      case 'loss_damage_report':
        return 'Lost/Damaged Approval Report';
      case 'tool_summary_report':
        return 'Tool Summary Report';
      default:
        return reportType;
    }
  }

  String get createdByDisplayName {
    final name = createdByNameSnapshot?.trim();
    final email = createdByEmailSnapshot?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'Unknown User';
  }

  factory SignedReportModel.fromJson(Map<String, dynamic> json) {
    return SignedReportModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      transactionId: json['transaction_id'] as String?,
      workerId: json['worker_id'] as String?,
      reportType: json['report_type'] as String? ?? '',
      reportNumber: json['report_number'] as String? ?? '',
      storageBucket: json['storage_bucket'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileSize: _parseInt(json['file_size']),
      fileHash: json['file_hash'] as String? ?? '',
      signedByName: json['signed_by_name'] as String? ?? '',
      signedAt: _parseDateTime(json['signed_at']) ?? DateTime.now(),
      signatureInputMethod: json['signature_input_method'] as String?,
      signaturePlatform: json['signature_platform'] as String?,
      workerNameSnapshot: json['worker_name_snapshot'] as String?,
      workerHrCodeSnapshot: json['worker_hr_code_snapshot'] as String?,
      transactionCodeSnapshot: json['transaction_code_snapshot'] as String?,
      filtersSnapshot: _parseJsonMap(json['filters_snapshot']),
      transactionIdsSnapshot: _parseJsonList(json['transaction_ids_snapshot']),
      createdByProfileId: json['created_by_profile_id'] as String? ?? '',
      createdByNameSnapshot: json['created_by_name_snapshot'] as String?,
      createdByEmailSnapshot: json['created_by_email_snapshot'] as String?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  static String reportTypeToDatabaseValue(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'worker_custody_report';
      case ReportType.toolHistory:
        return 'tool_history_report';
      case ReportType.transactions:
        return 'transactions_report';
      case ReportType.lostDamaged:
        return 'lost_damaged_report';
      case ReportType.lostDamagedApproval:
        return 'loss_damage_report';
      case ReportType.toolSummary:
        return 'tool_summary_report';
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic> _parseJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<dynamic> _parseJsonList(dynamic value) {
    if (value is List) {
      return value;
    }

    return <dynamic>[];
  }
}
