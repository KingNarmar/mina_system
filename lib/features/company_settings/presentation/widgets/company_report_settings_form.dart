import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/company_settings/presentation/functions/show_company_settings_audit_history.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_settings_panel.dart';

import 'report_settings/report_settings_form_helpers.dart';
import 'report_settings/report_settings_format_fields.dart';
import 'report_settings/report_settings_statement_fields.dart';
import 'report_settings/report_settings_visibility_switches.dart';

class CompanyReportSettingsForm extends StatefulWidget {
  const CompanyReportSettingsForm({
    super.key,
    required this.reportSettings,
    required this.isSaving,
    required this.companyTimezone,
  });

  final CompanyReportSettingsModel reportSettings;
  final bool isSaving;
  final String companyTimezone;

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
      child: CompanySettingsPanel(
        title: 'Report Configuration',
        description:
            'Control report formatting, visibility, footer text, and responsibility statements used across generated company documents.',
        icon: Icons.description_outlined,
        badgeLabel: 'PDF Defaults',
        badgeIcon: Icons.picture_as_pdf_outlined,
        headerActions: _ReportSettingsHeaderActions(
          isSaving: widget.isSaving,
          onSavePressed: _onSavePressed,
          onAuditPressed: () {
            showCompanySettingsAuditHistory(
              context,
              entityType: 'company_report_settings',
              entityId: widget.reportSettings.id,
              title: 'Report Settings Audit History',
              timezone: widget.companyTimezone,
              dateFormat: widget.reportSettings.dateFormat,
            );
          },
        ),
        accountability: RecordAccountabilitySection(
          createdBy: widget.reportSettings.createdByDisplayName,
          updatedBy: widget.reportSettings.updatedByDisplayName,
          createdAt: widget.reportSettings.createdAt,
          updatedAt: widget.reportSettings.updatedAt,
          timezone: widget.companyTimezone,
          dateFormat: widget.reportSettings.dateFormat,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportSettingsGroup(
                icon: Icons.tune_rounded,
                title: 'Format & Timezone',
                description:
                    'Set the default timezone, date format, and time format used when generating reports.',
                child: ReportSettingsFormatFields(
                  timezoneController: _controllers.timezoneController,
                  dateFormatController: _controllers.dateFormatController,
                  timeFormatController: _controllers.timeFormatController,
                ),
              ),
              const Gap(14),
              _ReportSettingsGroup(
                icon: Icons.visibility_outlined,
                title: 'Report Visibility',
                description:
                    'Choose which company and document control details should appear in generated reports.',
                child: ReportSettingsVisibilitySwitches(
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
              ),
              const Gap(14),
              _ReportSettingsGroup(
                icon: Icons.fact_check_outlined,
                title: 'Footer & Responsibility Statements',
                description:
                    'Customize the footer and accountability statements printed on custody and company documents.',
                child: ReportSettingsStatementFields(
                  footerTextController: _controllers.footerTextController,
                  custodyStatementController:
                      _controllers.custodyStatementController,
                  lossDamageStatementController:
                      _controllers.lossDamageStatementController,
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

class _ReportSettingsHeaderActions extends StatelessWidget {
  const _ReportSettingsHeaderActions({
    required this.isSaving,
    required this.onSavePressed,
    required this.onAuditPressed,
  });

  final bool isSaving;
  final VoidCallback onSavePressed;
  final VoidCallback onAuditPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          height: 36,
          child: TextButton.icon(
            onPressed: onAuditPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.history_rounded, size: 17),
            label: const Text('Audit History'),
          ),
        ),
        SizedBox(
          width: 120,
          height: 36,
          child: MainButton(
            text: 'Save',
            isLoading: isSaving,
            onPressed: onSavePressed,
          ),
        ),
      ],
    );
  }
}

class _ReportSettingsGroup extends StatelessWidget {
  const _ReportSettingsGroup({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(icon, color: AppColors.accent, size: 18),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          const Divider(height: 1, color: AppColors.border),
          const Gap(14),
          child,
        ],
      ),
    );
  }
}
