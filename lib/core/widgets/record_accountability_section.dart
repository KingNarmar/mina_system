import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/company_date_time_formatter.dart';

class RecordAccountabilitySection extends StatelessWidget {
  const RecordAccountabilitySection({
    super.key,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.timezone,
    this.dateFormat,
  });

  final String createdBy;
  final String updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? timezone;
  final String? dateFormat;

  @override
  Widget build(BuildContext context) {
    final createdAtText = CompanyDateTimeFormatter.formatNullableDateTime(
      createdAt,
      timezone: timezone,
      dateFormat: dateFormat,
    );

    final updatedAtText = CompanyDateTimeFormatter.formatNullableDateTime(
      updatedAt,
      timezone: timezone,
      dateFormat: dateFormat,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColors.accent.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'Accountability',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AccountabilityInfoRow(
            label: 'Created by',
            value: _safeText(createdBy),
          ),
          const SizedBox(height: 6),
          _AccountabilityInfoRow(label: 'Created at', value: createdAtText),
          const SizedBox(height: 6),
          _AccountabilityInfoRow(
            label: 'Last updated by',
            value: _safeText(updatedBy),
          ),
          const SizedBox(height: 6),
          _AccountabilityInfoRow(
            label: 'Last updated at',
            value: updatedAtText,
          ),
        ],
      ),
    );
  }

  String _safeText(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return 'Unknown User';
    }

    return cleanValue;
  }
}

class _AccountabilityInfoRow extends StatelessWidget {
  const _AccountabilityInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
