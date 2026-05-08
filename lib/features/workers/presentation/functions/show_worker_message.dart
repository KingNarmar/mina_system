import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_message.dart';

void showWorkerSuccessMessage(BuildContext context, String message) {
  AppMessage.showSuccess(context, message);
}

void showWorkerErrorMessage(BuildContext context, String message) {
  AppMessage.showError(context, message);
}

void showWorkerInfoMessage(BuildContext context, String message) {
  AppMessage.showInfo(context, message);
}

void showWorkerWarningMessage(BuildContext context, String message) {
  AppMessage.showWarning(context, message);
}
