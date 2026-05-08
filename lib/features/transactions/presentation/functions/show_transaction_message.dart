import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_message.dart';

void showTransactionMessage(
  BuildContext context,
  String message, {
  AppMessageType type = AppMessageType.info,
}) {
  switch (type) {
    case AppMessageType.success:
      AppMessage.showSuccess(context, message);
    case AppMessageType.error:
      AppMessage.showError(context, message);
    case AppMessageType.warning:
      AppMessage.showWarning(context, message);
    case AppMessageType.info:
      AppMessage.showInfo(context, message);
  }
}
