import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

class AddWorkerForm extends StatefulWidget {
  const AddWorkerForm({super.key, required this.onSave});

  final ValueChanged<WorkerModel> onSave;

  @override
  State<AddWorkerForm> createState() => _AddWorkerFormState();
}

class _AddWorkerFormState extends State<AddWorkerForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _hrCodeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _jobTitleController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _hrCodeController.dispose();
    _departmentController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('Add Worker', style: AppTextStyles.title),
              const SizedBox(height: 20),
              CustomTextFormField(
                hint: 'Worker Name',
                controller: _nameController,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                hint: 'HR Code',
                controller: _hrCodeController,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                hint: 'Department',
                controller: _departmentController,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                hint: 'Job Title',
                controller: _jobTitleController,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 20),
              MainButton(text: 'Save Worker', onPressed: _onSavePressed),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final worker = WorkerModel(
      name: _nameController.text.trim(),
      hrCode: _hrCodeController.text.trim(),
      department: _departmentController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      activeCustodyCount: 0,
    );

    widget.onSave(worker);
    Navigator.pop(context);
  }
}
