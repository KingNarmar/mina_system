import 'package:mina_system/core/utils/company_date_time_formatter.dart';

String formatTransactionDate(
  DateTime dateTime, {
  String? timezone,
  String? dateFormat,
  bool includeTimezone = false,
}) {
  return CompanyDateTimeFormatter.formatDateTime(
    dateTime,
    timezone: timezone,
    dateFormat: dateFormat,
    includeTimezone: includeTimezone,
  );
}
