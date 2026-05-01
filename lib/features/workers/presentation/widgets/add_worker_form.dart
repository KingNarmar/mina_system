import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/functions/worker_form_validators.dart';

class AddWorkerForm extends StatefulWidget {
  const AddWorkerForm({
    super.key,
    required this.onSave,
    this.initialWorker,
    this.isHrCodeAlreadyUsed,
  });

  final ValueChanged<WorkerModel> onSave;
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
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    hint: 'Worker Name',
                    controller: _nameController,
                    validator: WorkerFormValidators.requiredWorkerTextValidator,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    hint: 'HR Code',
                    controller: _hrCodeController,
                    validator: (value) => WorkerFormValidators.hrCodeValidator(
                      value,
                      isHrCodeAlreadyUsed: widget.isHrCodeAlreadyUsed,
                      initialHrCode: widget.initialWorker?.hrCode,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomDropdownFormField(
                    hint: 'Department',
                    value: _selectedDepartment,
                    items: lookupsState.departments,
                    validator: WorkerFormValidators.requiredWorkerDropdownValidator,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                        _selectedJobTitle = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomDropdownFormField(
                    hint: _selectedDepartment == null
                        ? 'Select Department First'
                        : 'Job Title',
                    value: _selectedJobTitle,
                    items: filteredJobTitles,
                    validator: WorkerFormValidators.requiredWorkerDropdownValidator,
                    onChanged: (value) {
                      setState(() {
                        _selectedJobTitle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  MainButton(
                    text: _isEditMode ? 'Update Worker' : 'Save Worker',
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

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final worker = WorkerModel(
      name: _nameController.text.trim(),
      hrCode: _hrCodeController.text.trim(),
      department: _selectedDepartment!.trim(),
      jobTitle: _selectedJobTitle!.trim(),
      activeCustodyCount: widget.initialWorker?.activeCustodyCount ?? 0,
    );

    widget.onSave(worker);
    Navigator.pop(context);
  }
}
