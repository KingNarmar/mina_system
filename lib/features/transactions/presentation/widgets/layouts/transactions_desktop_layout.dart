import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_type_filter_chips.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transactions_table.dart';

class TransactionsDesktopLayout extends StatelessWidget {
  const TransactionsDesktopLayout({
    super.key,
    required this.transactions,
    required this.selectedFilter,
  });

  final List<TransactionModel> transactions;
  final TransactionTypeFilter selectedFilter;

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
                      onChanged: (value) {
                        context.read<TransactionsCubit>().searchTransactions(
                          value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showTransactionDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Transaction'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                const AppEmptyState(
                  icon: Icons.swap_horiz_outlined,
                  title: 'No transactions found',
                  message:
                      'Add your first custody transaction to start tracking issued and closed tools.',
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
