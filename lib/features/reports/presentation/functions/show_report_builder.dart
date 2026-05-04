import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_builder_panel.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';

void showReportBuilder(
  BuildContext context, {
  required ReportOptionModel report,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final isMobile = width < AppBreakpoints.tablet;

  final transactionsCubit = context.read<TransactionsCubit>();

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return BlocProvider.value(
          value: transactionsCubit,
          child: ReportBuilderPanel(report: report),
        );
      },
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: transactionsCubit,
        child: Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ReportBuilderPanel(report: report),
          ),
        ),
      );
    },
  );
}