import 'package:flutter/material.dart';
import 'package:mina_system/features/transactions/presentation/widgets/table/transactions_table_cell.dart';

class TransactionsTableHeader extends StatelessWidget {
  const TransactionsTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          TransactionsTableHeaderCell(title: 'TRX Code', flex: 2),
          TransactionsTableHeaderCell(title: 'Type', flex: 1),
          TransactionsTableHeaderCell(title: 'Worker', flex: 3),
          TransactionsTableHeaderCell(title: 'Tool', flex: 3),
          TransactionsTableHeaderCell(title: 'Qty', flex: 1),
          TransactionsTableHeaderCell(title: 'Date', flex: 2),
        ],
      ),
    );
  }
}
