import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/transactions/presentation/widgets/card/transaction_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transactions_empty_state.dart';

class TransactionsMobileLayout extends StatelessWidget {
  const TransactionsMobileLayout({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: transactions.isEmpty ? 2 : transactions.length + 1,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return TransactionSearchField(
              onChanged: (value) {
                context.read<TransactionsCubit>().searchTransactions(value);
              },
            );
          }

          if (transactions.isEmpty) {
            return const TransactionsEmptyState(
              message: 'No transactions found',
            );
          }

          final transaction = transactions[index - 1];

          return TransactionCard(transaction: transaction);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTransactionBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
