import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/demo/data/repo/demo_tools_repo.dart';
import 'package:mina_system/features/demo/data/repo/demo_workers_repo.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/form/add_transaction_form.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';

void showTransactionBottomSheet(
  BuildContext context, {
  TransactionType? initialType,
}) {
  final parentContext = context;
  final companyId = context.currentCompanyId ?? '';
  final transactionsCubit = context.read<TransactionsCubit>();
  final repositories = resolveTransactionOptionRepositories(
    isDemo: AppModeScope.maybeOf(context)?.isDemo ?? false,
  );

  transactionsCubit.markTransactionFormOpened();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: BlocProvider.value(
          value: transactionsCubit,
          child: AddTransactionForm(
            companyId: companyId,
            initialType: initialType,
            workersRepo: repositories.workersRepo,
            toolsRepo: repositories.toolsRepo,
            onSave: (transaction) async {
              return _saveTransaction(
                context: parentContext,
                popContext: sheetContext,
                transaction: transaction,
              );
            },
          ),
        ),
      );
    },
  ).whenComplete(transactionsCubit.markTransactionFormClosed);
}

void showTransactionDialog(
  BuildContext context, {
  TransactionType? initialType,
}) {
  final parentContext = context;
  final companyId = context.currentCompanyId ?? '';
  final transactionsCubit = context.read<TransactionsCubit>();
  final repositories = resolveTransactionOptionRepositories(
    isDemo: AppModeScope.maybeOf(context)?.isDemo ?? false,
  );

  transactionsCubit.markTransactionFormOpened();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 460,
          child: BlocProvider.value(
            value: transactionsCubit,
            child: AddTransactionForm(
              companyId: companyId,
              initialType: initialType,
              workersRepo: repositories.workersRepo,
              toolsRepo: repositories.toolsRepo,
              onSave: (transaction) async {
                return _saveTransaction(
                  context: parentContext,
                  popContext: dialogContext,
                  transaction: transaction,
                );
              },
            ),
          ),
        ),
      );
    },
  ).whenComplete(transactionsCubit.markTransactionFormClosed);
}

({WorkersRepo? workersRepo, ToolsRepo? toolsRepo})
resolveTransactionOptionRepositories({required bool isDemo}) {
  if (!isDemo) {
    return (workersRepo: null, toolsRepo: null);
  }

  return (workersRepo: DemoWorkersRepo(), toolsRepo: DemoToolsRepo());
}

Future<String?> _saveTransaction({
  required BuildContext context,
  required BuildContext popContext,
  required TransactionModel transaction,
}) async {
  final companyId = context.currentCompanyId;
  final transactionsCubit = context.read<TransactionsCubit>();
  final dashboardCubit = context.read<DashboardCubit>();

  final navigator = Navigator.of(popContext);

  if (companyId == null || companyId.isEmpty) {
    return 'Company ID was not found';
  }

  final isSaved = await transactionsCubit.addTransaction(
    transaction,
    companyId: companyId,
  );

  if (!isSaved) {
    final errorMessage =
        transactionsCubit.state.errorMessage ?? 'Unable to save transaction.';

    transactionsCubit.clearErrorMessage();

    return errorMessage;
  }

  await dashboardCubit.loadDashboardSummary(
    companyId: companyId,
    showLoader: false,
  );

  navigator.pop();

  if (context.mounted) {
    AppMessage.showSuccess(context, 'Transaction added successfully');
  }

  return null;
}
