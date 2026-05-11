import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/card/custody_balance_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/custody_balance_search_field.dart';

class CustodyBalanceMobileLayout extends StatelessWidget {
  const CustodyBalanceMobileLayout({
    super.key,
    required this.balances,
    required this.searchQuery,
    this.isCompactSearchMode = false,
    this.onSearchFocusChanged,
  });

  final List<CustodyBalanceModel> balances;
  final String searchQuery;
  final bool isCompactSearchMode;
  final ValueChanged<bool>? onSearchFocusChanged;

  @override
  Widget build(BuildContext context) {
    final keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          isCompactSearchMode ? 16 : 24,
          isCompactSearchMode ? 8 : 24,
          isCompactSearchMode ? 16 : 24,
          keyboardBottomInset > 0 ? keyboardBottomInset + 16 : 100,
        ),
        itemCount: balances.isEmpty ? 2 : balances.length + 1,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return CustodyBalanceSearchField(
              initialQuery: searchQuery,
              onFocusChanged: onSearchFocusChanged,
              onChanged: (value) {
                context.read<TransactionsCubit>().searchCustodyBalances(value);
              },
            );
          }

          if (balances.isEmpty) {
            return const AppEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No open custody balances',
              message:
                  'Open custody balances will appear here after tools are issued and not yet returned, lost, or damaged.',
            );
          }

          final balance = balances[index - 1];

          return CustodyBalanceCard(balance: balance);
        },
      ),
    );
  }
}
