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
import 'package:mina_system/features/company_settings/presentation/widgets/company_identity_section.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_report_settings_form.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/loading/company_settings_loading_view.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CompanySettingsView();
  }
}

class _CompanySettingsView extends StatefulWidget {
  const _CompanySettingsView();

  @override
  State<_CompanySettingsView> createState() => _CompanySettingsViewState();
}

class _CompanySettingsViewState extends State<_CompanySettingsView> {
  _CompanySettingsSectionType? _selectedSection;

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
          return const CompanySettingsLoadingView();
        }

        if (state is CompanySettingsFailure) {
          return _CompanySettingsFailureView(message: state.message);
        }

        if (state is CompanySettingsLoaded) {
          final profile = state.profile;

          final sections = _buildAvailableSections(
            canManageCompanyProfile: canManageCompanyProfile,
            canUploadCompanyLogo: canUploadCompanyLogo,
            canManageReportSettings: canManageReportSettings,
            canManageDocumentTemplates: canManageDocumentTemplates,
            documentTemplateCount: state.documentTemplates.length,
          );

          if (sections.isEmpty) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: _NoCompanySettingsPermissionView(),
              ),
            );
          }

          final selectedSection = _resolveSelectedSection(sections);

          return Scaffold(
            backgroundColor: AppColors.background,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWideLayout = constraints.maxWidth >= 980;

                return SingleChildScrollView(
                  key: const PageStorageKey<String>(
                    'company_settings_scroll_key',
                  ),
                  padding: EdgeInsets.all(isWideLayout ? 28 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CompanySettingsHeader(
                        companyName: profile.name,
                        timezone: profile.timezone,
                        visibleSectionCount: sections.length,
                      ),
                      Gap(isWideLayout ? 20 : 14),
                      _CompanySettingsSectionSelector(
                        sections: sections,
                        selectedSection: selectedSection,
                        onSectionSelected: _onSectionSelected,
                      ),
                      Gap(isWideLayout ? 20 : 14),
                      _CompanySettingsSectionContent(
                        selectedSection: selectedSection,
                        state: state,
                        canManageCompanyProfile: canManageCompanyProfile,
                        canUploadCompanyLogo: canUploadCompanyLogo,
                        canManageReportSettings: canManageReportSettings,
                        canManageDocumentTemplates: canManageDocumentTemplates,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const CompanySettingsLoadingView();
      },
    );
  }

  List<_CompanySettingsSection> _buildAvailableSections({
    required bool canManageCompanyProfile,
    required bool canUploadCompanyLogo,
    required bool canManageReportSettings,
    required bool canManageDocumentTemplates,
    required int documentTemplateCount,
  }) {
    final sections = <_CompanySettingsSection>[];

    if (canManageCompanyProfile || canUploadCompanyLogo) {
      sections.add(
        const _CompanySettingsSection(
          type: _CompanySettingsSectionType.identity,
          title: 'Company Identity',
          description: 'Profile, legal details, logo, and timezone.',
          icon: Icons.business_rounded,
        ),
      );
    }

    if (canManageReportSettings) {
      sections.add(
        const _CompanySettingsSection(
          type: _CompanySettingsSectionType.reports,
          title: 'Report Configuration',
          description: 'PDF settings, visibility, and statements.',
          icon: Icons.description_outlined,
        ),
      );
    }

    if (canManageDocumentTemplates) {
      sections.add(
        _CompanySettingsSection(
          type: _CompanySettingsSectionType.documents,
          title: 'Document Templates',
          description: '$documentTemplateCount configured templates.',
          icon: Icons.article_outlined,
        ),
      );
    }

    return sections;
  }

  _CompanySettingsSection _resolveSelectedSection(
    List<_CompanySettingsSection> sections,
  ) {
    final currentSelectedSection = _selectedSection;

    if (currentSelectedSection != null) {
      for (final section in sections) {
        if (section.type == currentSelectedSection) {
          return section;
        }
      }
    }

    final firstSection = sections.first;

    if (_selectedSection != firstSection.type) {
      _selectedSection = firstSection.type;
    }

    return firstSection;
  }

  void _onSectionSelected(_CompanySettingsSection section) {
    if (_selectedSection == section.type) {
      return;
    }

    setState(() {
      _selectedSection = section.type;
    });
  }
}

class _CompanySettingsHeader extends StatelessWidget {
  const _CompanySettingsHeader({
    required this.companyName,
    required this.timezone,
    required this.visibleSectionCount,
  });

  final String companyName;
  final String timezone;
  final int visibleSectionCount;

  @override
  Widget build(BuildContext context) {
    final cleanCompanyName = companyName.trim().isEmpty
        ? 'Current Company'
        : companyName.trim();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Settings',
                      style: AppTextStyles.heading,
                    ),
                    const Gap(6),
                    Text(
                      'Manage profile, branding, report configuration, document templates, and accountability for $cleanCompanyName.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final infoChips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CompanySettingsInfoChip(
                icon: Icons.schedule_rounded,
                label: timezone,
              ),
              _CompanySettingsInfoChip(
                icon: Icons.dashboard_customize_outlined,
                label: '$visibleSectionCount sections',
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const Gap(16), infoChips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const Gap(18),
              Padding(padding: const EdgeInsets.only(top: 8), child: infoChips),
            ],
          );
        },
      ),
    );
  }
}

class _CompanySettingsInfoChip extends StatelessWidget {
  const _CompanySettingsInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.trim().isEmpty ? '-' : label.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const Gap(7),
          Text(
            cleanLabel,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanySettingsSectionSelector extends StatelessWidget {
  const _CompanySettingsSectionSelector({
    required this.sections,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  final List<_CompanySettingsSection> sections;
  final _CompanySettingsSection selectedSection;
  final ValueChanged<_CompanySettingsSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sections.map((section) {
            final isSelected = section.type == selectedSection.type;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _CompanySettingsSectionChip(
                section: section,
                isSelected: isSelected,
                onTap: () => onSectionSelected(section),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CompanySettingsSectionChip extends StatelessWidget {
  const _CompanySettingsSectionChip({
    required this.section,
    required this.isSelected,
    required this.onTap,
  });

  final _CompanySettingsSection section;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primary
        : AppColors.background;

    final foregroundColor = isSelected
        ? AppColors.onPrimary
        : AppColors.textPrimary;

    final iconColor = isSelected
        ? AppColors.onPrimary
        : AppColors.textSecondary;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(section.icon, size: 16, color: iconColor),
              const Gap(8),
              Text(
                section.title,
                style: AppTextStyles.caption.copyWith(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanySettingsSectionContent extends StatelessWidget {
  const _CompanySettingsSectionContent({
    required this.selectedSection,
    required this.state,
    required this.canManageCompanyProfile,
    required this.canUploadCompanyLogo,
    required this.canManageReportSettings,
    required this.canManageDocumentTemplates,
  });

  final _CompanySettingsSection selectedSection;
  final CompanySettingsLoaded state;
  final bool canManageCompanyProfile;
  final bool canUploadCompanyLogo;
  final bool canManageReportSettings;
  final bool canManageDocumentTemplates;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;

    switch (selectedSection.type) {
      case _CompanySettingsSectionType.identity:
        return CompanyIdentitySection(
          profile: profile,
          isUpdatingProfile: state.isUpdatingProfile,
          isUploadingLogo: state.isUploadingLogo,
          canManageCompanyProfile: canManageCompanyProfile,
          canUploadCompanyLogo: canUploadCompanyLogo,
        );

      case _CompanySettingsSectionType.reports:
        if (!canManageReportSettings) {
          return const _NoCompanySettingsPermissionView();
        }

        return CompanyReportSettingsForm(
          reportSettings: state.reportSettings,
          isSaving: state.isUpdatingReportSettings,
          companyTimezone: profile.timezone,
        );

      case _CompanySettingsSectionType.documents:
        if (!canManageDocumentTemplates) {
          return const _NoCompanySettingsPermissionView();
        }

        return CompanyDocumentTemplatesForm(
          documentTemplates: state.documentTemplates,
          isSaving: state.isUpdatingDocumentTemplate,
          companyTimezone: profile.timezone,
          dateFormat: state.reportSettings.dateFormat,
        );
    }
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

enum _CompanySettingsSectionType { identity, reports, documents }

class _CompanySettingsSection {
  const _CompanySettingsSection({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  final _CompanySettingsSectionType type;
  final String title;
  final String description;
  final IconData icon;
}
