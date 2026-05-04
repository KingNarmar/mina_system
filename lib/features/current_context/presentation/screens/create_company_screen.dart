import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    context.go(Routes.login);
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
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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
                          Icons.business_outlined,
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
                          'Set up your company workspace to start managing workers, tools, custody transactions, and reports.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        CustomTextFormField(
                          hint: 'Company Name',
                          controller: _companyNameController,
                          keyboardType: TextInputType.name,
                          validator: _validateCompanyName,
                        ),
                        const Gap(20),
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

  void _onCreateCompanyPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<CurrentContextCubit>().createCompany(
      companyName: _companyNameController.text,
    );
  }
}
