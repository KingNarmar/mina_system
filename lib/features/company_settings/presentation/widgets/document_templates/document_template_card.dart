import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/functions/show_company_settings_audit_history.dart';

import 'document_template_form_helpers.dart';
import 'document_template_general_fields.dart';
import 'document_template_signature_fields.dart';

part 'document_template_card/document_template_chips.dart';
part 'document_template_card/document_template_header.dart';
part 'document_template_card/document_template_sections.dart';
part 'document_template_card/document_template_status_card.dart';

class DocumentTemplateCard extends StatefulWidget {
  const DocumentTemplateCard({
    super.key,
    required this.documentTemplate,
    required this.isSaving,
    required this.companyTimezone,
    this.dateFormat,
  });

  final CompanyDocumentTemplateModel documentTemplate;
  final bool isSaving;
  final String companyTimezone;
  final String? dateFormat;

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
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DocumentTemplateHeader(
              title: reportTypeTitle,
              documentCode: widget.documentTemplate.documentCode,
              revisionNo: widget.documentTemplate.revisionNo,
              isActive: _isActive,
              isSaving: widget.isSaving,
              onSavePressed: _onSavePressed,
              onAuditPressed: () {
                showCompanySettingsAuditHistory(
                  context,
                  entityType: 'company_document_template',
                  entityId: widget.documentTemplate.id,
                  title: '$reportTypeTitle Audit History',
                  timezone: widget.companyTimezone,
                  dateFormat: widget.dateFormat,
                );
              },
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DocumentTemplateSection(
                    icon: AppIcons.reportDocument,
                    title: 'Document Details',
                    description:
                        'Control the document title, code, issue number, revision number, and effective date.',
                    child: DocumentTemplateGeneralFields(
                      documentTitleController: _documentTitleController,
                      documentCodeController: _documentCodeController,
                      issueNoController: _issueNoController,
                      revisionNoController: _revisionNoController,
                      effectiveDateController: _effectiveDateController,
                      onEffectiveDateTap: _pickEffectiveDate,
                    ),
                  ),
                  const Gap(16),
                  _DocumentTemplateStatusCard(
                    isActive: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  const Gap(16),
                  _DocumentTemplateSection(
                    icon: AppIcons.responsibility,
                    title: 'Approval & Signatures',
                    description:
                        'Customize approval titles and signature labels printed on generated documents.',
                    child: DocumentTemplateSignatureFields(
                      preparedByTitleController: _preparedByTitleController,
                      checkedByTitleController: _checkedByTitleController,
                      approvedByTitleController: _approvedByTitleController,
                      workerSignatureLabelController:
                          _workerSignatureLabelController,
                      managerSignatureLabelController:
                          _managerSignatureLabelController,
                      storekeeperSignatureLabelController:
                          _storekeeperSignatureLabelController,
                    ),
                  ),
                  const Gap(16),
                  RecordAccountabilitySection(
                    createdBy: widget.documentTemplate.createdByDisplayName,
                    updatedBy: widget.documentTemplate.updatedByDisplayName,
                    createdAt: widget.documentTemplate.createdAt,
                    updatedAt: widget.documentTemplate.updatedAt,
                    timezone: widget.companyTimezone,
                    dateFormat: widget.dateFormat,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setInitialValues() {
    _documentTitleController = TextEditingController(
      text: widget.documentTemplate.documentTitle,
    );
    _documentCodeController = TextEditingController(
      text: widget.documentTemplate.documentCode,
    );
    _issueNoController = TextEditingController(
      text: widget.documentTemplate.issueNo,
    );
    _revisionNoController = TextEditingController(
      text: widget.documentTemplate.revisionNo,
    );
    _effectiveDate = widget.documentTemplate.effectiveDate;
    _effectiveDateController = TextEditingController(
      text: DocumentTemplateFormHelpers.formatDate(_effectiveDate),
    );
    _preparedByTitleController = TextEditingController(
      text: widget.documentTemplate.preparedByTitle,
    );
    _checkedByTitleController = TextEditingController(
      text: widget.documentTemplate.checkedByTitle,
    );
    _approvedByTitleController = TextEditingController(
      text: widget.documentTemplate.approvedByTitle,
    );
    _workerSignatureLabelController = TextEditingController(
      text: widget.documentTemplate.workerSignatureLabel,
    );
    _managerSignatureLabelController = TextEditingController(
      text: widget.documentTemplate.managerSignatureLabel,
    );
    _storekeeperSignatureLabelController = TextEditingController(
      text: widget.documentTemplate.storekeeperSignatureLabel,
    );
    _isActive = widget.documentTemplate.isActive;
  }

  Future<void> _pickEffectiveDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _effectiveDate,
      firstDate: DateTime(2020),
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

    final updatedTemplate = widget.documentTemplate.copyWith(
      documentTitle: _documentTitleController.text,
      documentCode: _documentCodeController.text,
      issueNo: _issueNoController.text,
      revisionNo: _revisionNoController.text,
      effectiveDate: _effectiveDate,
      preparedByTitle: _preparedByTitleController.text,
      checkedByTitle: _checkedByTitleController.text,
      approvedByTitle: _approvedByTitleController.text,
      workerSignatureLabel: _workerSignatureLabelController.text,
      managerSignatureLabel: _managerSignatureLabelController.text,
      storekeeperSignatureLabel: _storekeeperSignatureLabelController.text,
      isActive: _isActive,
    );

    context.read<CompanySettingsCubit>().updateCompanyDocumentTemplate(
      documentTemplate: updatedTemplate,
    );
  }
}
