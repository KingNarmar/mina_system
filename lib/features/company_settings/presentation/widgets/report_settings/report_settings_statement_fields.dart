import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'report_multiline_text_field.dart';

class ReportSettingsStatementFields extends StatelessWidget {
  const ReportSettingsStatementFields({
    super.key,
    required this.footerTextController,
    required this.custodyStatementController,
    required this.lossDamageStatementController,
  });

  final TextEditingController footerTextController;
  final TextEditingController custodyStatementController;
  final TextEditingController lossDamageStatementController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportMultilineTextField(
          label: 'Report Footer Text',
          controller: footerTextController,
        ),
        const Gap(12),
        ReportMultilineTextField(
          label: 'Custody Responsibility Statement',
          controller: custodyStatementController,
        ),
        const Gap(12),
        ReportMultilineTextField(
          label: 'Loss / Damage Responsibility Statement',
          controller: lossDamageStatementController,
        ),
      ],
    );
  }
}
