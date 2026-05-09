import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_cubit.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_state.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';

class GlobalOfflineBanner extends StatelessWidget {
  const GlobalOfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkStatusCubit, NetworkStatusState>(
      builder: (context, networkState) {
        return BlocBuilder<CurrentContextCubit, CurrentContextState>(
          builder: (context, currentContextState) {
            final isOffline = networkState is NetworkStatusOffline;
            final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

            final isAppContextLoaded =
                currentContextState is CurrentContextLoaded &&
                !currentContextState.hasNoCompany &&
                !currentContextState.hasMultipleCompanies;

            final shouldShowBanner =
                isOffline && isAppContextLoaded && !isKeyboardOpen;

            return Column(
              children: [
                if (shouldShowBanner) const _OfflineBanner(),
                Expanded(child: child),
              ],
            );
          },
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Material(
        color: AppColors.warning,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Offline mode. You are currently offline. Some actions are temporarily disabled.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
