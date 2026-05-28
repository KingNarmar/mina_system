import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/current_context/data/models/company_model.dart';

class CompanySelectionList extends StatelessWidget {
  const CompanySelectionList({
    super.key,
    required this.companies,
    required this.onCompanySelected,
  });

  final List<CompanyModel> companies;
  final ValueChanged<String> onCompanySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(count: companies.length),
          const Gap(16),
          if (companies.isEmpty)
            const _EmptyCompaniesView()
          else
            Column(
              children: companies.map((company) {
                return _CompanyCard(
                  company: company,
                  onPressed: () => onCompanySelected(company.id),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Your Companies', style: AppTextStyles.title),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count active',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onPressed});

  final CompanyModel company;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile =
            MediaQuery.sizeOf(context).shortestSide < AppBreakpoints.tablet;

        if (isMobile || constraints.maxWidth < 560) {
          return _MobileCompanyCard(company: company, onPressed: onPressed);
        }

        return _DesktopCompanyCard(company: company, onPressed: onPressed);
      },
    );
  }
}

class _MobileCompanyCard extends StatelessWidget {
  const _MobileCompanyCard({required this.company, required this.onPressed});

  final CompanyModel company;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final roleLabel = CompanyRoles.label(company.role);
    final roleColor = _roleColor(company.role);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: roleColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompanyIcon(color: roleColor),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.name,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(8),
                            _RoleBadge(label: roleLabel, color: roleColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: roleColor,
                          size: 18,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'You will enter this workspace as $roleLabel.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(14),
                  MainButton(text: 'Open Workspace', onPressed: onPressed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopCompanyCard extends StatelessWidget {
  const _DesktopCompanyCard({required this.company, required this.onPressed});

  final CompanyModel company;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final roleLabel = CompanyRoles.label(company.role);
    final roleColor = _roleColor(company.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(width: 6, height: 112, color: roleColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    _CompanyIcon(color: roleColor),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: AppTextStyles.title.copyWith(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(8),
                          _RoleBadge(label: roleLabel, color: roleColor),
                          const Gap(8),
                          Text(
                            'Open this company workspace and continue with your assigned permissions.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Gap(14),
                    SizedBox(
                      width: 170,
                      child: MainButton(
                        text: 'Open Workspace',
                        onPressed: onPressed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyIcon extends StatelessWidget {
  const _CompanyIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.business_rounded, color: color, size: 24),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyCompaniesView extends StatelessWidget {
  const _EmptyCompaniesView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'No active companies found.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

Color _roleColor(String? role) {
  switch (CompanyRoles.normalize(role)) {
    case CompanyRoles.owner:
      return AppColors.primary;
    case CompanyRoles.admin:
      return AppColors.accent;
    case CompanyRoles.warehouseManager:
      return AppColors.success;
    case CompanyRoles.warehouseUser:
      return AppColors.warning;
    case CompanyRoles.viewer:
      return AppColors.textSecondary;
    default:
      return AppColors.textSecondary;
  }
}
