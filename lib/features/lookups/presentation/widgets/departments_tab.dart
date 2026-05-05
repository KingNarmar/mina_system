import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_add_row.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_card.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_list_tile.dart';

class DepartmentsTab extends StatefulWidget {
  const DepartmentsTab({super.key});

  @override
  State<DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<DepartmentsTab> {
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LookupCard(
            title: 'Manage Departments',
            child: Column(
              children: [
                LookupAddRow(
                  hint: 'Department Name',
                  controller: _departmentController,
                  onAdd: () async {
                    final isAdded = await addDepartmentLookup(
                      context: context,
                      department: _departmentController.text,
                      departments: state.departments,
                    );

                    if (isAdded) {
                      _departmentController.clear();
                    }
                  },
                ),
                const Gap(20),
                if (state.departments.isEmpty)
                  const EmptyLookupMessage(message: 'No departments found')
                else
                  ...state.departments.map((department) {
                    return LookupListTile(
                      title: department,
                      subtitle: 'Department',
                      onDelete: () {
                        confirmDeleteLookup(
                          context: context,
                          title: 'Delete Department',
                          message:
                              'Are you sure you want to delete $department?',
                          onConfirm: () async {
                            await deleteDepartmentLookup(
                              context: context,
                              department: department,
                            );
                          },
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
