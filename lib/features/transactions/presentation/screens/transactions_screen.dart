import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/layouts/custody_balance_desktop_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/layouts/custody_balance_mobile_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/layouts/transactions_desktop_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/layouts/transactions_mobile_layout.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TransactionsView();
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        final transactions = state.filteredTransactions;
        final custodyBalances = context
            .read<TransactionsCubit>()
            .getFilteredCustodyBalances();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: AppColors.background,
                body: Column(
                  children: [
                    Container(
                      color: AppColors.card,
                      child: const TabBar(
                        labelColor: AppColors.accent,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.accent,
                        tabs: [
                          Tab(text: 'Transactions'),
                          Tab(text: 'Custody Balance'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          if (isMobile)
                            TransactionsMobileLayout(transactions: transactions)
                          else
                            TransactionsDesktopLayout(
                              transactions: transactions,
                            ),
                          if (isMobile)
                            CustodyBalanceMobileLayout(
                              balances: custodyBalances,
                            )
                          else
                            CustodyBalanceDesktopLayout(
                              balances: custodyBalances,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
