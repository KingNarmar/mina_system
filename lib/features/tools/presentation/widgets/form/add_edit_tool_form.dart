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
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/functions/tool_form_validators.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class AddEditToolForm extends StatefulWidget {
  const AddEditToolForm({
    super.key,
    required this.onSave,
    this.initialTool,
    this.isToolCodeAlreadyUsed,
    this.isToolNameAlreadyUsed,
  });

  final Future<String?> Function(ToolModel tool) onSave;
  final ToolModel? initialTool;
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
  String? _submitErrorMessage;

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
    }
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
        final toolsState = context.watch<ToolsCubit>().state;
        final initialToolCode = widget.initialTool?.toolCode;

        final isSubmitting =
            _isEditMode && initialToolCode != null && initialToolCode.isNotEmpty
            ? toolsState.isActionSubmitting(
                ToolsSubmissionKeys.update(initialToolCode),
              )
            : toolsState.isActionSubmitting(ToolsSubmissionKeys.add);

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
                  const Gap(20),

                  if (_isEditMode) ...[
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
                    const Gap(12),
                  ],

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
                  const Gap(12),

                  CustomDropdownFormField(
                    hint: 'Unit',
                    value: _selectedUnit,
                    items: lookupsState.toolUnits,
                    validator: validateRequiredDropdown,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value;
                        _submitErrorMessage = null;
                      });
                    },
                  ),
                  const Gap(12),

                  CustomDropdownFormField(
                    hint: 'Category',
                    value: _selectedCategory,
                    items: lookupsState.toolCategories,
                    validator: validateRequiredDropdown,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
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
                    text: _isEditMode ? 'Update Tool' : 'Save Tool',
                    isLoading: isSubmitting,
                    onPressed: () => _onSavePressed(lookupsState),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSavePressed(LookupsState lookupsState) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitErrorMessage = null;
    });

    final selectedUnitName = _selectedUnit!.trim();
    final selectedCategoryName = _selectedCategory!.trim();

    final selectedUnitModel = lookupsState.toolUnitModels
        .where((unit) => unit.name == selectedUnitName)
        .firstOrNull;

    final selectedCategoryModel = lookupsState.toolCategoryModels
        .where((category) => category.name == selectedCategoryName)
        .firstOrNull;

    if (selectedUnitModel == null || selectedCategoryModel == null) {
      setState(() {
        _submitErrorMessage = 'Selected unit or category was not found.';
      });
      return;
    }

    final initialTool = widget.initialTool;

    final tool = ToolModel(
      id: initialTool?.id,
      companyId: initialTool?.companyId,
      toolCode: _isEditMode ? _toolCodeController.text.trim() : '',
      toolName: _toolNameController.text.trim(),
      unit: selectedUnitModel.name,
      category: selectedCategoryModel.name,
      unitId: selectedUnitModel.id,
      categoryId: selectedCategoryModel.id,
      description: initialTool?.description,
      status: initialTool?.status ?? 'active',
      createdByProfileId: initialTool?.createdByProfileId,
      createdAt: initialTool?.createdAt,
      updatedAt: initialTool?.updatedAt,
    );

    final errorMessage = await widget.onSave(tool);

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
          const Icon(AppIcons.error, color: AppColors.error, size: 20),
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
