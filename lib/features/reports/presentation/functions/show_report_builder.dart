import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_builder_panel.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

void showReportBuilder(
  BuildContext context, {
  required ReportOptionModel report,
  required bool canGenerateReports,
}) {
  final companyId = context.currentCompanyId;

  if (companyId == null || companyId.isEmpty) {
    AppMessage.showError(context, 'Company ID was not found');
    return;
  }

  final width = MediaQuery.sizeOf(context).width;
  final isMobile = width < AppBreakpoints.tablet;

  final transactionsCubit = context.read<TransactionsCubit>();
  final workersCubit = context.read<WorkersCubit>();
  final toolsCubit = context.read<ToolsCubit>();
  final companySettingsCubit = context.read<CompanySettingsCubit>();

  final reportBuilder = MultiBlocProvider(
    providers: [
      BlocProvider.value(value: transactionsCubit),
      BlocProvider.value(value: workersCubit),
      BlocProvider.value(value: toolsCubit),
      BlocProvider.value(value: companySettingsCubit),
    ],
    child: ReportBuilderPanel(
      report: report,
      companyId: companyId,
      canGenerateReports: canGenerateReports,
    ),
  );

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return reportBuilder;
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
          child: reportBuilder,
        ),
      );
    },
  );
}
