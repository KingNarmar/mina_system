class DocumentTemplateFormHelpers {
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

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
