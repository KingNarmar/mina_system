import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'worker': 'Ahmed Ali',
        'tool': 'Grinding Machine',
        'type': 'Issue',
        'date': 'Today',
      },
      {
        'worker': 'Mohamed Samir',
        'tool': 'Safety Helmet',
        'type': 'Return',
        'date': 'Today',
      },
      {
        'worker': 'Khaled Hassan',
        'tool': 'Drill Machine',
        'type': 'Issue',
        'date': 'Yesterday',
      },
      {
        'worker': 'Sayed Mahmoud',
        'tool': 'Welding Cable',
        'type': 'Return',
        'date': 'Yesterday',
      },
    ];

    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Transactions', style: AppTextStyles.title),
            const SizedBox(height: 16),
            ...transactions.map((transaction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: transaction['type'] == 'Issue'
                          ? AppColors.accent.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      child: Icon(
                        transaction['type'] == 'Issue'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 18,
                        color: transaction['type'] == 'Issue'
                            ? AppColors.accent
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['worker']!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${transaction['type']} • ${transaction['tool']}',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(transaction['date']!, style: AppTextStyles.caption),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
