import 'package:flutter/material.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_image_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProofImagePreview extends StatelessWidget {
  const TransactionProofImagePreview({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) {
      return const EmptyDetailsBox(text: 'No photo attached');
    }

    return FutureBuilder<_ProofImageResult>(
      future: _resolveTransactionImageUrl(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const EmptyDetailsBox(text: 'Loading image...');
        }

        final result = snapshot.data;

        if (result == null || !result.hasImageUrl) {
          return EmptyDetailsBox(
            text:
                result?.message ??
                'Unable to load proof image. Please try again.',
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showTransactionImagePreview(context, result.imageUrl!);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              result.imageUrl!,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return EmptyDetailsBox(
                  text: AppErrorMessage.fromError(
                    error,
                    fallback: 'Unable to load proof image. Please try again.',
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<_ProofImageResult> _resolveTransactionImageUrl(String path) async {
    try {
      await NetworkStatusService().ensureOnline();

      if (path.startsWith('http://') || path.startsWith('https://')) {
        return _ProofImageResult.success(path);
      }

      final signedUrl = await Supabase.instance.client.storage
          .from('transaction-proofs')
          .createSignedUrl(path, 60 * 60);

      return _ProofImageResult.success(signedUrl);
    } on NetworkUnavailableException {
      return const _ProofImageResult.failure(
        'Proof images are stored online and cannot be viewed while offline.',
      );
    } catch (error) {
      return _ProofImageResult.failure(
        AppErrorMessage.fromError(
          error,
          fallback: 'Unable to load proof image. Please try again.',
        ),
      );
    }
  }
}

class _ProofImageResult {
  const _ProofImageResult.success(this.imageUrl) : message = null;

  const _ProofImageResult.failure(this.message) : imageUrl = null;

  final String? imageUrl;
  final String? message;

  bool get hasImageUrl => imageUrl != null && imageUrl!.trim().isNotEmpty;
}

class EmptyDetailsBox extends StatelessWidget {
  const EmptyDetailsBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isOfflineMessage = text.toLowerCase().contains('offline');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isOfflineMessage
            ? AppColors.warning.withValues(alpha: 0.12)
            : AppColors.border,
        borderRadius: BorderRadius.circular(12),
        border: isOfflineMessage
            ? Border.all(color: AppColors.warning.withValues(alpha: 0.45))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOfflineMessage) ...[
            const Icon(
              Icons.wifi_off_rounded,
              size: 18,
              color: AppColors.warning,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: isOfflineMessage
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: isOfflineMessage
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
