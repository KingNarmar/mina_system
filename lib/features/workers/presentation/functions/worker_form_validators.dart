typedef HrCodeValidator = bool Function(String hrCode, {String? ignoredHrCode});
typedef WorkerNameValidator =
    bool Function(String name, {String? ignoredWorkerId});

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

  static String? workerNameValidator(
    String? value, {
    required WorkerNameValidator? isWorkerNameAlreadyUsed,
    required String? initialWorkerId,
  }) {
    final requiredError = requiredWorkerTextValidator(value);

    if (requiredError != null) {
      return requiredError;
    }

    final name = value!.trim();

    final isDuplicated = isWorkerNameAlreadyUsed?.call(
      name,
      ignoredWorkerId: initialWorkerId,
    );

    if (isDuplicated == true) {
      return 'Worker name already exists';
    }

    return null;
  }
}
