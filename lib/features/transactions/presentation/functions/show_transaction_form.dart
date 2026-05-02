import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_message.dart';
import 'package:mina_system/features/transactions/presentation/widgets/form/add_transaction_form.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

void showTransactionBottomSheet(BuildContext context) {
  final transactionsCubit = context.read<TransactionsCubit>();
  final workersCubit = context.read<WorkersCubit>();
  final toolsCubit = context.read<ToolsCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: transactionsCubit),
          BlocProvider.value(value: workersCubit),
          BlocProvider.value(value: toolsCubit),
        ],
        child: AddTransactionForm(
          onSave: (transaction) {
            _saveTransaction(context: context, transaction: transaction);
          },
        ),
      );
    },
  );
}

void showTransactionDialog(BuildContext context) {
  final transactionsCubit = context.read<TransactionsCubit>();
  final workersCubit = context.read<WorkersCubit>();
  final toolsCubit = context.read<ToolsCubit>();

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 460,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: transactionsCubit),
              BlocProvider.value(value: workersCubit),
              BlocProvider.value(value: toolsCubit),
            ],
            child: AddTransactionForm(
              onSave: (transaction) {
                _saveTransaction(context: context, transaction: transaction);
              },
            ),
          ),
        ),
      );
    },
  );
}

void _saveTransaction({
  required BuildContext context,
  required TransactionModel transaction,
}) {
  final change = transaction.isIssue ? 1 : -1;

  context.read<TransactionsCubit>().addTransaction(transaction);

  context.read<WorkersCubit>().updateWorkerCustodyCount(
    hrCode: transaction.workerHrCode,
    change: change,
  );

  context.read<ToolsCubit>().updateToolCustodyCount(
    toolCode: transaction.toolCode,
    change: change,
  );

  showTransactionMessage(context, 'Transaction added successfully');
}
