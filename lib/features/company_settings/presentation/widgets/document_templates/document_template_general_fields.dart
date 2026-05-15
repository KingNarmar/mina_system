import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

import 'document_template_form_helpers.dart';

class DocumentTemplateGeneralFields extends StatelessWidget {
  const DocumentTemplateGeneralFields({
    super.key,
    required this.documentTitleController,
    required this.documentCodeController,
    required this.issueNoController,
    required this.revisionNoController,
    required this.effectiveDateController,
    required this.onEffectiveDateTap,
  });

  final TextEditingController documentTitleController;
  final TextEditingController documentCodeController;
  final TextEditingController issueNoController;
  final TextEditingController revisionNoController;
  final TextEditingController effectiveDateController;
  final VoidCallback onEffectiveDateTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 840;

        if (isWideLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DocumentTemplateField(
                label: 'Document Title',
                helperText: 'Main title printed on the generated document.',
                controller: documentTitleController,
                icon: Icons.title_rounded,
                validator: DocumentTemplateFormHelpers.validateDocumentTitle,
              ),
              const Gap(12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DocumentTemplateField(
                      label: 'Document Code',
                      helperText: 'Official internal document reference code.',
                      controller: documentCodeController,
                      icon: Icons.qr_code_2_rounded,
                      validator:
                          DocumentTemplateFormHelpers.validateDocumentCode,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _DocumentTemplateField(
                      label: 'Issue No.',
                      helperText: 'Current document issue number.',
                      controller: issueNoController,
                      icon: Icons.confirmation_number_outlined,
                      validator:
                          DocumentTemplateFormHelpers.validateIssueOrRevisionNo,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DocumentTemplateField(
                      label: 'Revision No.',
                      helperText: 'Latest approved revision number.',
                      controller: revisionNoController,
                      icon: Icons.history_edu_outlined,
                      validator:
                          DocumentTemplateFormHelpers.validateIssueOrRevisionNo,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _DocumentTemplateField(
                      label: 'Effective Date',
                      helperText: 'Date from which this template is valid.',
                      controller: effectiveDateController,
                      icon: Icons.calendar_month_outlined,
                      readOnly: true,
                      onTap: onEffectiveDateTap,
                      validator:
                          DocumentTemplateFormHelpers.validateRequiredDate,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DocumentTemplateField(
              label: 'Document Title',
              helperText: 'Main title printed on the generated document.',
              controller: documentTitleController,
              icon: Icons.title_rounded,
              validator: DocumentTemplateFormHelpers.validateDocumentTitle,
            ),
            const Gap(12),
            _DocumentTemplateField(
              label: 'Document Code',
              helperText: 'Official internal document reference code.',
              controller: documentCodeController,
              icon: Icons.qr_code_2_rounded,
              validator: DocumentTemplateFormHelpers.validateDocumentCode,
            ),
            const Gap(12),
            _DocumentTemplateField(
              label: 'Issue No.',
              helperText: 'Current document issue number.',
              controller: issueNoController,
              icon: Icons.confirmation_number_outlined,
              validator: DocumentTemplateFormHelpers.validateIssueOrRevisionNo,
            ),
            const Gap(12),
            _DocumentTemplateField(
              label: 'Revision No.',
              helperText: 'Latest approved revision number.',
              controller: revisionNoController,
              icon: Icons.history_edu_outlined,
              validator: DocumentTemplateFormHelpers.validateIssueOrRevisionNo,
            ),
            const Gap(12),
            _DocumentTemplateField(
              label: 'Effective Date',
              helperText: 'Date from which this template is valid.',
              controller: effectiveDateController,
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              onTap: onEffectiveDateTap,
              validator: DocumentTemplateFormHelpers.validateRequiredDate,
            ),
          ],
        );
      },
    );
  }
}

class _DocumentTemplateField extends StatelessWidget {
  const _DocumentTemplateField({
    required this.label,
    required this.helperText,
    required this.controller,
    required this.icon,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final String helperText;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(6),
        CustomTextFormField(
          hint: label,
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          icon: Icon(icon, size: 18, color: AppColors.textSecondary),
          validator: validator,
          fillColor: AppColors.card,
          borderColor: AppColors.border,
          focusedBorderColor: AppColors.accent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textStyle: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Text(
          helperText,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
