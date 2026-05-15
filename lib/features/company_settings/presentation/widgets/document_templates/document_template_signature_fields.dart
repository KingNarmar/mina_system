import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

import 'document_template_form_helpers.dart';

class DocumentTemplateSignatureFields extends StatelessWidget {
  const DocumentTemplateSignatureFields({
    super.key,
    required this.preparedByTitleController,
    required this.checkedByTitleController,
    required this.approvedByTitleController,
    required this.workerSignatureLabelController,
    required this.managerSignatureLabelController,
    required this.storekeeperSignatureLabelController,
  });

  final TextEditingController preparedByTitleController;
  final TextEditingController checkedByTitleController;
  final TextEditingController approvedByTitleController;
  final TextEditingController workerSignatureLabelController;
  final TextEditingController managerSignatureLabelController;
  final TextEditingController storekeeperSignatureLabelController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SignatureFieldsGroup(
          title: 'Approval Titles',
          description:
              'Titles shown in the document approval workflow section.',
          children: [
            _SignatureFieldData(
              label: 'Prepared By Title',
              helperText: 'Role responsible for preparing the document.',
              controller: preparedByTitleController,
              icon: Icons.edit_document,
            ),
            _SignatureFieldData(
              label: 'Checked By Title',
              helperText: 'Role responsible for reviewing the document.',
              controller: checkedByTitleController,
              icon: Icons.rule_folder_outlined,
            ),
            _SignatureFieldData(
              label: 'Approved By Title',
              helperText: 'Role responsible for final approval.',
              controller: approvedByTitleController,
              icon: Icons.verified_outlined,
            ),
          ],
        ),
        const Gap(14),
        _SignatureFieldsGroup(
          title: 'Signature Labels',
          description:
              'Labels printed beside signature areas in generated documents.',
          children: [
            _SignatureFieldData(
              label: 'Worker Signature Label',
              helperText: 'Signature label for the assigned worker.',
              controller: workerSignatureLabelController,
              icon: Icons.badge_outlined,
            ),
            _SignatureFieldData(
              label: 'Manager Signature Label',
              helperText: 'Signature label for the responsible manager.',
              controller: managerSignatureLabelController,
              icon: Icons.manage_accounts_outlined,
            ),
            _SignatureFieldData(
              label: 'Storekeeper Signature Label',
              helperText: 'Signature label for the storekeeper.',
              controller: storekeeperSignatureLabelController,
              icon: Icons.inventory_2_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _SignatureFieldsGroup extends StatelessWidget {
  const _SignatureFieldsGroup({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<_SignatureFieldData> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(4),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const Gap(12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideLayout = constraints.maxWidth >= 900;

              if (isWideLayout) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children.map((field) {
                    final isLast = field == children.last;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 12),
                        child: _SignatureTemplateField(data: field),
                      ),
                    );
                  }).toList(),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children.map((field) {
                  final isLast = field == children.last;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: _SignatureTemplateField(data: field),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SignatureTemplateField extends StatelessWidget {
  const _SignatureTemplateField({required this.data});

  final _SignatureFieldData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(6),
        CustomTextFormField(
          hint: data.label,
          controller: data.controller,
          icon: Icon(data.icon, size: 18, color: AppColors.textSecondary),
          validator: DocumentTemplateFormHelpers.validateOptionalLabel,
          fillColor: AppColors.background,
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
          data.helperText,
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

class _SignatureFieldData {
  const _SignatureFieldData({
    required this.label,
    required this.helperText,
    required this.controller,
    required this.icon,
  });

  final String label;
  final String helperText;
  final TextEditingController controller;
  final IconData icon;
}
