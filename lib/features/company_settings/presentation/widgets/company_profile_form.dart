import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/company_settings/presentation/functions/show_company_settings_audit_history.dart';
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
              const Text('Company Profile', style: AppTextStyles.title),
              const Gap(8),
              const Text(
                'These details will be used later in custody reports, signed PDF documents, and audit history display.',
                style: AppTextStyles.body,
              ),
              const Gap(20),
              CompanyDetailsFields(
                controllers: _controllers,
                selectedTimezone: _selectedTimezone,
                onTimezoneChanged: (timezone) {
                  setState(() {
                    _selectedTimezone = timezone;
                  });
                },
              ),
              const Gap(20),
              RecordAccountabilitySection(
                createdBy: widget.profile.createdByDisplayName,
                updatedBy: widget.profile.updatedByDisplayName,
                createdAt: widget.profile.createdAt,
                updatedAt: widget.profile.updatedAt,
                timezone: widget.profile.timezone,
              ),
              const Gap(12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    showCompanySettingsAuditHistory(
                      context,
                      entityType: 'company',
                      entityId: widget.profile.id,
                      title: 'Company Profile Audit History',
                      timezone: widget.profile.timezone,
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('View Audit History'),
                ),
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
