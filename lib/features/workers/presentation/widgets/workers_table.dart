import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

class WorkersTable extends StatelessWidget {
  const WorkersTable({super.key, required this.workers});

  final List<WorkerModel> workers;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth,
                child: DataTable(
                  headingTextStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  dataTextStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  columns: const [
                    DataColumn(label: Text('Worker Name')),
                    DataColumn(label: Text('HR Code')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Job Title')),
                    DataColumn(label: Text('Active Custody')),
                  ],
                  rows: workers.map((worker) {
                    return DataRow(
                      cells: [
                        DataCell(Text(worker.name)),
                        DataCell(Text(worker.hrCode)),
                        DataCell(Text(worker.department)),
                        DataCell(Text(worker.jobTitle)),
                        DataCell(Text(worker.activeCustodyCount.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
