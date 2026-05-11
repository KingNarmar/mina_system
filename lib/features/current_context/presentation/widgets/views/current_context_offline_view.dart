import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_cubit.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';

class CurrentContextOfflineView extends StatelessWidget {
  const CurrentContextOfflineView({super.key});

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
