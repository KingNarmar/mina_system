import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';

import 'sections/transaction_details_section.dart';
import 'sections/transaction_tool_selection.dart';
import 'sections/transaction_type_picker.dart';
import 'sections/transaction_worker_selection.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({
    super.key,
    required this.companyId,
    required this.onSave,
    this.initialType,
    this.workersRepo,
    this.toolsRepo,
  });

  final String companyId;
  final Future<String?> Function(TransactionModel transaction) onSave;
  final TransactionType? initialType;
  final WorkersRepo? workersRepo;
  final ToolsRepo? toolsRepo;

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  late final WorkersRepo _workersRepo;
  late final ToolsRepo _toolsRepo;

  String? _selectedType;
  WorkerModel? _selectedWorker;
  ToolModel? _selectedTool;
  String? _selectedImagePath;
  String? _submitErrorMessage;
  String? _optionsErrorMessage;
  bool _isLoadingOptions = true;
  List<WorkerModel> _activeWorkers = const [];
  List<ToolModel> _activeTools = const [];

  TransactionType? get _selectedTransactionType {
    final selectedType = _selectedType;

    if (selectedType == null) {
      return null;
    }

    return getTransactionTypeFromLabel(selectedType);
  }

  bool get _isProofImageRequired {
    final type = _selectedTransactionType;

    return type == TransactionType.issue || type == TransactionType.damaged;
  }

  bool get _isNoteRequired {
    final type = _selectedTransactionType;

    return type == TransactionType.lost || type == TransactionType.damaged;
  }

  @override
  void initState() {
    super.initState();

    _workersRepo = widget.workersRepo ?? WorkersRepo();
    _toolsRepo = widget.toolsRepo ?? ToolsRepo();

    final initialType = widget.initialType;

    if (initialType != null) {
      _selectedType = getTransactionTypeLabel(initialType);
    }

    _loadActiveTransactionOptions();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = context.watch<TransactionsCubit>().state;

    final isSubmitting = transactionsState.isActionSubmitting(
      TransactionsSubmissionKeys.add,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: _buildContent(context: context, isSubmitting: isSubmitting),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isSubmitting,
  }) {
    if (_isLoadingOptions) {
      return const _TransactionOptionsLoadingView();
    }

    if (_optionsErrorMessage != null) {
      return _TransactionOptionsFailureView(
        message: _optionsErrorMessage!,
        onRetry: () {
          _loadActiveTransactionOptions();
        },
      );
    }

    if (_activeWorkers.isEmpty || _activeTools.isEmpty) {
      return _TransactionOptionsFailureView(
        message: _buildMissingActiveOptionsMessage(),
        onRetry: () {
          _loadActiveTransactionOptions();
        },
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Transaction', style: AppTextStyles.title),
          const Gap(20),
          TransactionTypePicker(
            selectedType: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
                _submitErrorMessage = null;
              });
            },
          ),
          const Gap(12),
          TransactionWorkerSelection(
            workers: _activeWorkers,
            selectedWorker: _selectedWorker,
            onSelected: (worker) {
              setState(() {
                _selectedWorker = worker;
                _submitErrorMessage = null;
              });
            },
          ),
          const Gap(12),
          TransactionToolSelection(
            tools: _activeTools,
            selectedTool: _selectedTool,
            onSelected: (tool) {
              setState(() {
                _selectedTool = tool;
                _submitErrorMessage = null;
              });
            },
          ),
          const Gap(12),
          TransactionDetailsSection(
            quantityController: _quantityController,
            noteController: _noteController,
            selectedImagePath: _selectedImagePath,
            isProofImageRequired: _isProofImageRequired,
            isNoteRequired: _isNoteRequired,
            maxReturnQuantity: _getMaxReturnQuantity(context),
            onImageSelected: (imagePath) {
              setState(() {
                _selectedImagePath = imagePath;
                _submitErrorMessage = null;
              });
            },
          ),
          if (_submitErrorMessage != null) ...[
            const Gap(16),
            _TransactionFormErrorMessage(message: _submitErrorMessage!),
          ],
          const Gap(20),
          MainButton(
            text: 'Save Transaction',
            isLoading: isSubmitting,
            onPressed: _onSavePressed,
          ),
        ],
      ),
    );
  }

  Future<void> _loadActiveTransactionOptions() async {
    final companyId = widget.companyId.trim();

    if (companyId.isEmpty) {
      setState(() {
        _isLoadingOptions = false;
        _optionsErrorMessage = 'Company ID was not found.';
      });

      return;
    }

    setState(() {
      _isLoadingOptions = true;
      _optionsErrorMessage = null;
      _submitErrorMessage = null;
    });

    try {
      final workers = await _workersRepo.getWorkers(
        companyId: companyId,
        status: 'active',
      );
      final tools = await _toolsRepo.getTools(
        companyId: companyId,
        status: 'active',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _activeWorkers = workers.where(_isActiveWorker).toList();
        _activeTools = tools.where(_isActiveTool).toList();
        _selectedWorker = _activeWorkers.contains(_selectedWorker)
            ? _selectedWorker
            : null;
        _selectedTool = _activeTools.contains(_selectedTool)
            ? _selectedTool
            : null;
        _isLoadingOptions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingOptions = false;
        _optionsErrorMessage =
            'Unable to load active workers and tools. Please try again.';
      });
    }
  }

  bool _isActiveWorker(WorkerModel worker) {
    return worker.status.trim().toLowerCase() == 'active';
  }

  bool _isActiveTool(ToolModel tool) {
    return tool.status.trim().toLowerCase() == 'active';
  }

  String _buildMissingActiveOptionsMessage() {
    if (_activeWorkers.isEmpty && _activeTools.isEmpty) {
      return 'No active workers or active tools are available for transactions.';
    }

    if (_activeWorkers.isEmpty) {
      return 'No active workers are available for transactions.';
    }

    return 'No active tools are available for transactions.';
  }

  double? _getMaxReturnQuantity(BuildContext context) {
    final selectedTransactionType = _selectedTransactionType;

    if (selectedTransactionType == null) {
      return null;
    }

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

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitErrorMessage = null;
    });

    final selectedWorker = _selectedWorker!;
    final selectedTool = _selectedTool!;
    final cleanNote = _noteController.text.trim();

    final transaction = TransactionModel(
      transactionCode: '',
      type: _selectedTransactionType!,
      workerId: selectedWorker.id,
      workerHrCode: selectedWorker.hrCode,
      workerName: selectedWorker.name,
      workerDepartment: selectedWorker.department,
      workerJobTitle: selectedWorker.jobTitle,
      toolId: selectedTool.id,
      toolCode: selectedTool.toolCode,
      toolName: selectedTool.toolName,
      unit: selectedTool.unit,
      toolCategory: selectedTool.category,
      quantity: double.parse(_quantityController.text.trim()),
      dateTime: DateTime.now(),
      imagePath: _selectedImagePath,
      note: cleanNote.isEmpty ? null : cleanNote,
    );

    final errorMessage = await widget.onSave(transaction);

    if (!mounted || errorMessage == null) {
      return;
    }

    setState(() {
      _submitErrorMessage = errorMessage;
    });
  }
}

class _TransactionOptionsLoadingView extends StatelessWidget {
  const _TransactionOptionsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Transaction', style: AppTextStyles.title),
        Gap(24),
        Center(child: CircularProgressIndicator()),
        Gap(16),
        Center(
          child: Text(
            'Loading active workers and tools...',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

class _TransactionOptionsFailureView extends StatelessWidget {
  const _TransactionOptionsFailureView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Transaction', style: AppTextStyles.title),
        const Gap(20),
        _TransactionFormErrorMessage(message: message),
        const Gap(16),
        MainButton(text: 'Retry', onPressed: onRetry),
      ],
    );
  }
}

class _TransactionFormErrorMessage extends StatelessWidget {
  const _TransactionFormErrorMessage({required this.message});

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
