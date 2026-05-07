class TransactionHelperService {
  static bool isSameTransactionCode(String? firstValue, String secondValue) {
    if (firstValue == null) {
      return false;
    }

    return normalizeTransactionCode(firstValue) ==
        normalizeTransactionCode(secondValue);
  }

  static String normalizeTransactionCode(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static int extractEndingNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }

    final match = RegExp(r'(\d+)$').firstMatch(value.trim());

    if (match == null) {
      return 0;
    }

    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  static String? emptyToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }
}
