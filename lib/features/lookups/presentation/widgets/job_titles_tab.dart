import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_job_title_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_job_title_lookup.dart';
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
                else if (jobTitles.isEmpty)
                  EmptyLookupMessage(
                    message: _showInactive
                        ? 'No inactive job titles found for this department'
                        : 'No job titles found for this department',
                  )
                else
                  ...jobTitles.map((jobTitle) {
                    return LookupListTile(
                      title: jobTitle,
                      subtitle: _showInactive
                          ? selectedDepartmentIsActive
                                ? 'Inactive Job Title'
                                : 'Inactive Department - restore department first'
                          : selectedDepartment,
                      onDelete: !_showInactive && widget.canDeleteLookups
                          ? () {
                              confirmDeleteLookup(
                                context: context,
                                title: 'Deactivate Job Title',
                                message:
                                    'Are you sure you want to deactivate $jobTitle?',
                                onConfirm: () async {
                                  await deleteJobTitleLookup(
                                    context: context,
                                    department: selectedDepartment,
                                    jobTitle: jobTitle,
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
                              await context
                                  .read<LookupsCubit>()
                                  .reactivateJobTitle(
                                    department: selectedDepartment,
                                    jobTitle: jobTitle,
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
}
