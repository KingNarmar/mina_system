import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          hint: 'Prepared By Title',
          controller: preparedByTitleController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Checked By Title',
          controller: checkedByTitleController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Approved By Title',
          controller: approvedByTitleController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Worker Signature Label',
          controller: workerSignatureLabelController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Manager Signature Label',
          controller: managerSignatureLabelController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Storekeeper Signature Label',
          controller: storekeeperSignatureLabelController,
        ),
      ],
    );
  }
}
