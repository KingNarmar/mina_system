import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/loading/audit_history_loading_view.dart';
import 'package:mina_system/features/audit_logs/presentation/cubit/audit_logs_cubit.dart';
import 'package:mina_system/features/audit_logs/presentation/cubit/audit_logs_state.dart';
import 'package:mina_system/features/audit_logs/presentation/widgets/audit_log_tile.dart';

Future<void> showAuditHistoryBottomSheet({
  required BuildContext context,
  required String companyId,
  required String entityType,
  required String entityId,
  String? title,
  String? timezone,
  String? dateFormat,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) {
      return BlocProvider(
        create: (_) => AuditLogsCubit()
          ..loadAuditLogsByEntity(
            companyId: companyId,
            entityType: entityType,
            entityId: entityId,
          ),
        child: AuditHistoryBottomSheet(
          title: title,
          timezone: timezone,
          dateFormat: dateFormat,
        ),
      );
    },
  );
}

class AuditHistoryBottomSheet extends StatelessWidget {
  const AuditHistoryBottomSheet({
    super.key,
    this.title,
    this.timezone,
    this.dateFormat,
  });

  final String? title;
  final String? timezone;
  final String? dateFormat;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Audit History',
                      style: AppTextStyles.title.copyWith(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      AppIcons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AuditLogsCubit, AuditLogsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const _AuditHistoryLoadingView();
                  }

                  if (state.errorMessage != null) {
                    return _AuditHistoryErrorView(
                      message: state.errorMessage!,
                      onRetry: () => _retryLoad(context, state),
                    );
                  }

                  if (!state.hasLogs) {
                    return const _AuditHistoryEmptyView();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: state.auditLogs.length,
                    itemBuilder: (context, index) {
                      return AuditLogTile(
                        auditLog: state.auditLogs[index],
                        lookupResolver: state.lookupResolver,
                        timezone: timezone,
                        dateFormat: dateFormat,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retryLoad(BuildContext context, AuditLogsState state) {
    final companyId = state.companyId;
    final entityType = state.entityType;
    final entityId = state.entityId;

    if (companyId == null || entityType == null || entityId == null) {
      return;
    }

    context.read<AuditLogsCubit>().loadAuditLogsByEntity(
      companyId: companyId,
      entityType: entityType,
      entityId: entityId,
    );
  }
}

class _AuditHistoryLoadingView extends StatelessWidget {
  const _AuditHistoryLoadingView();

  @override
  Widget build(BuildContext context) {
    return const AuditHistoryLoadingView();
  }
}

class _AuditHistoryEmptyView extends StatelessWidget {
  const _AuditHistoryEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No audit history found for this record yet.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _AuditHistoryErrorView extends StatelessWidget {
  const _AuditHistoryErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.error, color: AppColors.error, size: 32),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(AppIcons.retry),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
