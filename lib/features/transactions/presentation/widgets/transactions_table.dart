import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/widgets/table/transactions_table_header.dart';
import 'package:mina_system/features/transactions/presentation/widgets/table/transactions_table_row.dart';

class TransactionsTable extends StatelessWidget {
  const TransactionsTable({super.key, required this.transactions});

  final List<TransactionModel> transactions;

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
          const TransactionsTableHeader(),
          const Divider(height: 1, color: AppColors.border),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No transactions found', style: AppTextStyles.body),
            )
          else
            ...transactions.map((transaction) {
              return TransactionsTableRow(transaction: transaction);
            }),
        ],
      ),
    );
  }
}
