import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/demo/data/repo/demo_signed_reports_repo.dart';
import 'package:mina_system/features/reports/data/models/signed_report_model.dart';
import 'package:printing/printing.dart';

Future<void> showDemoSignedReportPdfPreview(
  BuildContext context, {
  required SignedReportModel signedReport,
}) async {
  final width = MediaQuery.sizeOf(context).width;
  final height = MediaQuery.sizeOf(context).height;
  final isMobile = width < AppBreakpoints.tablet;

  final preview = _DemoSignedReportPdfPreview(signedReport: signedReport);

  if (isMobile) {
    await showModalBottomSheet<void>(
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

  await showDialog<void>(
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

class _DemoSignedReportPdfPreview extends StatefulWidget {
  const _DemoSignedReportPdfPreview({required this.signedReport});

  final SignedReportModel signedReport;

  @override
  State<_DemoSignedReportPdfPreview> createState() =>
      _DemoSignedReportPdfPreviewState();
}

class _DemoSignedReportPdfPreviewState
    extends State<_DemoSignedReportPdfPreview> {
  late final Future<Uint8List> _pdfBytesFuture;

  @override
  void initState() {
    super.initState();

    _pdfBytesFuture = DemoSignedReportsRepo().readSignedReportBytes(
      widget.signedReport,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _DemoSignedReportPreviewHeader(signedReport: widget.signedReport),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<Uint8List>(
              future: _pdfBytesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return _DemoSignedReportPreviewError(
                    message:
                        snapshot.error?.toString() ??
                        'Unable to open demo signed PDF.',
                  );
                }

                final pdfBytes = snapshot.data!;

                return PdfPreview(
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  allowPrinting: true,
                  allowSharing: true,
                  pdfFileName: widget.signedReport.fileName,
                  build: (_) async {
                    return pdfBytes;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoSignedReportPreviewHeader extends StatelessWidget {
  const _DemoSignedReportPreviewHeader({required this.signedReport});

  final SignedReportModel signedReport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(AppIcons.pdf, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(signedReport.reportNumber, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(signedReport.reportTypeLabel, style: AppTextStyles.body),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(AppIcons.close),
          ),
        ],
      ),
    );
  }
}

class _DemoSignedReportPreviewError extends StatelessWidget {
  const _DemoSignedReportPreviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.errorOutline, color: AppColors.error, size: 32),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
