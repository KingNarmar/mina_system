import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/worker_form_validators.dart';

class AddWorkerForm extends StatefulWidget {
  const AddWorkerForm({
    super.key,
    required this.onSave,
    this.initialWorker,
    this.isHrCodeAlreadyUsed,
  });

  final Future<String?> Function(WorkerModel worker) onSave;
  final WorkerModel? initialWorker;
  final HrCodeValidator? isHrCodeAlreadyUsed;

  @override
  State<AddWorkerForm> createState() => _AddWorkerFormState();
}

class _AddWorkerFormState extends State<AddWorkerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hrCodeController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedJobTitle;
  String? _submitErrorMessage;

  bool get _isEditMode => widget.initialWorker != null;

  @override
  void initState() {
    super.initState();

    final worker = widget.initialWorker;

    if (worker != null) {
      _nameController.text = worker.name;
      _hrCodeController.text = worker.hrCode;
      _selectedDepartment = worker.department;
      _selectedJobTitle = worker.jobTitle;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hrCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, lookupsState) {
        final filteredJobTitles = lookupsState.getJobTitlesByDepartment(
          _selectedDepartment,
        );

        final isSubmitting = context.watch<WorkersCubit>().state.isSubmitting;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Worker' : 'Add Worker',
                    style: AppTextStyles.title,
                  ),
                  const Gap(20),
                  CustomTextFormField(
                    hint: 'Worker Name',
                    controller: _nameController,
                    validator: WorkerFormValidators.requiredWorkerTextValidator,
                  ),
                  const Gap(12),
                  CustomTextFormField(
                    hint: 'HR Code',
                    controller: _hrCodeController,
                    validator: (value) => WorkerFormValidators.hrCodeValidator(
                      value,
                      isHrCodeAlreadyUsed: widget.isHrCodeAlreadyUsed,
                      initialHrCode: widget.initialWorker?.hrCode,
                    ),
                  ),
                  const Gap(12),
                  CustomDropdownFormField(
                    hint: 'Department',
                    value: _selectedDepartment,
                    items: lookupsState.departments,
                    validator:
                        WorkerFormValidators.requiredWorkerDropdownValidator,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                        _selectedJobTitle = null;
                        _submitErrorMessage = null;
                      });
                    },
                  ),
                  const Gap(12),
                  CustomDropdownFormField(
                    hint: _selectedDepartment == null
                        ? 'Select Department First'
                        : 'Job Title',
                    value: _selectedJobTitle,
                    items: filteredJobTitles,
                    validator:
                        WorkerFormValidators.requiredWorkerDropdownValidator,
                    onChanged: (value) {
                      setState(() {
                        _selectedJobTitle = value;
                        _submitErrorMessage = null;
                      });
                    },
                  ),
                  if (_submitErrorMessage != null) ...[
                    const Gap(16),
                    _FormErrorMessage(message: _submitErrorMessage!),
                  ],
                  const Gap(20),
                  MainButton(
                    text: _isEditMode ? 'Update Worker' : 'Save Worker',
                    isLoading: isSubmitting,
                    onPressed: _onSavePressed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitErrorMessage = null;
    });

    final lookupsState = context.read<LookupsCubit>().state;

    final departmentModel = lookupsState.departmentModels.where((department) {
      return _isSameLookupName(department.name, _selectedDepartment ?? '');
    }).firstOrNull;

    final jobTitleModel = lookupsState.jobTitleModels.where((jobTitle) {
      final isSameDepartment = jobTitle.departmentId == departmentModel?.id;
      final isSameJobTitle = _isSameLookupName(
        jobTitle.name,
        _selectedJobTitle ?? '',
      );

      return isSameDepartment && isSameJobTitle;
    }).firstOrNull;

    final worker = WorkerModel(
      id: widget.initialWorker?.id,
      companyId: widget.initialWorker?.companyId,
      workerCode: widget.initialWorker?.workerCode,
      name: _nameController.text.trim(),
      hrCode: _hrCodeController.text.trim(),
      department: _selectedDepartment!.trim(),
      jobTitle: _selectedJobTitle!.trim(),
      departmentId: departmentModel?.id,
      jobTitleId: jobTitleModel?.id,
      phone: widget.initialWorker?.phone,
      email: widget.initialWorker?.email,
      status: widget.initialWorker?.status ?? 'active',
      notes: widget.initialWorker?.notes,
      createdByProfileId: widget.initialWorker?.createdByProfileId,
      createdAt: widget.initialWorker?.createdAt,
      updatedAt: widget.initialWorker?.updatedAt,
    );

    final errorMessage = await widget.onSave(worker);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      setState(() {
        _submitErrorMessage = errorMessage;
      });
      return;
    }

    Navigator.pop(context);
  }

  bool _isSameLookupName(String firstValue, String secondValue) {
    return _normalizeLookupName(firstValue) ==
        _normalizeLookupName(secondValue);
  }

  String _normalizeLookupName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

class _FormErrorMessage extends StatelessWidget {
  const _FormErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
