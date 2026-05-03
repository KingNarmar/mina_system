import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/transactions/presentation/widgets/card/transaction_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_type_filter_chips.dart';

class TransactionsMobileLayout extends StatelessWidget {
  const TransactionsMobileLayout({
    super.key,
    required this.transactions,
    required this.selectedFilter,
  });

  final List<TransactionModel> transactions;
  final TransactionTypeFilter selectedFilter;
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionSearchField(
                  onChanged: (value) {
                    context.read<TransactionsCubit>().searchTransactions(value);
                  },
                ),
                const SizedBox(height: 12),
                TransactionTypeFilterChips(
                  selectedFilter: selectedFilter,
                  onChanged: (filter) {
                    context.read<TransactionsCubit>().filterTransactionsByType(
                      filter,
                    );
                  },
                ),
              ],
            );
          }

          if (transactions.isEmpty) {
            return const AppEmptyState(
              icon: Icons.swap_horiz_outlined,
              title: 'No transactions found',
              message:
                  'Add your first custody transaction to start tracking issued and closed tools.',
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
