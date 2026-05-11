import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';

import 'document_template_form_helpers.dart';
import 'document_template_general_fields.dart';
import 'document_template_signature_fields.dart';

class DocumentTemplateCard extends StatefulWidget {
  const DocumentTemplateCard({
    super.key,
    required this.documentTemplate,
    required this.isSaving,
  });

  final CompanyDocumentTemplateModel documentTemplate;
  final bool isSaving;

  @override
  State<DocumentTemplateCard> createState() => _DocumentTemplateCardState();
}

class _DocumentTemplateCardState extends State<DocumentTemplateCard> {
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
    final reportTypeTitle = DocumentTemplateFormHelpers.formatReportType(
      widget.documentTemplate.reportType,
    );

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
            DocumentTemplateGeneralFields(
              documentTitleController: _documentTitleController,
              documentCodeController: _documentCodeController,
              issueNoController: _issueNoController,
              revisionNoController: _revisionNoController,
              effectiveDateController: _effectiveDateController,
              onEffectiveDateTap: _selectEffectiveDate,
            ),
            const Gap(12),
            DocumentTemplateSignatureFields(
              preparedByTitleController: _preparedByTitleController,
              checkedByTitleController: _checkedByTitleController,
              approvedByTitleController: _approvedByTitleController,
              workerSignatureLabelController: _workerSignatureLabelController,
              managerSignatureLabelController: _managerSignatureLabelController,
              storekeeperSignatureLabelController:
                  _storekeeperSignatureLabelController,
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
      text: DocumentTemplateFormHelpers.formatDate(template.effectiveDate),
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
      _effectiveDateController.text = DocumentTemplateFormHelpers.formatDate(
        selectedDate,
      );
    });
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
      preparedByTitle: DocumentTemplateFormHelpers.emptyToNull(
        _preparedByTitleController.text,
      ),
      checkedByTitle: DocumentTemplateFormHelpers.emptyToNull(
        _checkedByTitleController.text,
      ),
      approvedByTitle: DocumentTemplateFormHelpers.emptyToNull(
        _approvedByTitleController.text,
      ),
      workerSignatureLabel: DocumentTemplateFormHelpers.emptyToNull(
        _workerSignatureLabelController.text,
      ),
      managerSignatureLabel: DocumentTemplateFormHelpers.emptyToNull(
        _managerSignatureLabelController.text,
      ),
      storekeeperSignatureLabel: DocumentTemplateFormHelpers.emptyToNull(
        _storekeeperSignatureLabelController.text,
      ),
      isActive: _isActive,
    );

    context.read<CompanySettingsCubit>().updateCompanyDocumentTemplate(
      documentTemplate: updatedTemplate,
    );
  }
}
