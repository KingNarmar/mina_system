import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/data/repo/signed_reports_repo.dart';
import 'package:mina_system/features/reports/presentation/functions/report_filter_helpers.dart';
import 'package:mina_system/features/reports/presentation/services/report_pdf_service.dart';
import 'package:mina_system/features/reports/presentation/widgets/signature_capture_dialog.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:printing/printing.dart';

void showReportPdfPreview(
  BuildContext context, {
  required String companyId,
  required ReportType reportType,
  required ReportFilterModel filters,
  required List<TransactionModel> transactions,
  required CompanyProfileModel companyProfile,
  required CompanyReportSettingsModel reportSettings,
  required List<CompanyDocumentTemplateModel> documentTemplates,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final height = MediaQuery.sizeOf(context).height;
  final isMobile = width < AppBreakpoints.tablet;

  final preview = _ReportPdfPreview(
    companyId: companyId,
    reportType: reportType,
    filters: filters,
    transactions: transactions,
    companyProfile: companyProfile,
    reportSettings: reportSettings,
    documentTemplates: documentTemplates,
  );

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) {
        return SizedBox(height: height * 0.92, child: preview);
      },
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1100, maxHeight: height * 0.9),
          child: preview,
        ),
      );
    },
  );
}

class _ReportPdfPreview extends StatefulWidget {
  const _ReportPdfPreview({
    required this.companyId,
    required this.reportType,
    required this.filters,
    required this.transactions,
    required this.companyProfile,
    required this.reportSettings,
    required this.documentTemplates,
  });

  final String companyId;
  final ReportType reportType;
  final ReportFilterModel filters;
  final List<TransactionModel> transactions;
  final CompanyProfileModel companyProfile;
  final CompanyReportSettingsModel reportSettings;
  final List<CompanyDocumentTemplateModel> documentTemplates;

  @override
  State<_ReportPdfPreview> createState() => _ReportPdfPreviewState();
}

class _ReportPdfPreviewState extends State<_ReportPdfPreview> {
  final SignedReportsRepo _signedReportsRepo = SignedReportsRepo();

  Uint8List? _workerSignatureBytes;
  DateTime? _signedAt;
  bool _isSavingSignedPdf = false;

  @override
  Widget build(BuildContext context) {
    final pdfService = ReportPdfService();

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: PdfPreview(
              key: ValueKey(
                '${widget.companyId}-${_signedAt?.millisecondsSinceEpoch ?? 0}-${_workerSignatureBytes?.length ?? 0}',
              ),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: true,
              allowSharing: true,
              pdfFileName: _buildPdfFileName(widget.reportType),
              build: (_) {
                return pdfService.buildReportPdf(
                  reportType: widget.reportType,
                  filters: widget.filters,
                  transactions: widget.transactions,
                  companyProfile: widget.companyProfile,
                  reportSettings: widget.reportSettings,
                  documentTemplates: widget.documentTemplates,
                  workerSignatureBytes: _workerSignatureBytes,
                  signedAt: _signedAt,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasSignature =
        _workerSignatureBytes != null && _workerSignatureBytes!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: Text(
              _getReportTitle(widget.reportType),
              style: AppTextStyles.title,
            ),
          ),
          if (hasSignature)
            Chip(
              avatar: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Signature captured'),
              backgroundColor: AppColors.success.withValues(alpha: 0.10),
              side: BorderSide(
                color: AppColors.success.withValues(alpha: 0.25),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _isSavingSignedPdf ? null : _captureSignature,
            icon: Icon(
              hasSignature ? Icons.edit_outlined : Icons.draw_outlined,
            ),
            label: Text(
              hasSignature ? 'Replace Signature' : 'Capture Signature',
            ),
          ),
          if (hasSignature)
            OutlinedButton.icon(
              onPressed: _isSavingSignedPdf ? null : _clearSignature,
              icon: const Icon(Icons.clear_outlined),
              label: const Text('Clear'),
            ),
          ElevatedButton.icon(
            onPressed: hasSignature && !_isSavingSignedPdf
                ? _saveSignedPdf
                : null,
            icon: _isSavingSignedPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(_isSavingSignedPdf ? 'Saving...' : 'Save Signed PDF'),
          ),
          IconButton(
            onPressed: _isSavingSignedPdf ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Future<void> _captureSignature() async {
    final signatureBytes = await showSignatureCaptureDialog(context);

    if (!mounted || signatureBytes == null || signatureBytes.isEmpty) {
      return;
    }

    setState(() {
      _workerSignatureBytes = signatureBytes;
      _signedAt = DateTime.now();
    });
  }

  void _clearSignature() {
    setState(() {
      _workerSignatureBytes = null;
      _signedAt = null;
    });
  }

  Future<void> _saveSignedPdf() async {
    final signatureBytes = _workerSignatureBytes;
    final signedAt = _signedAt;

    if (signatureBytes == null || signatureBytes.isEmpty || signedAt == null) {
      await _showMessageDialog(
        title: 'Missing Signature',
        message: 'Please capture the worker signature first.',
        icon: Icons.warning_amber_outlined,
        iconColor: AppColors.warning,
      );
      return;
    }

    final signedByName = await _askSignedByName();

    if (!mounted || signedByName == null || signedByName.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSavingSignedPdf = true;
    });

    try {
      final reportNumber = _buildReportNumber(widget.reportType, signedAt);

      final filteredTransactions = applyReportTransactionFilters(
        transactions: widget.transactions,
        filters: widget.filters,
        lostDamagedOnly:
            widget.reportType == ReportType.lostDamaged ||
            widget.reportType == ReportType.lostDamagedApproval,
      );

      final transactionIds = filteredTransactions
          .map((transaction) => transaction.id)
          .whereType<String>()
          .where((id) => id.trim().isNotEmpty)
          .toList();

      final signedPdfBytes = await ReportPdfService().buildReportPdf(
        reportType: widget.reportType,
        filters: widget.filters,
        transactions: widget.transactions,
        companyProfile: widget.companyProfile,
        reportSettings: widget.reportSettings,
        documentTemplates: widget.documentTemplates,
        workerSignatureBytes: signatureBytes,
        signedAt: signedAt,
      );

      final signedReport = await _signedReportsRepo.createSignedReport(
        companyId: widget.companyId,
        reportType: widget.reportType,
        reportNumber: reportNumber,
        signedPdfBytes: signedPdfBytes,
        signedByName: signedByName,
        signedAt: signedAt,
        filters: widget.filters,
        workerId: widget.filters.worker?.id,
        transactionIds: transactionIds,
        signatureInputMethod: _resolveSignatureInputMethod(),
        signaturePlatform: _resolveSignaturePlatform(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSavingSignedPdf = false;
      });

      await _showMessageDialog(
        title: 'Signed PDF Saved',
        message:
            'The signed PDF has been saved successfully.\n\nReport No: ${signedReport.reportNumber}',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      await _showMessageDialog(
        title: 'Unable to Save Signed PDF',
        message: error.toString(),
        icon: Icons.error_outline,
        iconColor: AppColors.error,
      );
    } finally {
      if (mounted && _isSavingSignedPdf) {
        setState(() {
          _isSavingSignedPdf = false;
        });
      }
    }
  }

  Future<String?> _askSignedByName() async {
    final controller = TextEditingController(
      text: widget.filters.worker?.name ?? '',
    );

    final signedByName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Signer Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Signed by',
              hintText: 'Enter worker name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              final value = controller.text.trim();

              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return signedByName?.trim();
  }

  Future<void> _showMessageDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _getReportTitle(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'Worker Custody Report';
      case ReportType.toolHistory:
        return 'Tool History Report';
      case ReportType.transactions:
        return 'Transactions Report';
      case ReportType.lostDamaged:
        return 'Lost & Damaged Report';
      case ReportType.lostDamagedApproval:
        return 'Lost/Damaged Approval Report';
      case ReportType.toolSummary:
        return 'Tool Summary Report';
    }
  }

  String _buildPdfFileName(ReportType reportType) {
    final now = DateTime.now();
    final date = _formatDate(now);

    switch (reportType) {
      case ReportType.workerCustody:
        return 'worker-custody-report-$date.pdf';
      case ReportType.toolHistory:
        return 'tool-history-report-$date.pdf';
      case ReportType.transactions:
        return 'transactions-report-$date.pdf';
      case ReportType.lostDamaged:
        return 'lost-damaged-report-$date.pdf';
      case ReportType.lostDamagedApproval:
        return 'lost-damaged-approval-report-$date.pdf';
      case ReportType.toolSummary:
        return 'tool-summary-report-$date.pdf';
    }
  }

  String _buildReportNumber(ReportType reportType, DateTime signedAt) {
    final prefix = switch (reportType) {
      ReportType.workerCustody => 'WCR',
      ReportType.toolHistory => 'THR',
      ReportType.transactions => 'TRR',
      ReportType.lostDamaged => 'LDR',
      ReportType.lostDamagedApproval => 'LDAR',
      ReportType.toolSummary => 'TSR',
    };

    final timestamp =
        '${signedAt.year}'
        '${signedAt.month.toString().padLeft(2, '0')}'
        '${signedAt.day.toString().padLeft(2, '0')}'
        '${signedAt.hour.toString().padLeft(2, '0')}'
        '${signedAt.minute.toString().padLeft(2, '0')}'
        '${signedAt.second.toString().padLeft(2, '0')}';

    return '$prefix-$timestamp';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _resolveSignatureInputMethod() {
    final platform = Theme.of(context).platform;

    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return 'touch_or_stylus';
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return 'external_signature_pad_or_pen_tablet';
      case TargetPlatform.fuchsia:
        return 'unknown';
    }
  }

  String _resolveSignaturePlatform() {
    return Theme.of(context).platform.name;
  }
}
