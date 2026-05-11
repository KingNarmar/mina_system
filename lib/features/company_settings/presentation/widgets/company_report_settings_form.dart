import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';

import 'report_settings/report_settings_form_helpers.dart';
import 'report_settings/report_settings_format_fields.dart';
import 'report_settings/report_settings_statement_fields.dart';
import 'report_settings/report_settings_visibility_switches.dart';

class CompanyReportSettingsForm extends StatefulWidget {
  const CompanyReportSettingsForm({
    super.key,
    required this.reportSettings,
    required this.isSaving,
  });

  final CompanyReportSettingsModel reportSettings;
  final bool isSaving;

  @override
  State<CompanyReportSettingsForm> createState() =>
      _CompanyReportSettingsFormState();
}

class _CompanyReportSettingsFormState extends State<CompanyReportSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final ReportSettingsControllers _controllers;

  late bool _showCompanyLogo;
  late bool _showCompanyDetails;
  late bool _showDocumentControl;
  late bool _showGeneratedBy;

  @override
  void initState() {
    super.initState();

    _controllers = ReportSettingsControllers(
      timezoneController: TextEditingController(
        text: widget.reportSettings.defaultTimezone,
      ),
      dateFormatController: TextEditingController(
        text: widget.reportSettings.dateFormat,
      ),
      timeFormatController: TextEditingController(
        text: widget.reportSettings.timeFormat,
      ),
      footerTextController: TextEditingController(
        text: widget.reportSettings.reportFooterText ?? '',
      ),
      custodyStatementController: TextEditingController(
        text: widget.reportSettings.custodyResponsibilityStatement ?? '',
      ),
      lossDamageStatementController: TextEditingController(
        text: widget.reportSettings.lossDamageResponsibilityStatement ?? '',
      ),
    );

    _showCompanyLogo = widget.reportSettings.showCompanyLogo;
    _showCompanyDetails = widget.reportSettings.showCompanyDetails;
    _showDocumentControl = widget.reportSettings.showDocumentControl;
    _showGeneratedBy = widget.reportSettings.showGeneratedBy;
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanySettingsCubit, CompanySettingsState>(
      listenWhen: (previous, current) {
        return previous is CompanySettingsLoaded &&
            previous.isUpdatingReportSettings &&
            current is CompanySettingsLoaded &&
            !current.isUpdatingReportSettings;
      },
      listener: (context, state) {
        final loadedState = state as CompanySettingsLoaded;

        if (loadedState.hasError) {
          AppMessage.showError(context, loadedState.errorMessage!);
          context.read<CompanySettingsCubit>().clearErrorMessage();
          return;
        }

        AppMessage.showSuccess(context, 'Report settings updated.');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Report Settings', style: AppTextStyles.title),
              const Gap(8),
              const Text(
                'Control how company details, document control, and responsibility statements appear in reports and PDF documents.',
                style: AppTextStyles.body,
              ),
              const Gap(20),
              ReportSettingsFormatFields(
                timezoneController: _controllers.timezoneController,
                dateFormatController: _controllers.dateFormatController,
                timeFormatController: _controllers.timeFormatController,
              ),
              const Gap(16),
              ReportSettingsVisibilitySwitches(
                showCompanyLogo: _showCompanyLogo,
                showCompanyDetails: _showCompanyDetails,
                showDocumentControl: _showDocumentControl,
                showGeneratedBy: _showGeneratedBy,
                onShowCompanyLogoChanged: (value) {
                  setState(() => _showCompanyLogo = value);
                },
                onShowCompanyDetailsChanged: (value) {
                  setState(() => _showCompanyDetails = value);
                },
                onShowDocumentControlChanged: (value) {
                  setState(() => _showDocumentControl = value);
                },
                onShowGeneratedByChanged: (value) {
                  setState(() => _showGeneratedBy = value);
                },
              ),
              const Gap(16),
              ReportSettingsStatementFields(
                footerTextController: _controllers.footerTextController,
                custodyStatementController:
                    _controllers.custodyStatementController,
                lossDamageStatementController:
                    _controllers.lossDamageStatementController,
              ),
              const Gap(20),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 180,
                  child: MainButton(
                    text: 'Save',
                    isLoading: widget.isSaving,
                    onPressed: _onSavePressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedReportSettings = widget.reportSettings.copyWith(
      defaultTimezone: _controllers.timezoneController.text,
      dateFormat: _controllers.dateFormatController.text,
      timeFormat: _controllers.timeFormatController.text,
      showCompanyLogo: _showCompanyLogo,
      showCompanyDetails: _showCompanyDetails,
      showDocumentControl: _showDocumentControl,
      showGeneratedBy: _showGeneratedBy,
      reportFooterText: _controllers.footerTextController.text,
      custodyResponsibilityStatement:
          _controllers.custodyStatementController.text,
      lossDamageResponsibilityStatement:
          _controllers.lossDamageStatementController.text,
    );

    context.read<CompanySettingsCubit>().updateCompanyReportSettings(
      reportSettings: updatedReportSettings,
    );
  }
}
