import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_builder_panel.dart';

void showReportBuilder(
  BuildContext context, {
  required ReportOptionModel report,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final isMobile = width < AppBreakpoints.tablet;

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return ReportBuilderPanel(report: report);
      },
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ReportBuilderPanel(report: report),
        ),
      );
    },
  );
}