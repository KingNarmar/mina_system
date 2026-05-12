import 'package:timezone/timezone.dart' as tz;

class AppTimezoneOption {
  const AppTimezoneOption({
    required this.value,
    required this.label,
    required this.searchText,
  });

  final String value;
  final String label;
  final String searchText;
}

class AppTimezones {
  const AppTimezones._();

  static const String fallbackTimezone = 'Asia/Dubai';

  static List<AppTimezoneOption> get all {
    final locations = tz.timeZoneDatabase.locations.keys.toList()..sort();

    return locations.map(_toOption).toList();
  }

  static AppTimezoneOption? findByValue(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    for (final option in all) {
      if (option.value == normalizedValue) {
        return option;
      }
    }

    return null;
  }

  static AppTimezoneOption fallbackOption() {
    return findByValue(fallbackTimezone) ??
        const AppTimezoneOption(
          value: fallbackTimezone,
          label: 'Dubai — Asia/Dubai',
          searchText: 'dubai asia dubai united arab emirates uae',
        );
  }

  static List<AppTimezoneOption> search(String query) {
    final normalizedQuery = _normalizeSearchText(query);

    if (normalizedQuery.isEmpty) {
      return all;
    }

    return all.where((option) {
      return option.searchText.contains(normalizedQuery);
    }).toList();
  }

  static bool isValidTimezone(String value) {
    return findByValue(value) != null;
  }

  static String normalizeOrFallback(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return fallbackTimezone;
    }

    if (!isValidTimezone(normalizedValue)) {
      return fallbackTimezone;
    }

    return normalizedValue;
  }

  static AppTimezoneOption _toOption(String timezone) {
    final parts = timezone.split('/');
    final area = parts.isNotEmpty ? parts.first : timezone;
    final location = parts.length > 1 ? parts.sublist(1).join(' / ') : timezone;

    final readableLocation = _humanize(location);
    final readableArea = _humanize(area);

    final label = '$readableLocation — $timezone';

    final searchText = _normalizeSearchText(
      [
        timezone,
        readableLocation,
        readableArea,
        _commonSearchAliases(timezone),
      ].join(' '),
    );

    return AppTimezoneOption(
      value: timezone,
      label: label,
      searchText: searchText,
    );
  }

  static String _humanize(String value) {
    return value.replaceAll('_', ' ').trim();
  }

  static String _normalizeSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('/', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _commonSearchAliases(String timezone) {
    switch (timezone) {
      case 'Asia/Dubai':
        return 'uae united arab emirates emirates abu dhabi dubai';
      case 'Africa/Cairo':
        return 'egypt cairo';
      case 'Asia/Riyadh':
        return 'saudi arabia ksa riyadh';
      case 'Asia/Kolkata':
        return 'india kolkata calcutta';
      case 'Europe/London':
        return 'united kingdom uk england london';
      case 'Europe/Istanbul':
        return 'turkey turkiye istanbul';
      default:
        return '';
    }
  }
}
