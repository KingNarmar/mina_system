import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.title});

  final String title;

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.title),
          const Spacer(),
          BlocBuilder<CurrentContextCubit, CurrentContextState>(
            builder: (context, state) {
              if (state is CurrentContextLoading) {
                return const Text(
                  'Loading company...',
                  style: AppTextStyles.body,
                );
              }

              if (state is CurrentContextLoaded) {
                if (state.currentCompany != null) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.currentCompany!.name,
                        style: AppTextStyles.body,
                      ),
                      if (state.hasMultipleCompanies) ...[
                        const Gap(8),
                        TextButton.icon(
                          onPressed: () {
                            context
                                .read<CurrentContextCubit>()
                                .openCompanySelection();
                          },
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: const Text('Switch Company'),
                        ),
                      ],
                    ],
                  );
                }

                if (state.hasMultipleCompanies) {
                  return const Text(
                    'Select Company',
                    style: AppTextStyles.body,
                  );
                }

                return const Text('No Company', style: AppTextStyles.body);
              }

              if (state is CurrentContextFailure) {
                return const Text(
                  'Company unavailable',
                  style: AppTextStyles.body,
                );
              }

              return const Text('M.I.N.A System', style: AppTextStyles.body);
            },
          ),
          const Gap(16),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.border,
            foregroundColor: AppColors.textPrimary,
            child: Icon(Icons.person_outline, size: 20),
          ),
          const Gap(12),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
