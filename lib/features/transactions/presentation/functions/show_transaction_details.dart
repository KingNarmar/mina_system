import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_dialog.dart';

void showTransactionDetails(
  BuildContext context,
  TransactionModel transaction,
) {
  final currentContextCubit = context.read<CurrentContextCubit>();
  final transactionsCubit = context.read<TransactionsCubit>();

  showDialog(
    context: context,
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: currentContextCubit),
          BlocProvider.value(value: transactionsCubit),
        ],
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: TransactionDetailsDialog(transaction: transaction),
            ),
          ),
        ),
      );
    },
  );
}
