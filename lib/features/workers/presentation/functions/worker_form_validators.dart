typedef HrCodeValidator = bool Function(String hrCode, {String? ignoredHrCode});

class WorkerFormValidators {
  static String? requiredWorkerTextValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  static String? requiredWorkerDropdownValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a value';
    }

    return null;
  }

  static String? hrCodeValidator(
    String? value, {
    required HrCodeValidator? isHrCodeAlreadyUsed,
    required String? initialHrCode,
  }) {
    final requiredError = requiredWorkerTextValidator(value);

    if (requiredError != null) {
      return requiredError;
    }

    final hrCode = value!.trim();

    final isDuplicated = isHrCodeAlreadyUsed?.call(
      hrCode,
      ignoredHrCode: initialHrCode,
    );

    if (isDuplicated == true) {
      return 'HR Code already exists';
    }

    return null;
  }
}
