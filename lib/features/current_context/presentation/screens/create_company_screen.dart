import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_timezones.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/searchable_timezone_form_field.dart';
import 'package:mina_system/features/current_context/data/models/create_company_request.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedTimezone = AppTimezones.fallbackTimezone;

  @override
  void dispose() {
    _companyNameController.dispose();
    _tradeNameController.dispose();
    _legalNameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    context.go(Routes.emailEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(AppIcons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: BlocConsumer<CurrentContextCubit, CurrentContextState>(
                listener: (context, state) {
                  if (state is CurrentContextFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CurrentContextLoading;

                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          AppIcons.businessOutlined,
                          size: 48,
                          color: AppColors.accent,
                        ),
                        const Gap(16),
                        const Text(
                          'Create Your Company',
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        const Text(
                          'Set up your company workspace with the key details needed for workers, tools, custody transactions, reports, and audit history.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(28),
                        const _SectionTitle(title: 'Basic Information'),
                        const Gap(12),
                        CustomTextFormField(
                          hint: 'Company Name *',
                          controller: _companyNameController,
                          keyboardType: TextInputType.name,
                          validator: _validateCompanyName,
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
                        const Gap(22),
                        const _SectionTitle(title: 'Location & Time'),
                        const Gap(12),
                        CustomTextFormField(
                          hint: 'Country *',
                          controller: _countryController,
                          keyboardType: TextInputType.text,
                          validator: _validateCountry,
                        ),
                        const Gap(12),
                        CustomTextFormField(
                          hint: 'City',
                          controller: _cityController,
                          keyboardType: TextInputType.text,
                        ),
                        const Gap(12),
                        SearchableTimezoneFormField(
                          value: _selectedTimezone,
                          helperText:
                              'Used to display audit logs, transactions, and reports in your company local time.',
                          validator: _validateTimezone,
                          onChanged: (timezone) {
                            setState(() {
                              _selectedTimezone = timezone;
                            });
                          },
                        ),
                        const Gap(22),
                        const _SectionTitle(title: 'Contact Details'),
                        const Gap(12),
                        CustomTextFormField(
                          hint: 'Company Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateOptionalEmail,
                        ),
                        const Gap(12),
                        CustomTextFormField(
                          hint: 'Company Phone',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const Gap(24),
                        MainButton(
                          text: 'Create Company',
                          isLoading: isLoading,
                          onPressed: _onCreateCompanyPressed,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateCompanyName(String? value) {
    final companyName = value?.trim() ?? '';

    if (companyName.isEmpty) {
      return 'Company name is required';
    }

    if (companyName.length < 2) {
      return 'Company name is too short';
    }

    return null;
  }

  String? _validateCountry(String? value) {
    final country = value?.trim() ?? '';

    if (country.isEmpty) {
      return 'Country is required';
    }

    if (country.length < 2) {
      return 'Country name is too short';
    }

    return null;
  }

  String? _validateTimezone(String? value) {
    final timezone = value?.trim() ?? '';

    if (timezone.isEmpty) {
      return 'Company timezone is required';
    }

    if (!AppTimezones.isValidTimezone(timezone)) {
      return 'Select a valid company timezone';
    }

    return null;
  }

  String? _validateOptionalEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  void _onCreateCompanyPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = CreateCompanyRequest(
      companyName: _companyNameController.text,
      tradeName: _tradeNameController.text,
      legalName: _legalNameController.text,
      country: _countryController.text,
      city: _cityController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      timezone: _selectedTimezone,
    );

    context.read<CurrentContextCubit>().createCompany(request: request);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.title.copyWith(fontSize: 16));
  }
}
