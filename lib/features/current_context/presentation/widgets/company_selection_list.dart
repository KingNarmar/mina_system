import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Companies', style: AppTextStyles.title),
        const Gap(12),
        if (companies.isEmpty)
          const Text('No active companies found.', style: AppTextStyles.body)
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
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onPressed});

  final CompanyModel company;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.business_outlined, color: AppColors.textSecondary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company.name, style: AppTextStyles.title),
                const Gap(4),
                Text(
                  CompanyRoles.label(company.role),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Gap(12),
          SizedBox(
            width: 150,
            child: MainButton(text: 'Open Workspace', onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}
