import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;

    final actions = [
      if (CompanyRolePermissions.canCreateTransactions(currentRole)) ...[
        _QuickActionItem(
          title: 'Issue Tool',
          subtitle: 'Create a new issue transaction',
          icon: AppIcons.arrowUpward,
          color: AppColors.accent,
          onTap: () => _openTransactionForm(context, TransactionType.issue),
        ),
        _QuickActionItem(
          title: 'Return Tool',
          subtitle: 'Receive a returned tool',
          icon: AppIcons.arrowDownward,
          color: AppColors.success,
          onTap: () =>
              _openTransactionForm(context, TransactionType.returnTool),
        ),
      ],
      if (CompanyRolePermissions.canCreateWorkers(currentRole))
        _QuickActionItem(
          title: 'Add Worker',
          subtitle: 'Register a new worker',
          icon: AppIcons.personAddAlt1Outlined,
          color: AppColors.warning,
          onTap: () => _openWorkerForm(context),
        ),
      if (CompanyRolePermissions.canCreateTools(currentRole))
        _QuickActionItem(
          title: 'Add Tool',
          subtitle: 'Register a new tool',
          icon: AppIcons.addBoxOutlined,
          color: AppColors.error,
          onTap: () => _openToolForm(context),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(14),
          if (actions.isEmpty)
            const _EmptyQuickActions()
          else
            Column(
              children: actions.map((action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _QuickActionRow(action: action),
                );
              }).toList(),
            ),
        ],
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
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    return shortestSide < AppBreakpoints.tablet;
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.action});

  final _QuickActionItem action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    action.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Icon(
              AppIcons.chevronRight,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQuickActions extends StatelessWidget {
  const _EmptyQuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'No quick actions available for your current role.',
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
