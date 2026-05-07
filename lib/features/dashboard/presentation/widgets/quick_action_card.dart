import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionItem(
        title: 'Issue Tool',
        icon: Icons.arrow_upward,
        color: AppColors.accent,
        onTap: () {
          _openTransactionForm(context, TransactionType.issue);
        },
      ),
      _QuickActionItem(
        title: 'Return Tool',
        icon: Icons.arrow_downward,
        color: AppColors.accent,
        onTap: () {
          _openTransactionForm(context, TransactionType.returnTool);
        },
      ),
      _QuickActionItem(
        title: 'Add Worker',
        icon: Icons.person_add_alt_1_outlined,
        color: AppColors.error,
        onTap: () {
          _openWorkerForm(context);
        },
      ),
      _QuickActionItem(
        title: 'Add Tool',
        icon: Icons.add_box_outlined,
        color: AppColors.error,
        onTap: () {
          _openToolForm(context);
        },
      ),
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
            const Text('Quick Actions', style: AppTextStyles.title),
            const Gap(16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 420;
                final buttonWidth = isMobile
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: actions.map((action) {
                    return SizedBox(
                      width: buttonWidth,
                      child: _QuickActionButton(action: action),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openTransactionForm(BuildContext context, TransactionType type) {
    if (_shouldUseBottomSheet(context)) {
      showTransactionBottomSheet(context, initialType: type);
      return;
    }

    showTransactionDialog(context, initialType: type);
  }

  void _openWorkerForm(BuildContext context) {
    if (_shouldUseBottomSheet(context)) {
      showWorkerBottomSheet(context);
      return;
    }

    showWorkerDialog(context);
  }

  void _openToolForm(BuildContext context) {
    if (_shouldUseBottomSheet(context)) {
      showToolBottomSheet(context);
      return;
    }

    showToolDialog(context);
  }

  bool _shouldUseBottomSheet(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final _QuickActionItem action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(action.icon, color: action.color, size: 22),
            const Gap(12),
            Text(
              action.title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
