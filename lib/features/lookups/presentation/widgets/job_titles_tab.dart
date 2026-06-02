import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/features/lookups/data/models/job_title_model.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_job_title_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_job_title_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/restore_job_title_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_audit_history.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_add_row.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_card.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_list_tile.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_status_toggle.dart';

class JobTitlesTab extends StatefulWidget {
  const JobTitlesTab({
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
  State<JobTitlesTab> createState() => _JobTitlesTabState();
}

class _JobTitlesTabState extends State<JobTitlesTab> {
  final _jobTitleController = TextEditingController();

  String? _selectedDepartment;
  bool _showInactive = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
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
        final departmentItems = _showInactive
            ? _uniqueValues([
                ...state.departments,
                ...state.inactiveDepartments,
              ])
            : state.departments;

        final selectedDepartment = departmentItems.contains(_selectedDepartment)
            ? _selectedDepartment
            : null;

        final jobTitles = _showInactive
            ? state.getInactiveJobTitlesByDepartment(selectedDepartment)
            : state.getJobTitlesByDepartment(selectedDepartment);

        final jobTitleModels = _getJobTitleModelsForDepartment(
          state: state,
          selectedDepartment: selectedDepartment,
        );

        final selectedDepartmentIsActive =
            selectedDepartment != null &&
            state.departments.contains(selectedDepartment);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: LookupCard(
            title: 'Manage Job Titles',
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
                Gap(widget.isCompactInputMode ? 8 : 16),
                if (widget.isCompactInputMode &&
                    selectedDepartment != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Department: $selectedDepartment',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  CustomDropdownFormField(
                    hint: 'Select Department',
                    value: selectedDepartment,
                    items: departmentItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                  ),
                ],
                if (!_showInactive && widget.canCreateLookups) ...[
                  Gap(widget.isCompactInputMode ? 8 : 12),
                  LookupAddRow(
                    hint: 'Job Title',
                    controller: _jobTitleController,
                    isCompactInputMode: widget.isCompactInputMode,
                    onFocusChanged: widget.onLookupInputFocusChanged,
                    onAdd: () async {
                      final isAdded = await addJobTitleLookup(
                        context: context,
                        department: selectedDepartment,
                        jobTitle: _jobTitleController.text,
                        jobTitles: jobTitles,
                      );

                      if (isAdded) {
                        _jobTitleController.clear();
                      }
                    },
                  ),
                ],
                const Gap(20),
                if (selectedDepartment == null)
                  EmptyLookupMessage(
                    message: _showInactive
                        ? 'Select a department to view inactive job titles'
                        : 'Select a department to view its job titles',
                  )
                else if (jobTitleModels.isEmpty)
                  EmptyLookupMessage(
                    message: _showInactive
                        ? 'No inactive job titles found for this department'
                        : 'No job titles found for this department',
                  )
                else
                  ...jobTitleModels.map((jobTitle) {
                    return LookupListTile(
                      title: jobTitle.name,
                      subtitle: _showInactive
                          ? selectedDepartmentIsActive
                                ? 'Inactive Job Title'
                                : 'Inactive Department - restore department first'
                          : selectedDepartment,
                      onViewAuditHistory: () {
                        showLookupAuditHistory(
                          context,
                          entityType: 'job_title',
                          entityId: jobTitle.id,
                          title: 'Job Title Audit History',
                        );
                      },
                      onDelete: !_showInactive && widget.canDeleteLookups
                          ? () {
                              confirmDeleteLookup(
                                context: context,
                                title: 'Deactivate Job Title',
                                message:
                                    'Are you sure you want to deactivate ${jobTitle.name}?',
                                onConfirm: () async {
                                  await deleteJobTitleLookup(
                                    context: context,
                                    department: selectedDepartment,
                                    jobTitle: jobTitle.name,
                                  );
                                },
                              );
                            }
                          : null,
                      onRestore:
                          _showInactive &&
                              widget.canRestoreLookups &&
                              selectedDepartmentIsActive
                          ? () async {
                              await restoreJobTitleLookup(
                                context: context,
                                department: selectedDepartment,
                                jobTitle: jobTitle.name,
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

  List<String> _uniqueValues(List<String> values) {
    final seenValues = <String>{};
    final uniqueValues = <String>[];

    for (final value in values) {
      if (seenValues.add(value)) {
        uniqueValues.add(value);
      }
    }

    return uniqueValues;
  }

  List<JobTitleModel> _getJobTitleModelsForDepartment({
    required LookupsState state,
    required String? selectedDepartment,
  }) {
    if (selectedDepartment == null || selectedDepartment.trim().isEmpty) {
      return [];
    }

    final departments = [
      ...state.departmentModels,
      ...state.inactiveDepartmentModels,
    ];

    final matchingDepartments = departments.where((department) {
      return department.name == selectedDepartment;
    }).toList();

    if (matchingDepartments.isEmpty) {
      return [];
    }

    final selectedDepartmentIds = matchingDepartments.map((department) {
      return department.id;
    }).toSet();

    final sourceModels = _showInactive
        ? state.inactiveJobTitleModels
        : state.jobTitleModels;

    return sourceModels.where((jobTitle) {
      return selectedDepartmentIds.contains(jobTitle.departmentId);
    }).toList();
  }
}
