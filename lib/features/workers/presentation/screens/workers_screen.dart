import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/widgets/add_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_card.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';
import 'package:mina_system/features/workers/presentation/widgets/workers_table.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  String _searchQuery = '';

  static const List<WorkerModel> workers = [
    WorkerModel(
      name: 'Ahmed Ali',
      hrCode: 'HR-001',
      department: 'Warehouse',
      jobTitle: 'Storekeeper',
      activeCustodyCount: 6,
    ),
    WorkerModel(
      name: 'Mohamed Samir',
      hrCode: 'HR-002',
      department: 'Fabrication',
      jobTitle: 'Welder',
      activeCustodyCount: 3,
    ),
    WorkerModel(
      name: 'Khaled Hassan',
      hrCode: 'HR-003',
      department: 'Mechanical',
      jobTitle: 'Mechanic',
      activeCustodyCount: 4,
    ),
    WorkerModel(
      name: 'Sayed Mahmoud',
      hrCode: 'HR-004',
      department: 'Electrical',
      jobTitle: 'Electrician',
      activeCustodyCount: 2,
    ),
  ];

  List<WorkerModel> get filteredWorkers {
    if (_searchQuery.trim().isEmpty) {
      return workers;
    }

    final query = _searchQuery.trim().toLowerCase();

    return workers.where((worker) {
      final name = worker.name.toLowerCase();
      final hrCode = worker.hrCode.toLowerCase();

      return name.contains(query) || hrCode.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

        if (isMobile) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              itemCount: filteredWorkers.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return WorkerSearchField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  );
                }

                final worker = filteredWorkers[index - 1];

                return WorkerCard(worker: worker);
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _showAddWorkerBottomSheet,
              child: const Icon(Icons.add),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: WorkerSearchField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _showAddWorkerDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Worker'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: WorkersTable(workers: filteredWorkers),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddWorkerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const AddWorkerForm();
      },
    );
  }

  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const SizedBox(width: 460, child: AddWorkerForm()),
        );
      },
    );
  }
}
