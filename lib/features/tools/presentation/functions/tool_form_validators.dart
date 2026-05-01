import 'package:mina_system/features/tools/data/models/tool_model.dart';

typedef ToolCodeValidator =
    bool Function(String toolCode, {String? ignoredToolCode});

typedef ToolNameValidator =
    bool Function(String toolName, {String? ignoredToolCode});

String? validateRequiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }

  return null;
}

String? validateRequiredDropdown(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please select a value';
  }

  return null;
}

String? validateToolCode({
  required String? value,
  required ToolModel? initialTool,
  required ToolCodeValidator? isToolCodeAlreadyUsed,
}) {
  final requiredError = validateRequiredText(value);

  if (requiredError != null) {
    return requiredError;
  }

  final isDuplicated = isToolCodeAlreadyUsed?.call(
    value!.trim(),
    ignoredToolCode: initialTool?.toolCode,
  );

  if (isDuplicated == true) {
    return 'Tool Code already exists';
  }

  return null;
}

String? validateToolName({
  required String? value,
  required ToolModel? initialTool,
  required ToolNameValidator? isToolNameAlreadyUsed,
}) {
  final requiredError = validateRequiredText(value);

  if (requiredError != null) {
    return requiredError;
  }

  final isDuplicated = isToolNameAlreadyUsed?.call(
    value!.trim(),
    ignoredToolCode: initialTool?.toolCode,
  );

  if (isDuplicated == true) {
    return 'Tool Name already exists';
  }

  return null;
}
