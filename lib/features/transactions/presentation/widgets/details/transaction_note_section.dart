import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_proof_image_preview.dart';

class TransactionNoteSection extends StatelessWidget {
  const TransactionNoteSection({super.key, required this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null && note!.trim().isNotEmpty;

    if (!hasNote) {
      return const EmptyDetailsBox(text: 'No note added');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        note!,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
