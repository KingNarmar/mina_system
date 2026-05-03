import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_helpers.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_validators.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/transactions/presentation/widgets/form/transaction_image_picker_field.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:gap/gap.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key, required this.onSave});

  final ValueChanged<TransactionModel> onSave;

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedType;
  WorkerModel? _selectedWorker;
  ToolModel? _selectedTool;
  String? _selectedImagePath;

  bool get _isIssueSelected {
    if (_selectedType == null) {
      return false;
    }

    return getTransactionTypeFromLabel(_selectedType!) == TransactionType.issue;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workers = context.watch<WorkersCubit>().state.workers;
    final tools = context.watch<ToolsCubit>().state.tools;

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
              const Text('Add Transaction', style: AppTextStyles.title),
              const Gap(20),
              CustomDropdownFormField(
                hint: 'Transaction Type',
                value: _selectedType,
                items: transactionTypeLabels,
                validator: validateRequiredTransactionDropdown,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const Gap(12),
              SearchableSelectionField<WorkerModel>(
                hint: 'Search Worker by HR Code or Name',
                items: workers,
                selectedItem: _selectedWorker,
                itemLabelBuilder: buildWorkerOptionLabel,
                validator: validateRequiredTransactionSelection,
                searchMatcher: (worker, query) {
                  final hrCode = worker.hrCode.trim().toLowerCase();
                  final name = worker.name.trim().toLowerCase();
                  final department = worker.department.trim().toLowerCase();

                  return hrCode.contains(query) ||
                      name.contains(query) ||
                      department.contains(query);
                },
                onItemSelected: (worker) {
                  setState(() {
                    _selectedWorker = worker;
                  });
                },
              ),
              const Gap(12),
              SearchableSelectionField<ToolModel>(
                hint: 'Search Tool by Code or Name',
                items: tools,
                selectedItem: _selectedTool,
                itemLabelBuilder: buildToolOptionLabel,
                validator: validateRequiredTransactionSelection,
                searchMatcher: (tool, query) {
                  final toolCode = tool.toolCode.trim().toLowerCase();
                  final toolName = tool.toolName.trim().toLowerCase();
                  final category = tool.category.trim().toLowerCase();

                  return toolCode.contains(query) ||
                      toolName.contains(query) ||
                      category.contains(query);
                },
                onItemSelected: (tool) {
                  setState(() {
                    _selectedTool = tool;
                  });
                },
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Quantity',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return validateTransactionQuantity(
                    value,
                    maxReturnQuantity: _getMaxReturnQuantity(context),
                  );
                },
              ),
              const Gap(12),
              TransactionImagePickerField(
                imagePath: _selectedImagePath,
                isRequired: _isIssueSelected,
                onImageSelected: (imagePath) {
                  setState(() {
                    _selectedImagePath = imagePath;
                  });
                },
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Note (optional)',
                controller: _noteController,
              ),
              const Gap(20),
              MainButton(text: 'Save Transaction', onPressed: _onSavePressed),
            ],
          ),
        ),
      ),
    );
  }

  double? _getMaxReturnQuantity(BuildContext context) {
    if (_selectedType == null) {
      return null;
    }

    final selectedTransactionType = getTransactionTypeFromLabel(_selectedType!);

    if (!isClosingTransactionType(selectedTransactionType)) {
      return null;
    }

    final selectedWorker = _selectedWorker;
    final selectedTool = _selectedTool;

    if (selectedWorker == null || selectedTool == null) {
      return null;
    }

    return context.read<TransactionsCubit>().getWorkerToolBalance(
      workerHrCode: selectedWorker.hrCode,
      toolCode: selectedTool.toolCode,
    );
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedWorker = _selectedWorker!;
    final selectedTool = _selectedTool!;

    final cleanNote = _noteController.text.trim();

    final transaction = TransactionModel(
      transactionCode: context
          .read<TransactionsCubit>()
          .generateNextTransactionCode(),
      type: getTransactionTypeFromLabel(_selectedType!),
      workerHrCode: selectedWorker.hrCode,
      workerName: selectedWorker.name,
      toolCode: selectedTool.toolCode,
      toolName: selectedTool.toolName,
      unit: selectedTool.unit,
      quantity: double.parse(_quantityController.text.trim()),
      dateTime: DateTime.now(),
      imagePath: _selectedImagePath,
      note: cleanNote.isEmpty ? null : cleanNote,
    );

    widget.onSave(transaction);
    Navigator.pop(context);
  }
}
