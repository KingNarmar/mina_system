import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/company_settings/presentation/functions/show_company_settings_audit_history.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_settings_panel.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';

import 'profile/company_details_fields.dart';
import 'profile/company_profile_form_helpers.dart';

class CompanyProfileForm extends StatefulWidget {
  const CompanyProfileForm({
    super.key,
    required this.profile,
    required this.isSaving,
  });

  final CompanyProfileModel profile;
  final bool isSaving;

  @override
  State<CompanyProfileForm> createState() => _CompanyProfileFormState();
}

class _CompanyProfileFormState extends State<CompanyProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final CompanyProfileControllers _controllers;
  late String _selectedTimezone;

  @override
  void initState() {
    super.initState();
    _selectedTimezone = widget.profile.timezone;
    _controllers = CompanyProfileControllers(
      nameController: TextEditingController(text: widget.profile.name),
      tradeNameController: TextEditingController(
        text: widget.profile.tradeName ?? '',
      ),
      legalNameController: TextEditingController(
        text: widget.profile.legalName ?? '',
      ),
      tradeLicenseNoController: TextEditingController(
        text: widget.profile.tradeLicenseNo ?? '',
      ),
      taxRegistrationNoController: TextEditingController(
        text: widget.profile.taxRegistrationNo ?? '',
      ),
      addressLine1Controller: TextEditingController(
        text: widget.profile.addressLine1 ?? '',
      ),
      addressLine2Controller: TextEditingController(
        text: widget.profile.addressLine2 ?? '',
      ),
      cityController: TextEditingController(text: widget.profile.city ?? ''),
      countryController: TextEditingController(
        text: widget.profile.country ?? '',
      ),
      phoneController: TextEditingController(text: widget.profile.phone ?? ''),
      emailController: TextEditingController(text: widget.profile.email ?? ''),
      websiteController: TextEditingController(
        text: widget.profile.website ?? '',
      ),
    );
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
            previous.isUpdatingProfile &&
            current is CompanySettingsLoaded &&
            !current.isUpdatingProfile;
      },
      listener: (context, state) {
        final loadedState = state as CompanySettingsLoaded;

        if (loadedState.hasError) {
          AppMessage.showError(context, loadedState.errorMessage!);
          context.read<CompanySettingsCubit>().clearErrorMessage();
          return;
        }

        context.read<CurrentContextCubit>().updateCurrentCompanyProfile(
          companyName: loadedState.profile.name,
          timezone: loadedState.profile.timezone,
        );

        AppMessage.showSuccess(context, 'Company profile updated.');
      },
      child: CompanySettingsPanel(
        title: 'Company Profile',
        description:
            'Manage the official company identity, legal information, contact details, and timezone used across reports and audit history.',
        icon: AppIcons.company,
        badgeLabel: 'Core Identity',
        badgeIcon: AppIcons.verifiedUser,
        headerActions: _CompanyProfileHeaderActions(
          isSaving: widget.isSaving,
          onSavePressed: _onSavePressed,
          onAuditPressed: () {
            showCompanySettingsAuditHistory(
              context,
              entityType: 'company',
              entityId: widget.profile.id,
              title: 'Company Profile Audit History',
              timezone: widget.profile.timezone,
            );
          },
        ),
        accountability: RecordAccountabilitySection(
          createdBy: widget.profile.createdByDisplayName,
          updatedBy: widget.profile.updatedByDisplayName,
          createdAt: widget.profile.createdAt,
          updatedAt: widget.profile.updatedAt,
          timezone: widget.profile.timezone,
        ),
        child: Form(
          key: _formKey,
          child: CompanyDetailsFields(
            controllers: _controllers,
            selectedTimezone: _selectedTimezone,
            onTimezoneChanged: (timezone) {
              setState(() {
                _selectedTimezone = timezone;
              });
            },
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      name: _controllers.nameController.text,
      tradeName: _controllers.tradeNameController.text,
      legalName: _controllers.legalNameController.text,
      tradeLicenseNo: _controllers.tradeLicenseNoController.text,
      taxRegistrationNo: _controllers.taxRegistrationNoController.text,
      addressLine1: _controllers.addressLine1Controller.text,
      addressLine2: _controllers.addressLine2Controller.text,
      city: _controllers.cityController.text,
      country: _controllers.countryController.text,
      phone: _controllers.phoneController.text,
      email: _controllers.emailController.text,
      website: _controllers.websiteController.text,
      timezone: _selectedTimezone,
    );

    context.read<CompanySettingsCubit>().updateCompanyProfile(
      profile: updatedProfile,
    );
  }
}

class _CompanyProfileHeaderActions extends StatelessWidget {
  const _CompanyProfileHeaderActions({
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
            icon: const Icon(AppIcons.auditHistory, size: 17),
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
