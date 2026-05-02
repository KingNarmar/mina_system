import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/table/custody_balance_table_cell.dart';

class CustodyBalanceTableRow extends StatelessWidget {
  const CustodyBalanceTableRow({super.key, required this.balance});

  final CustodyBalanceModel balance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              CustodyBalanceTableBodyCell(value: balance.workerName, flex: 3),
              CustodyBalanceTableBodyCell(value: balance.workerHrCode, flex: 2),
              CustodyBalanceTableBodyCell(value: balance.toolName, flex: 3),
              CustodyBalanceTableBodyCell(value: balance.toolCode, flex: 2),
              CustodyBalanceTableBodyCell(
                value:
                    '${formatQuantity(balance.balanceQuantity)} ${balance.unit}',
                flex: 2,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
