import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/custody_balance_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/custody_balance_table.dart';

class CustodyBalanceDesktopLayout extends StatelessWidget {
  const CustodyBalanceDesktopLayout({super.key, required this.balances});

  final List<CustodyBalanceModel> balances;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, 860.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CustodyBalanceSearchField(
                onChanged: (value) {
                  context.read<TransactionsCubit>().searchCustodyBalances(
                    value,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (balances.isEmpty)
                const AppEmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No open custody balances',
                  message:
                      'Open custody balances will appear here after tools are issued and not yet returned, lost, or damaged.',
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: CustodyBalanceTable(balances: balances),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
