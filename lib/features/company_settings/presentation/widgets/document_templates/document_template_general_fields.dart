import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          hint: 'Document Title',
          controller: documentTitleController,
          validator: DocumentTemplateFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Document Code',
          controller: documentCodeController,
          validator: DocumentTemplateFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Issue No.',
          controller: issueNoController,
          validator: DocumentTemplateFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Revision No.',
          controller: revisionNoController,
          validator: DocumentTemplateFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Effective Date',
          controller: effectiveDateController,
          readOnly: true,
          onTap: onEffectiveDateTap,
          validator: DocumentTemplateFormHelpers.validateRequired,
        ),
      ],
    );
  }
}
