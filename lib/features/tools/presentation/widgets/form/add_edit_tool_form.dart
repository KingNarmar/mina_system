import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/functions/tool_form_validators.dart';

class AddEditToolForm extends StatefulWidget {
  const AddEditToolForm({
    super.key,
    required this.onSave,
    this.initialTool,
    this.generatedToolCode,
    this.isToolCodeAlreadyUsed,
    this.isToolNameAlreadyUsed,
  });

  final ValueChanged<ToolModel> onSave;
  final ToolModel? initialTool;
  final String? generatedToolCode;
  final ToolCodeValidator? isToolCodeAlreadyUsed;
  final ToolNameValidator? isToolNameAlreadyUsed;

  @override
  State<AddEditToolForm> createState() => _AddEditToolFormState();
}

class _AddEditToolFormState extends State<AddEditToolForm> {
  final _formKey = GlobalKey<FormState>();

  final _toolCodeController = TextEditingController();
  final _toolNameController = TextEditingController();

  String? _selectedUnit;
  String? _selectedCategory;

  bool get _isEditMode => widget.initialTool != null;

  @override
  void initState() {
    super.initState();

    final tool = widget.initialTool;

    if (tool != null) {
      _toolCodeController.text = tool.toolCode;
      _toolNameController.text = tool.toolName;
      _selectedUnit = tool.unit;
      _selectedCategory = tool.category;
      return;
    }

    _toolCodeController.text = widget.generatedToolCode ?? '';
  }

  @override
  void dispose() {
    _toolCodeController.dispose();
    _toolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, lookupsState) {
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
                    _isEditMode ? 'Edit Tool' : 'Add Tool',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    hint: 'Tool Code',
                    controller: _toolCodeController,
                    readOnly: true,
                    validator: (value) {
                      return validateToolCode(
                        value: value,
                        initialTool: widget.initialTool,
                        isToolCodeAlreadyUsed: widget.isToolCodeAlreadyUsed,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    hint: 'Tool Name',
                    controller: _toolNameController,
                    validator: (value) {
                      return validateToolName(
                        value: value,
                        initialTool: widget.initialTool,
                        isToolNameAlreadyUsed: widget.isToolNameAlreadyUsed,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomDropdownFormField(
                    hint: 'Unit',
                    value: _selectedUnit,
                    items: lookupsState.toolUnits,
                    validator: validateRequiredDropdown,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomDropdownFormField(
                    hint: 'Category',
                    value: _selectedCategory,
                    items: lookupsState.toolCategories,
                    validator: validateRequiredDropdown,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  MainButton(
                    text: _isEditMode ? 'Update Tool' : 'Save Tool',
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

    final tool = ToolModel(
      toolCode: _toolCodeController.text.trim(),
      toolName: _toolNameController.text.trim(),
      unit: _selectedUnit!.trim(),
      category: _selectedCategory!.trim(),
      activeCustodyCount: widget.initialTool?.activeCustodyCount ?? 0,
    );

    widget.onSave(tool);
    Navigator.pop(context);
  }
}