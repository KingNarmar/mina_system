import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class DateFilterTile extends StatelessWidget {
  const DateFilterTile({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onClear,
  });

  final String title;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selectedDateText = selectedDate == null
        ? 'Optional'
        : _formatDate(selectedDate!);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (pickedDate == null) {
          return;
        }

        onDateSelected(pickedDate);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.accent),
            const Gap(12),
            Expanded(child: Text(title, style: AppTextStyles.body)),
            const Gap(12),
            Text(
              selectedDateText,
              style: AppTextStyles.caption.copyWith(
                color: selectedDate == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selectedDate != null) ...[
              const Gap(8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
