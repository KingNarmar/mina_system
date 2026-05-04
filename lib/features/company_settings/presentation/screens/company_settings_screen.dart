import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_profile_form.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = context.requireCurrentCompanyId();

    return BlocProvider(
      create: (_) =>
          CompanySettingsCubit()..loadCompanyProfile(companyId: companyId),
      child: const _CompanySettingsView(),
    );
  }
}

class _CompanySettingsView extends StatelessWidget {
  const _CompanySettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanySettingsCubit, CompanySettingsState>(
      builder: (context, state) {
        if (state is CompanySettingsLoading ||
            state is CompanySettingsInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CompanySettingsFailure) {
          return _CompanySettingsFailureView(message: state.message);
        }

        if (state is CompanySettingsLoaded) {
          final profile = state.profile;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Company Settings', style: AppTextStyles.heading),
                  const Gap(8),
                  Text(
                    'Manage company profile, report settings, logo, and document templates for ${profile.name}.',
                    style: AppTextStyles.body,
                  ),
                  const Gap(24),
                  CompanyProfileForm(
                    profile: profile,
                    isSaving: state.isSaving,
                  ),
                  const Gap(16),
                  _CompanySettingsPlaceholderCard(
                    title: 'Company Logo',
                    description: profile.logoPath == null
                        ? 'No logo uploaded yet. Logo upload will use Supabase Storage bucket: company-assets.'
                        : 'Logo path: ${profile.logoPath}',
                  ),
                  const Gap(16),
                  const _CompanySettingsPlaceholderCard(
                    title: 'Report Settings',
                    description:
                        'Report header, footer, and default report settings will be configured here.',
                  ),
                  const Gap(16),
                  const _CompanySettingsPlaceholderCard(
                    title: 'Document Templates',
                    description:
                        'Document code, issue number, revision number, and effective date will be managed here.',
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _CompanySettingsFailureView extends StatelessWidget {
  const _CompanySettingsFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final companyId = context.requireCurrentCompanyId();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const Gap(16),
                const Text(
                  'Unable to load company settings',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Text(
                  message,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                MainButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<CompanySettingsCubit>().loadCompanyProfile(
                      companyId: companyId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanySettingsPlaceholderCard extends StatelessWidget {
  const _CompanySettingsPlaceholderCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const Gap(8),
          Text(description, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
