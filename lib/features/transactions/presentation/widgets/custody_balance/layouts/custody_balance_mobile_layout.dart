import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/card/custody_balance_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/custody_balance_search_field.dart';
import 'package:gap/gap.dart';

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
          return const Gap(12);
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
