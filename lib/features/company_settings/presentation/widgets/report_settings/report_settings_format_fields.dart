import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

import 'report_settings_form_helpers.dart';

class ReportSettingsFormatFields extends StatelessWidget {
  const ReportSettingsFormatFields({
    super.key,
    required this.timezoneController,
    required this.dateFormatController,
    required this.timeFormatController,
  });

  final TextEditingController timezoneController;
  final TextEditingController dateFormatController;
  final TextEditingController timeFormatController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          hint: 'Default Timezone',
          controller: timezoneController,
          validator: ReportSettingsFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Date Format',
          controller: dateFormatController,
          validator: ReportSettingsFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Time Format',
          controller: timeFormatController,
          validator: ReportSettingsFormHelpers.validateRequired,
        ),
      ],
    );
  }
}
