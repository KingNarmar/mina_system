import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';

class CompanyDocumentTemplatesForm extends StatelessWidget {
  const CompanyDocumentTemplatesForm({
    super.key,
    required this.documentTemplates,
    required this.isSaving,
  });

  final List<CompanyDocumentTemplateModel> documentTemplates;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanySettingsCubit, CompanySettingsState>(
      listenWhen: (previous, current) {
        return previous is CompanySettingsLoaded &&
            previous.isUpdatingDocumentTemplate &&
            current is CompanySettingsLoaded &&
            !current.isUpdatingDocumentTemplate;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document template updated.')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Document Templates', style: AppTextStyles.title),
            const Gap(8),
            const Text(
              'Control document titles, codes, revision details, effective dates, and signature labels used later in PDF reports.',
              style: AppTextStyles.body,
            ),
            const Gap(20),
            if (documentTemplates.isEmpty)
              const _EmptyDocumentTemplatesView()
            else
              ...documentTemplates.map(
                (template) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DocumentTemplateCard(
                      key: ValueKey(template.id),
                      documentTemplate: template,
                      isSaving: isSaving,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDocumentTemplatesView extends StatelessWidget {
  const _EmptyDocumentTemplatesView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'No document templates found for this company.',
        style: AppTextStyles.body,
      ),
    );
  }
}

class _DocumentTemplateCard extends StatefulWidget {
  const _DocumentTemplateCard({
    super.key,
    required this.documentTemplate,
    required this.isSaving,
  });

  final CompanyDocumentTemplateModel documentTemplate;
  final bool isSaving;

  @override
  State<_DocumentTemplateCard> createState() => _DocumentTemplateCardState();
}

class _DocumentTemplateCardState extends State<_DocumentTemplateCard> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _documentTitleController;
  late final TextEditingController _documentCodeController;
  late final TextEditingController _issueNoController;
  late final TextEditingController _revisionNoController;
  late final TextEditingController _effectiveDateController;
  late final TextEditingController _preparedByTitleController;
  late final TextEditingController _checkedByTitleController;
  late final TextEditingController _approvedByTitleController;
  late final TextEditingController _workerSignatureLabelController;
  late final TextEditingController _managerSignatureLabelController;
  late final TextEditingController _storekeeperSignatureLabelController;

  late DateTime _effectiveDate;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _setInitialValues();
  }

  @override
  void dispose() {
    _documentTitleController.dispose();
    _documentCodeController.dispose();
    _issueNoController.dispose();
    _revisionNoController.dispose();
    _effectiveDateController.dispose();
    _preparedByTitleController.dispose();
    _checkedByTitleController.dispose();
    _approvedByTitleController.dispose();
    _workerSignatureLabelController.dispose();
    _managerSignatureLabelController.dispose();
    _storekeeperSignatureLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportTypeTitle = _formatReportType(widget.documentTemplate.reportType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(reportTypeTitle, style: AppTextStyles.body),
            const Gap(12),
            CustomTextFormField(
              hint: 'Document Title',
              controller: _documentTitleController,
              validator: _validateRequired,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Document Code',
              controller: _documentCodeController,
              validator: _validateRequired,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Issue No.',
              controller: _issueNoController,
              validator: _validateRequired,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Revision No.',
              controller: _revisionNoController,
              validator: _validateRequired,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Effective Date',
              controller: _effectiveDateController,
              readOnly: true,
              onTap: _selectEffectiveDate,
              validator: _validateRequired,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Prepared By Title',
              controller: _preparedByTitleController,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Checked By Title',
              controller: _checkedByTitleController,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Approved By Title',
              controller: _approvedByTitleController,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Worker Signature Label',
              controller: _workerSignatureLabelController,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Manager Signature Label',
              controller: _managerSignatureLabelController,
            ),
            const Gap(12),
            CustomTextFormField(
              hint: 'Storekeeper Signature Label',
              controller: _storekeeperSignatureLabelController,
            ),
            const Gap(8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active', style: AppTextStyles.body),
              value: _isActive,
              activeThumbColor: AppColors.accent,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const Gap(12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                child: MainButton(
                  text: 'Save',
                  isLoading: widget.isSaving,
                  onPressed: _onSavePressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setInitialValues() {
    final template = widget.documentTemplate;

    _effectiveDate = template.effectiveDate;
    _isActive = template.isActive;

    _documentTitleController = TextEditingController(
      text: template.documentTitle,
    );
    _documentCodeController = TextEditingController(
      text: template.documentCode,
    );
    _issueNoController = TextEditingController(text: template.issueNo);
    _revisionNoController = TextEditingController(text: template.revisionNo);
    _effectiveDateController = TextEditingController(
      text: _formatDate(template.effectiveDate),
    );
    _preparedByTitleController = TextEditingController(
      text: template.preparedByTitle ?? '',
    );
    _checkedByTitleController = TextEditingController(
      text: template.checkedByTitle ?? '',
    );
    _approvedByTitleController = TextEditingController(
      text: template.approvedByTitle ?? '',
    );
    _workerSignatureLabelController = TextEditingController(
      text: template.workerSignatureLabel ?? '',
    );
    _managerSignatureLabelController = TextEditingController(
      text: template.managerSignatureLabel ?? '',
    );
    _storekeeperSignatureLabelController = TextEditingController(
      text: template.storekeeperSignatureLabel ?? '',
    );
  }

  Future<void> _selectEffectiveDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _effectiveDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _effectiveDate = selectedDate;
      _effectiveDateController.text = _formatDate(selectedDate);
    });
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final template = widget.documentTemplate;

    final updatedTemplate = CompanyDocumentTemplateModel(
      id: template.id,
      companyId: template.companyId,
      reportType: template.reportType,
      documentTitle: _documentTitleController.text,
      documentCode: _documentCodeController.text,
      issueNo: _issueNoController.text,
      revisionNo: _revisionNoController.text,
      effectiveDate: _effectiveDate,
      preparedByTitle: _emptyToNull(_preparedByTitleController.text),
      checkedByTitle: _emptyToNull(_checkedByTitleController.text),
      approvedByTitle: _emptyToNull(_approvedByTitleController.text),
      workerSignatureLabel: _emptyToNull(
        _workerSignatureLabelController.text,
      ),
      managerSignatureLabel: _emptyToNull(
        _managerSignatureLabelController.text,
      ),
      storekeeperSignatureLabel: _emptyToNull(
        _storekeeperSignatureLabelController.text,
      ),
      isActive: _isActive,
    );

    context.read<CompanySettingsCubit>().updateCompanyDocumentTemplate(
          documentTemplate: updatedTemplate,
        );
  }

  String? _emptyToNull(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return null;
    }
    return trimmedValue;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatReportType(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
      final lowerWord = word.toLowerCase();
      return '${lowerWord[0].toUpperCase()}${lowerWord.substring(1)}';
    }).join(' ');
  }
}