import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/functions/show_company_settings_audit_history.dart';

import 'document_template_form_helpers.dart';
import 'document_template_general_fields.dart';
import 'document_template_signature_fields.dart';

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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DocumentTemplateSection(
                    icon: Icons.fact_check_outlined,
                    title: 'Document Control',
                    description:
                        'Define the official title, code, issue, revision, and effective date shown on generated documents.',
                    child: DocumentTemplateGeneralFields(
                      documentTitleController: _documentTitleController,
                      documentCodeController: _documentCodeController,
                      issueNoController: _issueNoController,
                      revisionNoController: _revisionNoController,
                      effectiveDateController: _effectiveDateController,
                      onEffectiveDateTap: _selectEffectiveDate,
                    ),
                  ),
                  const Gap(14),
                  _DocumentTemplateSection(
                    icon: Icons.approval_outlined,
                    title: 'Approval Titles',
                    description:
                        'Set the approval hierarchy labels printed in the document control area.',
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
                  const Gap(14),
                  _DocumentTemplateStatusCard(
                    isActive: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                    },
                  ),
                  const Gap(14),
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

    if (selectedDate == null || !mounted) {
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

class _DocumentTemplateHeader extends StatelessWidget {
  const _DocumentTemplateHeader({
    required this.title,
    required this.documentCode,
    required this.revisionNo,
    required this.isActive,
    required this.isSaving,
    required this.onSavePressed,
    required this.onAuditPressed,
  });

  final String title;
  final String documentCode;
  final String revisionNo;
  final bool isActive;
  final bool isSaving;
  final VoidCallback onSavePressed;
  final VoidCallback onAuditPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DocumentTemplateInfoChip(
                          icon: Icons.tag_outlined,
                          label: documentCode.trim().isEmpty
                              ? 'No Code'
                              : documentCode.trim(),
                        ),
                        _DocumentTemplateInfoChip(
                          icon: Icons.history_edu_outlined,
                          label: revisionNo.trim().isEmpty
                              ? 'No Revision'
                              : 'Rev. ${revisionNo.trim()}',
                        ),
                        _DocumentTemplateStatusChip(isActive: isActive),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = _DocumentTemplateHeaderActions(
            isSaving: isSaving,
            onSavePressed: onSavePressed,
            onAuditPressed: onAuditPressed,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleBlock,
                const Gap(14),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const Gap(14),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _DocumentTemplateHeaderActions extends StatelessWidget {
  const _DocumentTemplateHeaderActions({
    required this.isSaving,
    required this.onSavePressed,
    required this.onAuditPressed,
  });

  final bool isSaving;
  final VoidCallback onSavePressed;
  final VoidCallback onAuditPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          height: 36,
          child: TextButton.icon(
            onPressed: onAuditPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.history_rounded, size: 17),
            label: const Text('Audit History'),
          ),
        ),
        SizedBox(
          width: 116,
          height: 36,
          child: MainButton(
            text: 'Save',
            isLoading: isSaving,
            onPressed: onSavePressed,
          ),
        ),
      ],
    );
  }
}

class _DocumentTemplateInfoChip extends StatelessWidget {
  const _DocumentTemplateInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const Gap(5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTemplateStatusChip extends StatelessWidget {
  const _DocumentTemplateStatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final label = isActive ? 'Active' : 'Inactive';
    final icon = isActive
        ? Icons.check_circle_outline_rounded
        : Icons.pause_circle_outline_rounded;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accent.withValues(alpha: 0.08)
            : AppColors.border.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.20)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive ? AppColors.accent : AppColors.textSecondary,
          ),
          const Gap(5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTemplateSection extends StatelessWidget {
  const _DocumentTemplateSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(icon, color: AppColors.accent, size: 18),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          const Divider(height: 1, color: AppColors.border),
          const Gap(14),
          child,
        ],
      ),
    );
  }
}

class _DocumentTemplateStatusCard extends StatelessWidget {
  const _DocumentTemplateStatusCard({
    required this.isActive,
    required this.onChanged,
  });

  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onChanged(!isActive),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.08)
                      : AppColors.border.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.border,
                  ),
                ),
                child: Icon(
                  isActive
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                  color: isActive ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template Status',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      isActive
                          ? 'This template is active and ready to be used in generated documents.'
                          : 'This template is currently inactive and should not be used for new generated documents.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Switch(
                value: isActive,
                activeThumbColor: AppColors.accent,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
