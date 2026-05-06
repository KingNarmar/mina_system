import 'package:flutter/material.dart';

class ReportSettingsFormHelpers {
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}

class ReportSettingsControllers {
  final TextEditingController timezoneController;
  final TextEditingController dateFormatController;
  final TextEditingController timeFormatController;
  final TextEditingController footerTextController;
  final TextEditingController custodyStatementController;
  final TextEditingController lossDamageStatementController;

  ReportSettingsControllers({
    required this.timezoneController,
    required this.dateFormatController,
    required this.timeFormatController,
    required this.footerTextController,
    required this.custodyStatementController,
    required this.lossDamageStatementController,
  });

  void dispose() {
    timezoneController.dispose();
    dateFormatController.dispose();
    timeFormatController.dispose();
    footerTextController.dispose();
    custodyStatementController.dispose();
    lossDamageStatementController.dispose();
  }
}
