import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';

import 'document_templates/document_template_card.dart';
import 'document_templates/empty_document_templates_view.dart';

class CompanyDocumentTemplatesForm extends StatelessWidget {
  const CompanyDocumentTemplatesForm({
    super.key,
    required this.documentTemplates,
    required this.isSaving,
  });

  final List<CompanyDocumentTemplateModel> documentTemplates;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Document Templates', style: AppTextStyles.title),
            const Gap(8),
            const Text(
              'Control document titles, codes, revision details, effective dates, and signature labels used later in PDF reports.',
              style: AppTextStyles.body,
            ),
            const Gap(20),
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
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
