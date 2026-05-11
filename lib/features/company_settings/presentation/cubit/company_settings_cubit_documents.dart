part of 'company_settings_cubit.dart';

extension CompanySettingsCubitDocuments on CompanySettingsCubit {
  Future<void> updateCompanyDocumentTemplate({
    required CompanyDocumentTemplateModel documentTemplate,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    final actionState = currentState.copyWith(
      action: CompanySettingsAction.updatingDocumentTemplate,
      clearErrorMessage: true,
    );

    emitState(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedDocumentTemplate = await _repo.updateCompanyDocumentTemplate(
        documentTemplate: documentTemplate,
      );

      final updatedDocumentTemplates = actionState.documentTemplates.map((
        item,
      ) {
        if (item.id == updatedDocumentTemplate.id) {
          return updatedDocumentTemplate;
        }

        return item;
      }).toList();

      emitState(
        actionState.copyWith(
          documentTemplates: updatedDocumentTemplates,
          action: CompanySettingsAction.none,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UpdateCompanyDocumentTemplate error: $error');
        debugPrint('UpdateCompanyDocumentTemplate stackTrace: $stackTrace');
      }

      emitState(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to update document template.',
          ),
        ),
      );
    }
  }
}
