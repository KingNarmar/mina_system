import 'package:flutter/material.dart';
import 'package:mina_system/features/workers/presentation/widgets/table/workers_table_cell.dart';

class WorkersTableHeader extends StatelessWidget {
  const WorkersTableHeader({super.key, required this.showActions});

  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const WorkersTableHeaderCell(title: 'Worker Name', flex: 3),
          const WorkersTableHeaderCell(title: 'HR Code', flex: 2),
          const WorkersTableHeaderCell(title: 'Department', flex: 2),
          const WorkersTableHeaderCell(title: 'Job Title', flex: 2),
          if (showActions)
            const WorkersTableHeaderCell(title: 'Actions', flex: 2),
        ],
      ),
    );
  }
}
