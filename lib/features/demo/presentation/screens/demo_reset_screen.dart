import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/demo/data/repo/demo_signed_reports_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

class DemoResetScreen extends StatefulWidget {
  const DemoResetScreen({super.key});

  @override
  State<DemoResetScreen> createState() => _DemoResetScreenState();
}

class _DemoResetScreenState extends State<DemoResetScreen> {
  bool _isResetting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DemoResetHeader(),
                const Gap(20),
                const _DemoResetSummaryCard(),
                const Gap(20),
                _DemoResetActionCard(
                  isResetting: _isResetting,
                  onResetPressed: _confirmAndResetDemoData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndResetDemoData() async {
    if (_isResetting) {
      return;
    }

    final shouldReset = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(AppIcons.restore, color: AppColors.warning),
              SizedBox(width: 10),
              Expanded(child: Text('Reset Demo Data?')),
            ],
          ),
          content: const Text(
            'This will remove all demo changes on this device and restore the original sample workspace.\n\n'
            'It will delete locally saved demo signed reports, added workers, tools, transactions, approvals, invitations, and team changes.\n\n'
            'Live company data will not be affected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(AppIcons.restore),
              label: const Text('Reset Demo'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !mounted) {
      return;
    }

    await _resetDemoData();
  }

  Future<void> _resetDemoData() async {
    setState(() => _isResetting = true);

    try {
      const companyId = DemoSeedService.demoCompanyId;

      await DemoSignedReportsRepo().clearSignedReportFiles(
        companyId: companyId,
      );

      await const DemoSeedService().resetAndSeed();

      if (!mounted) {
        return;
      }

      await Future.wait([
        context.read<LookupsCubit>().loadLookups(
          companyId: companyId,
          showLoader: false,
        ),
        context.read<WorkersCubit>().loadWorkers(
          companyId: companyId,
          showLoader: false,
        ),
        context.read<ToolsCubit>().loadTools(
          companyId: companyId,
          showLoader: false,
        ),
        context.read<TransactionsCubit>().loadTransactions(
          companyId: companyId,
          showLoader: false,
        ),
        context.read<DashboardCubit>().loadDashboardSummary(
          companyId: companyId,
          showLoader: false,
        ),
        context.read<CompanySettingsCubit>().loadCompanyProfile(
          companyId: companyId,
          showLoader: false,
        ),
        context.read<CompanyUsersCubit>().loadCompanyUsers(
          companyId: companyId,
          showLoader: false,
        ),
      ]);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Demo data has been reset successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Unable to reset demo data: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }
}

class _DemoResetHeader extends StatelessWidget {
  const _DemoResetHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              AppIcons.restore,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reset Demo Data', style: AppTextStyles.heading),
                const Gap(8),
                Text(
                  'Restore the local demo workspace to its original sample state.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoResetSummaryCard extends StatelessWidget {
  const _DemoResetSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What will be reset?', style: AppTextStyles.title),
          Gap(12),
          _DemoResetBullet(text: 'Workers, tools, transactions, and lookups.'),
          _DemoResetBullet(text: 'Lost/damaged approval workflow changes.'),
          _DemoResetBullet(
            text: 'Team invitations, role changes, and activity.',
          ),
          _DemoResetBullet(text: 'Signed reports saved locally in demo mode.'),
          _DemoResetBullet(
            text: 'Company/report settings stored for the demo.',
          ),
        ],
      ),
    );
  }
}

class _DemoResetBullet extends StatelessWidget {
  const _DemoResetBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.checkRounded, size: 18, color: AppColors.success),
          const Gap(8),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _DemoResetActionCard extends StatelessWidget {
  const _DemoResetActionCard({
    required this.isResetting,
    required this.onResetPressed,
  });

  final bool isResetting;
  final VoidCallback onResetPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Safe for live data', style: AppTextStyles.title),
          const Gap(8),
          Text(
            'This action affects demo local storage only. It does not write to Supabase and does not affect any live company workspace.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const Gap(18),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isResetting ? null : onResetPressed,
              icon: isResetting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(AppIcons.restore),
              label: Text(isResetting ? 'Resetting...' : 'Reset Demo Data'),
            ),
          ),
        ],
      ),
    );
  }
}
