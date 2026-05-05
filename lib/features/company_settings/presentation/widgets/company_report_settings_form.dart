import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';

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

class _CompanyReportSettingsFormState
    extends State<CompanyReportSettingsForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _timezoneController;
  late final TextEditingController _dateFormatController;
  late final TextEditingController _timeFormatController;
  late final TextEditingController _footerTextController;
  late final TextEditingController _custodyStatementController;
  late final TextEditingController _lossDamageStatementController;

  late bool _showCompanyLogo;
  late bool _showCompanyDetails;
  late bool _showDocumentControl;
  late bool _showGeneratedBy;

  @override
  void initState() {
    super.initState();

    _timezoneController = TextEditingController(
      text: widget.reportSettings.defaultTimezone,
    );
    _dateFormatController = TextEditingController(
      text: widget.reportSettings.dateFormat,
    );
    _timeFormatController = TextEditingController(
      text: widget.reportSettings.timeFormat,
    );
    _footerTextController = TextEditingController(
      text: widget.reportSettings.reportFooterText ?? '',
    );
    _custodyStatementController = TextEditingController(
      text: widget.reportSettings.custodyResponsibilityStatement ?? '',
    );
    _lossDamageStatementController = TextEditingController(
      text: widget.reportSettings.lossDamageResponsibilityStatement ?? '',
    );

    _showCompanyLogo = widget.reportSettings.showCompanyLogo;
    _showCompanyDetails = widget.reportSettings.showCompanyDetails;
    _showDocumentControl = widget.reportSettings.showDocumentControl;
    _showGeneratedBy = widget.reportSettings.showGeneratedBy;
  }

  @override
  void dispose() {
    _timezoneController.dispose();
    _dateFormatController.dispose();
    _timeFormatController.dispose();
    _footerTextController.dispose();
    _custodyStatementController.dispose();
    _lossDamageStatementController.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report settings updated.')),
        );
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
              CustomTextFormField(
                hint: 'Default Timezone',
                controller: _timezoneController,
                validator: _validateRequired,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Date Format',
                controller: _dateFormatController,
                validator: _validateRequired,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Time Format',
                controller: _timeFormatController,
                validator: _validateRequired,
              ),
              const Gap(16),
              _ReportSettingSwitch(
                title: 'Show Company Logo',
                value: _showCompanyLogo,
                onChanged: (value) {
                  setState(() => _showCompanyLogo = value);
                },
              ),
              _ReportSettingSwitch(
                title: 'Show Company Details',
                value: _showCompanyDetails,
                onChanged: (value) {
                  setState(() => _showCompanyDetails = value);
                },
              ),
              _ReportSettingSwitch(
                title: 'Show Document Control',
                value: _showDocumentControl,
                onChanged: (value) {
                  setState(() => _showDocumentControl = value);
                },
              ),
              _ReportSettingSwitch(
                title: 'Show Generated By',
                value: _showGeneratedBy,
                onChanged: (value) {
                  setState(() => _showGeneratedBy = value);
                },
              ),
              const Gap(16),
              _MultilineTextField(
                label: 'Report Footer Text',
                controller: _footerTextController,
              ),
              const Gap(12),
              _MultilineTextField(
                label: 'Custody Responsibility Statement',
                controller: _custodyStatementController,
              ),
              const Gap(12),
              _MultilineTextField(
                label: 'Loss / Damage Responsibility Statement',
                controller: _lossDamageStatementController,
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

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedReportSettings = widget.reportSettings.copyWith(
      defaultTimezone: _timezoneController.text,
      dateFormat: _dateFormatController.text,
      timeFormat: _timeFormatController.text,
      showCompanyLogo: _showCompanyLogo,
      showCompanyDetails: _showCompanyDetails,
      showDocumentControl: _showDocumentControl,
      showGeneratedBy: _showGeneratedBy,
      reportFooterText: _footerTextController.text,
      custodyResponsibilityStatement: _custodyStatementController.text,
      lossDamageResponsibilityStatement: _lossDamageStatementController.text,
    );

    context.read<CompanySettingsCubit>().updateCompanyReportSettings(
      reportSettings: updatedReportSettings,
    );
  }
}

class _ReportSettingSwitch extends StatelessWidget {
  const _ReportSettingSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTextStyles.body),
      value: value,
      activeThumbColor: AppColors.accent,
      onChanged: onChanged,
    );
  }
}

class _MultilineTextField extends StatelessWidget {
  const _MultilineTextField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: AppColors.border,
        hintText: label,
        hintStyle: AppTextStyles.caption,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}