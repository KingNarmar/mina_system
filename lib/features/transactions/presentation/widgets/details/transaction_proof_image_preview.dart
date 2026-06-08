import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
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
      future: _resolveTransactionImageSource(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const EmptyDetailsBox(text: 'Loading image...');
        }

        final result = snapshot.data;

        if (result == null || !result.hasImageSource) {
          return EmptyDetailsBox(
            text:
                result?.message ??
                'Unable to load proof image. Please try again.',
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showTransactionImagePreview(context, result.imageSource!);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: result.isLocalFile
                ? Image.file(
                    File(result.imageSource!),
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return EmptyDetailsBox(
                        text: AppErrorMessage.fromError(
                          error,
                          fallback:
                              'Unable to load proof image. Please try again.',
                        ),
                      );
                    },
                  )
                : Image.network(
                    result.imageSource!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return EmptyDetailsBox(
                        text: AppErrorMessage.fromError(
                          error,
                          fallback:
                              'Unable to load proof image. Please try again.',
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<_ProofImageResult> _resolveTransactionImageSource(String path) async {
    try {
      final cleanPath = path.trim();

      if (cleanPath.isEmpty) {
        return const _ProofImageResult.failure('No photo attached');
      }

      final localFile = File(cleanPath);

      if (await localFile.exists()) {
        return _ProofImageResult.local(cleanPath);
      }

      if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
        return _ProofImageResult.remote(cleanPath);
      }

      await NetworkStatusService().ensureOnline();

      final signedUrl = await Supabase.instance.client.storage
          .from('transaction-proofs')
          .createSignedUrl(cleanPath, 60 * 60);

      return _ProofImageResult.remote(signedUrl);
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
  const _ProofImageResult.remote(this.imageSource)
    : message = null,
      isLocalFile = false;

  const _ProofImageResult.local(this.imageSource)
    : message = null,
      isLocalFile = true;

  const _ProofImageResult.failure(this.message)
    : imageSource = null,
      isLocalFile = false;

  final String? imageSource;
  final String? message;
  final bool isLocalFile;

  bool get hasImageSource =>
      imageSource != null && imageSource!.trim().isNotEmpty;
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
            const Icon(AppIcons.offline, size: 18, color: AppColors.warning),
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
