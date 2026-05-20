import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_cubit.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_state.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/screens/pending_company_invitations_screen.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:mina_system/features/current_context/presentation/screens/create_company_screen.dart';
import 'package:mina_system/features/current_context/presentation/screens/select_company_screen.dart';

import 'views/current_context_failure_view.dart';
import 'views/current_context_loading_view.dart';
import 'views/current_context_offline_view.dart';

class CurrentContextGate extends StatelessWidget {
  const CurrentContextGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentContextCubit, CurrentContextState>(
      builder: (context, state) {
        if (state is CurrentContextInitial || state is CurrentContextLoading) {
          return const CurrentContextLoadingView();
        }

        if (state is CurrentContextFailure) {
          return BlocBuilder<NetworkStatusCubit, NetworkStatusState>(
            builder: (context, networkState) {
              final isOffline = networkState is NetworkStatusOffline;

              if (isOffline) {
                return const CurrentContextOfflineView();
              }

              return CurrentContextFailureView(message: state.message);
            },
          );
        }

        if (state is CurrentContextLoaded) {
          if (state.hasNoCompany) {
            return const _NoCompanyInvitationGate();
          }

          return _ExistingCompanyGate(state: state, child: child);
        }

        return const CurrentContextLoadingView();
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
  static const Duration _contextRecoveryInterval = Duration(seconds: 12);

  Timer? _contextRecoveryTimer;
  bool _isRefreshingContextSilently = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      context.read<CompanyUsersCubit>().loadCurrentUserPendingInvitations();
    });

    _startContextRecoveryGuard();
  }

  void _startContextRecoveryGuard() {
    _contextRecoveryTimer?.cancel();

    _contextRecoveryTimer = Timer.periodic(
      _contextRecoveryInterval,
      (_) => unawaited(_refreshContextSilently()),
    );
  }

  Future<void> _refreshContextSilently() async {
    if (!mounted || _isRefreshingContextSilently) {
      return;
    }

    _isRefreshingContextSilently = true;

    try {
      await context.read<CurrentContextCubit>().refreshCurrentContextSilently();
    } finally {
      _isRefreshingContextSilently = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
      builder: (context, state) {
        if (state.isCurrentUserInvitationsLoading) {
          return const CurrentContextLoadingView();
        }

        if (state.hasError) {
          return CurrentContextFailureView(message: state.errorMessage!);
        }

        if (state.pendingCurrentUserInvitations.isNotEmpty) {
          return const PendingCompanyInvitationsScreen();
        }

        return const CreateCompanyScreen();
      },
    );
  }

  @override
  void dispose() {
    _contextRecoveryTimer?.cancel();
    _contextRecoveryTimer = null;
    super.dispose();
  }
}

class _ExistingCompanyGate extends StatefulWidget {
  const _ExistingCompanyGate({required this.state, required this.child});

  final CurrentContextLoaded state;
  final Widget child;

  @override
  State<_ExistingCompanyGate> createState() => _ExistingCompanyGateState();
}

class _ExistingCompanyGateState extends State<_ExistingCompanyGate> {
  bool _hasChosenWorkspace = false;

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
      builder: (context, companyUsersState) {
        final currentCompany = widget.state.currentCompany;

        if (_hasChosenWorkspace && currentCompany != null) {
          return widget.child;
        }

        if (companyUsersState.isCurrentUserInvitationsLoading) {
          return const CurrentContextLoadingView();
        }

        if (companyUsersState.hasError) {
          if (currentCompany != null) {
            return widget.child;
          }

          return SelectCompanyScreen(
            companies: widget.state.companies,
            onCompanySelected: _selectCompany,
          );
        }

        if (widget.state.hasMultipleCompanies && currentCompany == null) {
          return SelectCompanyScreen(
            companies: widget.state.companies,
            onCompanySelected: _selectCompany,
          );
        }

        if (companyUsersState.pendingCurrentUserInvitations.isNotEmpty) {
          return SelectCompanyScreen(
            companies: widget.state.companies,
            onCompanySelected: _selectCompany,
          );
        }

        return widget.child;
      },
    );
  }

  void _selectCompany(String companyId) {
    setState(() => _hasChosenWorkspace = true);

    context.read<CurrentContextCubit>().selectCurrentCompany(
      companyId: companyId,
    );
  }
}
