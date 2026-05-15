import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_settings_panel.dart';

import 'document_templates/document_template_card.dart';
import 'document_templates/empty_document_templates_view.dart';

class CompanyDocumentTemplatesForm extends StatelessWidget {
  const CompanyDocumentTemplatesForm({
    super.key,
    required this.documentTemplates,
    required this.isSaving,
    required this.companyTimezone,
    required this.dateFormat,
  });

  final List<CompanyDocumentTemplateModel> documentTemplates;
  final bool isSaving;
  final String companyTimezone;
  final String dateFormat;

  @override
  Widget build(BuildContext context) {
    final templateCountLabel = documentTemplates.length == 1
        ? '1 Template'
        : '${documentTemplates.length} Templates';

    return BlocListener<CompanySettingsCubit, CompanySettingsState>(
      listenWhen: (previous, current) {
        return previous is CompanySettingsLoaded &&
            previous.isUpdatingDocumentTemplate &&
            current is CompanySettingsLoaded &&
            !current.isUpdatingDocumentTemplate;
      },
      listener: (context, state) {
        final loadedState = state as CompanySettingsLoaded;

        if (loadedState.hasError) {
          AppMessage.showError(context, loadedState.errorMessage!);
          context.read<CompanySettingsCubit>().clearErrorMessage();
          return;
        }

        AppMessage.showSuccess(context, 'Document template updated.');
      },
      child: CompanySettingsPanel(
        title: 'Document Templates',
        description:
            'Manage document control headers, revision details, effective dates, approval titles, and signature labels used across generated company reports.',
        icon: Icons.article_outlined,
        badgeLabel: templateCountLabel,
        badgeIcon: Icons.library_books_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DocumentTemplatesOverview(documentTemplates: documentTemplates),
            const Gap(16),
            if (documentTemplates.isEmpty)
              const EmptyDocumentTemplatesView()
            else
              ...documentTemplates.map((template) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DocumentTemplateCard(
                    key: ValueKey(template.id),
                    documentTemplate: template,
                    isSaving: isSaving,
                    companyTimezone: companyTimezone,
                    dateFormat: dateFormat,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DocumentTemplatesOverview extends StatelessWidget {
  const _DocumentTemplatesOverview({required this.documentTemplates});

  final List<CompanyDocumentTemplateModel> documentTemplates;

  @override
  Widget build(BuildContext context) {
    final activeTemplates = documentTemplates.where((template) {
      return template.isActive;
    }).length;

    final inactiveTemplates = documentTemplates.length - activeTemplates;

    final metrics = [
      _DocumentTemplateMetricData(
        icon: Icons.description_outlined,
        label: 'Configured Templates',
        value: documentTemplates.length.toString(),
        description: 'Available document definitions',
      ),
      _DocumentTemplateMetricData(
        icon: Icons.verified_outlined,
        label: 'Active Templates',
        value: activeTemplates.toString(),
        description: 'Ready for document generation',
      ),
      _DocumentTemplateMetricData(
        icon: Icons.pause_circle_outline_rounded,
        label: 'Inactive Templates',
        value: inactiveTemplates.toString(),
        description: 'Disabled or draft templates',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        if (isWide) {
          return Row(
            children: metrics.map((metric) {
              final isLast = metric == metrics.last;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 12),
                  child: _DocumentTemplateMetricCard(metric: metric),
                ),
              );
            }).toList(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: metrics.map((metric) {
            final isLast = metric == metrics.last;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: _DocumentTemplateMetricCard(metric: metric),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DocumentTemplateMetricCard extends StatelessWidget {
  const _DocumentTemplateMetricCard({required this.metric});

  final _DocumentTemplateMetricData metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(metric.icon, color: AppColors.accent, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  metric.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  metric.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
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

class _DocumentTemplateMetricData {
  const _DocumentTemplateMetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String value;
  final String description;
}
