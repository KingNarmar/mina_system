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

class JobTitlesTab extends StatefulWidget {
  const JobTitlesTab({
    super.key,
    required this.canCreateLookups,
    required this.canDeleteLookups,
    this.isCompactInputMode = false,
    this.onLookupInputFocusChanged,
  });

  final bool canCreateLookups;
  final bool canDeleteLookups;
  final bool isCompactInputMode;
  final ValueChanged<bool>? onLookupInputFocusChanged;

  @override
  State<JobTitlesTab> createState() => _JobTitlesTabState();
}

class _JobTitlesTabState extends State<JobTitlesTab> {
  final _jobTitleController = TextEditingController();

  String? _selectedDepartment;

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
        final jobTitles = state.getJobTitlesByDepartment(_selectedDepartment);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: LookupCard(
            title: 'Manage Job Titles',
            child: Column(
              children: [
                if (widget.isCompactInputMode &&
                    _selectedDepartment != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Department: $_selectedDepartment',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  CustomDropdownFormField(
                    hint: 'Select Department',
                    value: _selectedDepartment,
                    items: state.departments,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                  ),
                ],
                if (widget.canCreateLookups) ...[
                  Gap(widget.isCompactInputMode ? 8 : 12),
                  LookupAddRow(
                    hint: 'Job Title',
                    controller: _jobTitleController,
                    isCompactInputMode: widget.isCompactInputMode,
                    onFocusChanged: widget.onLookupInputFocusChanged,
                    onAdd: () async {
                      final isAdded = await addJobTitleLookup(
                        context: context,
                        department: _selectedDepartment,
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
                if (_selectedDepartment == null)
                  const EmptyLookupMessage(
                    message: 'Select a department to view its job titles',
                  )
                else if (jobTitles.isEmpty)
                  const EmptyLookupMessage(
                    message: 'No job titles found for this department',
                  )
                else
                  ...jobTitles.map((jobTitle) {
                    return LookupListTile(
                      title: jobTitle,
                      subtitle: _selectedDepartment!,
                      onDelete: widget.canDeleteLookups
                          ? () {
                              confirmDeleteLookup(
                                context: context,
                                title: 'Delete Job Title',
                                message:
                                    'Are you sure you want to delete $jobTitle?',
                                onConfirm: () async {
                                  await deleteJobTitleLookup(
                                    context: context,
                                    department: _selectedDepartment!,
                                    jobTitle: jobTitle,
                                  );
                                },
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
