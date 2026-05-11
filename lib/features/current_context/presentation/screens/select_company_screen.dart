import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/current_context/data/models/company_model.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/company_selection_list.dart';
import '../widgets/pending_company_invitations_section.dart';

class SelectCompanyScreen extends StatelessWidget {
  const SelectCompanyScreen({
    super.key,
    required this.companies,
    required this.onCompanySelected,
  });

  final List<CompanyModel> companies;
  final ValueChanged<String> onCompanySelected;

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) {
      return;
    }

    context.go(Routes.emailEntry);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyUsersCubit, CompanyUsersState>(
      listenWhen: (previous, current) {
        return previous.isSubmitting && !current.isSubmitting;
      },
      listener: (context, state) {
        if (state.hasError) {
          AppMessage.showError(context, state.errorMessage!);
          context.read<CompanyUsersCubit>().clearErrorMessage();
          return;
        }

        context.read<CurrentContextCubit>().loadCurrentContext(
          restoreLastSelectedCompany: false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
                  builder: (context, state) {
                    final pendingInvitations =
                        state.pendingCurrentUserInvitations;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.apartment_outlined,
                          size: 48,
                          color: AppColors.accent,
                        ),
                        const Gap(16),
                        const Text(
                          'Choose Workspace',
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        const Text(
                          'Open one of your active companies or review any pending invitations.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        CompanySelectionList(
                          companies: companies,
                          onCompanySelected: onCompanySelected,
                        ),
                        if (pendingInvitations.isNotEmpty) ...[
                          const Gap(28),
                          PendingCompanyInvitationsSection(
                            invitations: pendingInvitations,
                            isSubmitting: state.isSubmitting,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
