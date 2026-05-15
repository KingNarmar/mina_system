class DocumentTemplateFormHelpers {
  static const int documentTitleMaxLength = 80;
  static const int documentCodeMaxLength = 40;
  static const int issueRevisionMaxLength = 12;
  static const int optionalLabelMaxLength = 60;

  static String? emptyToNull(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  static String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String formatReportType(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
          final lowerWord = word.toLowerCase();
          return '${lowerWord[0].toUpperCase()}${lowerWord.substring(1)}';
        })
        .join(' ');
  }

  static String? validateDocumentTitle(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Document title is required';
    }

    if (trimmedValue.length > documentTitleMaxLength) {
      return 'Document title must be $documentTitleMaxLength characters or less';
    }

    return null;
  }

  static String? validateDocumentCode(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Document code is required';
    }

    if (trimmedValue.length > documentCodeMaxLength) {
      return 'Document code must be $documentCodeMaxLength characters or less';
    }

    final documentCodePattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]*$');

    if (!documentCodePattern.hasMatch(trimmedValue)) {
      return 'Use letters, numbers, dot, slash, underscore, or hyphen only';
    }

    return null;
  }

  static String? validateIssueOrRevisionNo(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'This field is required';
    }

    if (trimmedValue.length > issueRevisionMaxLength) {
      return 'Must be $issueRevisionMaxLength characters or less';
    }

    final issueRevisionPattern = RegExp(r'^[A-Za-z0-9._/-]+$');

    if (!issueRevisionPattern.hasMatch(trimmedValue)) {
      return 'Use letters, numbers, dot, slash, underscore, or hyphen only';
    }

    return null;
  }

  static String? validateRequiredDate(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Effective date is required';
    }

    return null;
  }

  static String? validateOptionalLabel(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return null;
    }

    if (trimmedValue.length > optionalLabelMaxLength) {
      return 'Must be $optionalLabelMaxLength characters or less';
    }

    return null;
  }
}
