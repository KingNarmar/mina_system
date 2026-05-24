import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/restore_department_lookup.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_add_row.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_card.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_list_tile.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_status_toggle.dart';

class DepartmentsTab extends StatefulWidget {
  const DepartmentsTab({
    super.key,
    required this.canCreateLookups,
    required this.canDeleteLookups,
    required this.canRestoreLookups,
    this.isCompactInputMode = false,
    this.onLookupInputFocusChanged,
  });

  final bool canCreateLookups;
  final bool canDeleteLookups;
  final bool canRestoreLookups;
  final bool isCompactInputMode;
  final ValueChanged<bool>? onLookupInputFocusChanged;

  @override
  State<DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<DepartmentsTab> {
  final _departmentController = TextEditingController();
  bool _showInactive = false;

  @override
  void dispose() {
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(
      widget.isCompactInputMode ? 16 : 24,
      widget.isCompactInputMode ? 8 : 24,
      widget.isCompactInputMode ? 16 : 24,
      bottomInset > 0 ? bottomInset + 16 : 24,
    );

    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, state) {
        final departments = _showInactive
            ? state.inactiveDepartments
            : state.departments;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: LookupCard(
            title: 'Manage Departments',
            child: Column(
              children: [
                LookupStatusToggle(
                  showInactive: _showInactive,
                  onChanged: (value) {
                    setState(() {
                      _showInactive = value;
                    });
                  },
                ),
                const Gap(16),
                if (!_showInactive && widget.canCreateLookups) ...[
                  LookupAddRow(
                    hint: 'Department Name',
                    controller: _departmentController,
                    isCompactInputMode: widget.isCompactInputMode,
                    onFocusChanged: widget.onLookupInputFocusChanged,
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
                ],
                if (departments.isEmpty)
                  EmptyLookupMessage(
                    message: _showInactive
                        ? 'No inactive departments found'
                        : 'No active departments found',
                  )
                else
                  ...departments.map((department) {
                    return LookupListTile(
                      title: department,
                      subtitle: _showInactive
                          ? 'Inactive Department'
                          : 'Active Department',
                      onDelete: !_showInactive && widget.canDeleteLookups
                          ? () {
                              confirmDeleteLookup(
                                context: context,
                                title: 'Deactivate Department',
                                message:
                                    'Are you sure you want to deactivate $department?',
                                onConfirm: () async {
                                  await deleteDepartmentLookup(
                                    context: context,
                                    department: department,
                                  );
                                },
                              );
                            }
                          : null,
                      onRestore: _showInactive && widget.canRestoreLookups
                          ? () async {
                              await restoreDepartmentLookup(
                                context: context,
                                department: department,
                              );
                            }
                          : null,
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
