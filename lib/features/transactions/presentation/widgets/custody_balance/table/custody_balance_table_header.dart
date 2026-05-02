import 'package:flutter/material.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/table/custody_balance_table_cell.dart';

class CustodyBalanceTableHeader extends StatelessWidget {
  const CustodyBalanceTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CustodyBalanceTableHeaderCell(title: 'Worker', flex: 3),
          CustodyBalanceTableHeaderCell(title: 'HR Code', flex: 2),
          CustodyBalanceTableHeaderCell(title: 'Tool', flex: 3),
          CustodyBalanceTableHeaderCell(title: 'Tool Code', flex: 2),
          CustodyBalanceTableHeaderCell(title: 'Balance', flex: 2),
        ],
      ),
    );
  }
}
