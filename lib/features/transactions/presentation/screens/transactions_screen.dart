import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

            if (isMobile) {
              return TransactionsMobileLayout(transactions: transactions);
            }

            return TransactionsDesktopLayout(transactions: transactions);
          },
        );
      },
    );
  }
}
