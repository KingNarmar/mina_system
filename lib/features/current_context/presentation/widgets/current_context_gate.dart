import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_cubit.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_state.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/screens/pending_company_invitations_screen.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:mina_system/features/current_context/presentation/screens/create_company_screen.dart';

class CurrentContextGate extends StatelessWidget {
  const CurrentContextGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentContextCubit, CurrentContextState>(
      builder: (context, state) {
        if (state is CurrentContextInitial || state is CurrentContextLoading) {
          return const _CurrentContextLoadingView();
        }

        if (state is CurrentContextFailure) {
          return BlocBuilder<NetworkStatusCubit, NetworkStatusState>(
            builder: (context, networkState) {
              final isOffline = networkState is NetworkStatusOffline;

              if (isOffline) {
                return const _CurrentContextOfflineView();
              }

              return _CurrentContextFailureView(message: state.message);
            },
          );
        }

        if (state is CurrentContextLoaded) {
          if (state.hasNoCompany) {
            return const _NoCompanyInvitationGate();
          }

          if (state.hasMultipleCompanies) {
            return const _SelectCompanyPlaceholderView();
          }

          return child;
        }

        return const _CurrentContextLoadingView();
      },
    );
  }
}

class _NoCompanyInvitationGate extends StatefulWidget {
  const _NoCompanyInvitationGate();

  @override
  State<_NoCompanyInvitationGate> createState() =>
      _NoCompanyInvitationGateState();
}

class _NoCompanyInvitationGateState extends State<_NoCompanyInvitationGate> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      context.read<CompanyUsersCubit>().loadCurrentUserPendingInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _CurrentContextLoadingView();
        }

        if (state.hasError) {
          return _CurrentContextFailureView(message: state.errorMessage!);
        }

        if (state.pendingInvitations.isNotEmpty) {
          return const PendingCompanyInvitationsScreen();
        }

        return const CreateCompanyScreen();
      },
    );
  }
}

class _CurrentContextLoadingView extends StatelessWidget {
  const _CurrentContextLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CurrentContextOfflineView extends StatelessWidget {
  const _CurrentContextOfflineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 52,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                const Text(
                  'You are offline',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No internet connection detected. Please reconnect and try again.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                MainButton(
                  text: 'Retry',
                  onPressed: () async {
                    await context.read<NetworkStatusCubit>().refresh();

                    if (!context.mounted) {
                      return;
                    }

                    context.read<CurrentContextCubit>().loadCurrentContext();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentContextFailureView extends StatelessWidget {
  const _CurrentContextFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load company context',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                MainButton(
                  text: 'Retry',
                  onPressed: () async {
                    await context.read<NetworkStatusCubit>().refresh();

                    if (!context.mounted) {
                      return;
                    }

                    context.read<CurrentContextCubit>().loadCurrentContext();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectCompanyPlaceholderView extends StatelessWidget {
  const _SelectCompanyPlaceholderView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Select Company screen will be added next.',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
