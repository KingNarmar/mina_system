import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/company_date_time_formatter.dart';
import 'package:mina_system/features/company_users/data/models/company_member_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';

class CompanyUserStatusBadge extends StatelessWidget {
  const CompanyUserStatusBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: AppTextStyles.caption),
    );
  }
}

String companyMemberDisplayName(CompanyMemberModel member) {
  return member.fullName?.trim().isNotEmpty == true
      ? member.fullName!
      : member.email ?? 'Unknown user';
}

String companyUserActorDisplayName({
  required String? fullName,
  required String? email,
  String fallback = 'Recorded user',
}) {
  final cleanName = fullName?.trim();
  final cleanEmail = email?.trim();

  final hasName = cleanName != null && cleanName.isNotEmpty;
  final hasEmail = cleanEmail != null && cleanEmail.isNotEmpty;

  if (hasName && hasEmail) {
    return '$cleanName ($cleanEmail)';
  }

  if (hasName) {
    return cleanName;
  }

  if (hasEmail) {
    return cleanEmail;
  }

  return fallback;
}

String successMessageForActionKey(String? actionKey) {
  if (actionKey == CompanyUsersSubmissionKey.invite) {
    return 'Invitation sent successfully.';
  }

  if (actionKey?.startsWith('change-role:') == true) {
    return 'Member role updated successfully.';
  }

  if (actionKey?.startsWith('deactivate-member:') == true) {
    return 'Member deactivated successfully.';
  }

  if (actionKey?.startsWith('reactivate-member:') == true) {
    return 'Member reactivated successfully.';
  }

  if (actionKey?.startsWith('cancel-invitation:') == true) {
    return 'Invitation cancelled successfully.';
  }

  return 'Company users updated.';
}

String formatInvitationDate(
  DateTime value, {
  String? timezone,
  bool includeTimezone = true,
}) {
  return CompanyDateTimeFormatter.formatDateTime(
    value,
    timezone: timezone,
    includeTimezone: includeTimezone,
  );
}

String formatOptionalInvitationDate(
  DateTime? value, {
  String? timezone,
  bool includeTimezone = true,
  String fallback = 'Not recorded',
}) {
  return CompanyDateTimeFormatter.formatNullableDateTime(
    value,
    timezone: timezone,
    includeTimezone: includeTimezone,
    fallback: fallback,
  );
}

String formatCompanyUserDate(
  DateTime value, {
  String? timezone,
  bool includeTimezone = true,
}) {
  return CompanyDateTimeFormatter.formatDateTime(
    value,
    timezone: timezone,
    includeTimezone: includeTimezone,
  );
}

String formatOptionalCompanyUserDate(
  DateTime? value, {
  String? timezone,
  bool includeTimezone = true,
  String fallback = 'Not recorded',
}) {
  return CompanyDateTimeFormatter.formatNullableDateTime(
    value,
    timezone: timezone,
    includeTimezone: includeTimezone,
    fallback: fallback,
  );
}
