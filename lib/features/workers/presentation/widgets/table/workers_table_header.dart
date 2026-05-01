import 'package:flutter/material.dart';
import 'package:mina_system/features/workers/presentation/widgets/table/workers_table_cell.dart';

class WorkersTableHeader extends StatelessWidget {
  const WorkersTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          WorkersTableHeaderCell(title: 'Worker Name', flex: 3),
          WorkersTableHeaderCell(title: 'HR Code', flex: 2),
          WorkersTableHeaderCell(title: 'Department', flex: 2),
          WorkersTableHeaderCell(title: 'Job Title', flex: 2),
          WorkersTableHeaderCell(title: 'Active Custody', flex: 2),
          WorkersTableHeaderCell(title: 'Actions', flex: 2),
        ],
      ),
    );
  }
}
