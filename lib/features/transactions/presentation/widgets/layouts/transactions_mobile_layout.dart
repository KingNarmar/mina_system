import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/transactions/presentation/widgets/card/transaction_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_type_filter_chips.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class TransactionsMobileLayout extends StatelessWidget {
  const TransactionsMobileLayout({
    super.key,
    required this.transactions,
    required this.searchQuery,
    required this.selectedFilter,
    required this.canCreateTransactions,
    this.isCompactSearchMode = false,
    this.onSearchFocusChanged,
  });

  final List<TransactionModel> transactions;
  final String searchQuery;
  final TransactionTypeFilter selectedFilter;
  final bool canCreateTransactions;
  final bool isCompactSearchMode;
  final ValueChanged<bool>? onSearchFocusChanged;

  @override
  Widget build(BuildContext context) {
    final keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardBottomInset > 0;
    final shouldHideFloatingButton =
        isKeyboardOpen || isCompactSearchMode || !canCreateTransactions;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          isCompactSearchMode ? 16 : 24,
          isCompactSearchMode ? 8 : 24,
          isCompactSearchMode ? 16 : 24,
          isKeyboardOpen ? keyboardBottomInset + 16 : 100,
        ),
        itemCount: transactions.isEmpty ? 2 : transactions.length + 1,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionSearchField(
                  initialQuery: searchQuery,
                  onFocusChanged: onSearchFocusChanged,
                  onChanged: (value) {
                    context.read<TransactionsCubit>().searchTransactions(value);
                  },
                ),
                if (!isCompactSearchMode) ...[
                  const Gap(12),
                  TransactionTypeFilterChips(
                    selectedFilter: selectedFilter,
                    onChanged: (filter) {
                      context
                          .read<TransactionsCubit>()
                          .filterTransactionsByType(filter);
                    },
                  ),
                ],
              ],
            );
          }

          if (transactions.isEmpty) {
            return AppEmptyState(
              icon: AppIcons.transactions,
              title: 'No transactions found',
              message: canCreateTransactions
                  ? 'Add your first custody transaction to start tracking issued and closed tools.'
                  : 'No transactions are currently available for your company.',
            );
          }

          final transaction = transactions[index - 1];

          return TransactionCard(transaction: transaction);
        },
      ),
      floatingActionButton: shouldHideFloatingButton
          ? null
          : FloatingActionButton(
              onPressed: () {
                showTransactionBottomSheet(context);
              },
              child: const Icon(AppIcons.add),
            ),
    );
  }
}
