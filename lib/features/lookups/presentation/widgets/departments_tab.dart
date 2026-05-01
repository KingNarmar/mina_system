import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
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
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        hint: 'Department Name',
                        controller: _departmentController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final isAdded = addDepartmentLookup(
                            context: context,
                            department: _departmentController.text,
                            departments: state.departments,
                          );

                          if (isAdded) {
                            _departmentController.clear();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                          onConfirm: () {
                            deleteDepartmentLookup(
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
