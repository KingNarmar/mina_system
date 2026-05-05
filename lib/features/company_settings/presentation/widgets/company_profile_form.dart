import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';

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

  late final TextEditingController _nameController;
  late final TextEditingController _tradeNameController;
  late final TextEditingController _legalNameController;
  late final TextEditingController _tradeLicenseNoController;
  late final TextEditingController _taxRegistrationNoController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name);
    _tradeNameController = TextEditingController(
      text: widget.profile.tradeName ?? '',
    );
    _legalNameController = TextEditingController(
      text: widget.profile.legalName ?? '',
    );
    _tradeLicenseNoController = TextEditingController(
      text: widget.profile.tradeLicenseNo ?? '',
    );
    _taxRegistrationNoController = TextEditingController(
      text: widget.profile.taxRegistrationNo ?? '',
    );
    _addressLine1Controller = TextEditingController(
      text: widget.profile.addressLine1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: widget.profile.addressLine2 ?? '',
    );
    _cityController = TextEditingController(text: widget.profile.city ?? '');
    _countryController = TextEditingController(
      text: widget.profile.country ?? '',
    );
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _websiteController = TextEditingController(
      text: widget.profile.website ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tradeNameController.dispose();
    _legalNameController.dispose();
    _tradeLicenseNoController.dispose();
    _taxRegistrationNoController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
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

        context.read<CurrentContextCubit>().updateCurrentCompanyName(
          loadedState.profile.name,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company profile updated.')),
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
              const Text('Company Profile', style: AppTextStyles.title),
              const Gap(8),
              const Text(
                'These details will be used later in custody reports and signed PDF documents.',
                style: AppTextStyles.body,
              ),
              const Gap(20),
              CustomTextFormField(
                hint: 'Company Name',
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: _validateRequired,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Trade Name',
                controller: _tradeNameController,
                keyboardType: TextInputType.name,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Legal Name',
                controller: _legalNameController,
                keyboardType: TextInputType.name,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Trade License No.',
                controller: _tradeLicenseNoController,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Tax Registration No.',
                controller: _taxRegistrationNoController,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Address Line 1',
                controller: _addressLine1Controller,
                keyboardType: TextInputType.streetAddress,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Address Line 2',
                controller: _addressLine2Controller,
                keyboardType: TextInputType.streetAddress,
              ),
              const Gap(12),
              CustomTextFormField(hint: 'City', controller: _cityController),
              const Gap(12),
              CustomTextFormField(
                hint: 'Country',
                controller: _countryController,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Website',
                controller: _websiteController,
                keyboardType: TextInputType.url,
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
      return 'Company name is required';
    }

    return null;
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text,
      tradeName: _tradeNameController.text,
      legalName: _legalNameController.text,
      tradeLicenseNo: _tradeLicenseNoController.text,
      taxRegistrationNo: _taxRegistrationNoController.text,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text,
      city: _cityController.text,
      country: _countryController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      website: _websiteController.text,
    );

    context.read<CompanySettingsCubit>().updateCompanyProfile(
      profile: updatedProfile,
    );
  }
}
