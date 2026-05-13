import 'package:mina_system/core/utils/app_timezones.dart';
import 'package:timezone/timezone.dart' as tz;

class CompanyDateTimeFormatter {
  const CompanyDateTimeFormatter._();

  static const String defaultDateFormat = 'dd/mm/yyyy';

  static tz.TZDateTime toCompanyTime(
    DateTime dateTime, {
    String? timezone,
  }) {
    final location = _resolveLocation(timezone);
    final utcDateTime = dateTime.isUtc ? dateTime : dateTime.toUtc();

    return tz.TZDateTime.from(utcDateTime, location);
  }

  static String formatDateTime(
    DateTime dateTime, {
    String? timezone,
    String? dateFormat,
    bool includeTimezone = false,
  }) {
    final companyTime = toCompanyTime(dateTime, timezone: timezone);
    final normalizedTimezone = AppTimezones.normalizeOrFallback(timezone);

    final formattedDate = formatCompanyDate(
      companyTime,
      dateFormat: dateFormat,
    );

    final formattedTime = formatCompanyTime(companyTime);

    final value = '$formattedDate - $formattedTime';

    if (!includeTimezone) {
      return value;
    }

    return '$value ($normalizedTimezone)';
  }

  static String formatNullableDateTime(
    DateTime? dateTime, {
    String? timezone,
    String? dateFormat,
    bool includeTimezone = false,
    String fallback = '-',
  }) {
    if (dateTime == null) {
      return fallback;
    }

    return formatDateTime(
      dateTime,
      timezone: timezone,
      dateFormat: dateFormat,
      includeTimezone: includeTimezone,
    );
  }

  static String formatDate(
    DateTime dateTime, {
    String? timezone,
    String? dateFormat,
  }) {
    final companyTime = toCompanyTime(dateTime, timezone: timezone);

    return formatCompanyDate(companyTime, dateFormat: dateFormat);
  }

  static String formatNullableDate(
    DateTime? dateTime, {
    String? timezone,
    String? dateFormat,
    String fallback = '-',
  }) {
    if (dateTime == null) {
      return fallback;
    }

    return formatDate(
      dateTime,
      timezone: timezone,
      dateFormat: dateFormat,
    );
  }

  static String formatTime(
    DateTime dateTime, {
    String? timezone,
  }) {
    final companyTime = toCompanyTime(dateTime, timezone: timezone);

    return formatCompanyTime(companyTime);
  }

  static String formatNullableTime(
    DateTime? dateTime, {
    String? timezone,
    String fallback = '-',
  }) {
    if (dateTime == null) {
      return fallback;
    }

    return formatTime(dateTime, timezone: timezone);
  }

  static String formatDateForFileName(
    DateTime dateTime, {
    String? timezone,
  }) {
    final companyTime = toCompanyTime(dateTime, timezone: timezone);

    return [
      companyTime.year.toString(),
      _twoDigits(companyTime.month),
      _twoDigits(companyTime.day),
    ].join('-');
  }

  static String formatCompanyDate(
    DateTime companyDateTime, {
    String? dateFormat,
  }) {
    final normalizedFormat = _normalizeDateFormat(dateFormat);

    switch (normalizedFormat) {
      case 'dd/mm/yyyy':
        return [
          _twoDigits(companyDateTime.day),
          _twoDigits(companyDateTime.month),
          companyDateTime.year.toString(),
        ].join('/');

      case 'mm/dd/yyyy':
        return [
          _twoDigits(companyDateTime.month),
          _twoDigits(companyDateTime.day),
          companyDateTime.year.toString(),
        ].join('/');

      case 'dd-mm-yyyy':
        return [
          _twoDigits(companyDateTime.day),
          _twoDigits(companyDateTime.month),
          companyDateTime.year.toString(),
        ].join('-');

      case 'yyyy/mm/dd':
        return [
          companyDateTime.year.toString(),
          _twoDigits(companyDateTime.month),
          _twoDigits(companyDateTime.day),
        ].join('/');

      case 'yyyy-mm-dd':
      default:
        return [
          companyDateTime.year.toString(),
          _twoDigits(companyDateTime.month),
          _twoDigits(companyDateTime.day),
        ].join('-');
    }
  }

  static String formatCompanyTime(DateTime companyDateTime) {
    return [
      _twoDigits(companyDateTime.hour),
      _twoDigits(companyDateTime.minute),
    ].join(':');
  }

  static tz.Location _resolveLocation(String? timezone) {
    final normalizedTimezone = AppTimezones.normalizeOrFallback(timezone);

    try {
      return tz.getLocation(normalizedTimezone);
    } catch (_) {
      return tz.getLocation(AppTimezones.fallbackTimezone);
    }
  }

  static String _normalizeDateFormat(String? dateFormat) {
    final cleanFormat = dateFormat
        ?.trim()
        .toLowerCase()
        .replaceAll('\\', '/')
        .replaceAll('.', '-')
        .replaceAll(' ', '');

    if (cleanFormat == null || cleanFormat.isEmpty) {
      return defaultDateFormat;
    }

    if (cleanFormat.contains('/')) {
      return _normalizeDateFormatBySeparator(cleanFormat, '/');
    }

    if (cleanFormat.contains('-')) {
      return _normalizeDateFormatBySeparator(cleanFormat, '-');
    }

    return defaultDateFormat;
  }

  static String _normalizeDateFormatBySeparator(
    String value,
    String separator,
  ) {
    final parts = value.split(separator);

    if (parts.length != 3) {
      return defaultDateFormat;
    }

    final normalizedParts = parts.map(_normalizeDateFormatPart).toList();

    if (normalizedParts.contains(null)) {
      return defaultDateFormat;
    }

    final normalizedFormat = normalizedParts.cast<String>().join(separator);

    switch (normalizedFormat) {
      case 'yyyy-mm-dd':
      case 'yyyy/mm/dd':
      case 'dd/mm/yyyy':
      case 'mm/dd/yyyy':
      case 'dd-mm-yyyy':
        return normalizedFormat;

      default:
        return defaultDateFormat;
    }
  }

  static String? _normalizeDateFormatPart(String value) {
    switch (value) {
      case 'yyyy':
      case 'yyy':
      case 'yy':
      case 'y':
        return 'yyyy';

      case 'mm':
      case 'm':
        return 'mm';

      case 'dd':
      case 'd':
        return 'dd';

      default:
        return null;
    }
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}