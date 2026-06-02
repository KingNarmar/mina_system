import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_type_filter_chips.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transactions_table.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class TransactionsDesktopLayout extends StatelessWidget {
  const TransactionsDesktopLayout({
    super.key,
    required this.transactions,
    required this.searchQuery,
    required this.selectedFilter,
    required this.canCreateTransactions,
  });

  final List<TransactionModel> transactions;
  final String searchQuery;
  final TransactionTypeFilter selectedFilter;
  final bool canCreateTransactions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, 980.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TransactionSearchField(
                      initialQuery: searchQuery,
                      onChanged: (value) {
                        context.read<TransactionsCubit>().searchTransactions(
                          value,
                        );
                      },
                    ),
                  ),
                  if (canCreateTransactions) ...[
                    const Gap(16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showTransactionDialog(context);
                        },
                        icon: const Icon(AppIcons.add),
                        label: const Text('Add Transaction'),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(12),
              Align(
                alignment: Alignment.centerLeft,
                child: TransactionTypeFilterChips(
                  selectedFilter: selectedFilter,
                  onChanged: (filter) {
                    context.read<TransactionsCubit>().filterTransactionsByType(
                      filter,
                    );
                  },
                ),
              ),
              const Gap(16),
              if (transactions.isEmpty)
                AppEmptyState(
                  icon: AppIcons.transactions,
                  title: 'No transactions found',
                  message: canCreateTransactions
                      ? 'Add your first custody transaction to start tracking issued and closed tools.'
                      : 'No transactions are currently available for your company.',
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: TransactionsTable(transactions: transactions),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
