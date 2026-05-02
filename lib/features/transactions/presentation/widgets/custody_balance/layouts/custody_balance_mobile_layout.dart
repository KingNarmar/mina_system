import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/card/custody_balance_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/custody_balance_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transactions_empty_state.dart';

class CustodyBalanceMobileLayout extends StatelessWidget {
  const CustodyBalanceMobileLayout({super.key, required this.balances});

  final List<CustodyBalanceModel> balances;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: balances.isEmpty ? 2 : balances.length + 1,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return CustodyBalanceSearchField(
              onChanged: (value) {
                context.read<TransactionsCubit>().searchCustodyBalances(value);
              },
            );
          }

          if (balances.isEmpty) {
            return const TransactionsEmptyState(
              message: 'No open custody balances found',
              icon: Icons.inventory_2_outlined,
            );
          }

          final balance = balances[index - 1];

          return CustodyBalanceCard(balance: balance);
        },
      ),
    );
  }
}
