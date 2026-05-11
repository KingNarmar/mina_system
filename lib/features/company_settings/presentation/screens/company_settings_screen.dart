import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_document_templates_form.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_profile_form.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_report_settings_form.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/profile/company_logo_picker.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CompanySettingsView();
  }
}

class _CompanySettingsView extends StatelessWidget {
  const _CompanySettingsView();

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;

    final canManageCompanyProfile =
        CompanyRolePermissions.canManageCompanyProfile(currentRole);

    final canUploadCompanyLogo = CompanyRolePermissions.canUploadCompanyLogo(
      currentRole,
    );

    final canManageReportSettings =
        CompanyRolePermissions.canManageReportSettings(currentRole);

    final canManageDocumentTemplates =
        CompanyRolePermissions.canManageDocumentTemplates(currentRole);

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
                  if (canManageCompanyProfile) ...[
                    CompanyProfileForm(
                      profile: profile,
                      isSaving: state.isUpdatingProfile,
                    ),
                    const Gap(16),
                  ],
                  if (canUploadCompanyLogo) ...[
                    CompanyLogoPicker(
                      profile: profile,
                      isSaving: state.isUploadingLogo,
                    ),
                    const Gap(16),
                  ],
                  if (canManageReportSettings) ...[
                    CompanyReportSettingsForm(
                      reportSettings: state.reportSettings,
                      isSaving: state.isUpdatingReportSettings,
                    ),
                    const Gap(16),
                  ],
                  if (canManageDocumentTemplates)
                    CompanyDocumentTemplatesForm(
                      documentTemplates: state.documentTemplates,
                      isSaving: state.isUpdatingDocumentTemplate,
                    ),
                  if (!canManageCompanyProfile &&
                      !canUploadCompanyLogo &&
                      !canManageReportSettings &&
                      !canManageDocumentTemplates)
                    const _NoCompanySettingsPermissionView(),
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

class _NoCompanySettingsPermissionView extends StatelessWidget {
  const _NoCompanySettingsPermissionView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No settings available', style: AppTextStyles.title),
          Gap(8),
          Text(
            'Your current role does not have permission to manage company settings.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
