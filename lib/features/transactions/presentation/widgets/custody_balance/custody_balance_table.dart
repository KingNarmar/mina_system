import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/table/custody_balance_table_header.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/table/custody_balance_table_row.dart';

class CustodyBalanceTable extends StatelessWidget {
  const CustodyBalanceTable({super.key, required this.balances});

  final List<CustodyBalanceModel> balances;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          const CustodyBalanceTableHeader(),
          const Divider(height: 1, color: AppColors.border),
          if (balances.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No open custody balances found',
                style: AppTextStyles.body,
              ),
            )
          else
            ...balances.map((balance) {
              return CustodyBalanceTableRow(balance: balance);
            }),
        ],
      ),
    );
  }
}
