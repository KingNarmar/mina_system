import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_image_reference.dart';

void showTransactionImagePreview(BuildContext context, String imagePathOrUrl) {
  final reference = classifyTransactionImageReference(imagePathOrUrl);

  showDialog(
    context: context,
    builder: (_) {
      final localFile = reference.kind == TransactionImageReferenceKind.path
          ? File(reference.value)
          : null;
      final isLocalImage = localFile != null && localFile.existsSync();
      final isNetworkImage = reference.isSecureRemoteUrl;

      Widget imageContent = const _ImageErrorMessage();

      if (isLocalImage) {
        imageContent = Image.file(
          localFile,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const _ImageErrorMessage();
          },
        );
      } else if (isNetworkImage) {
        imageContent = Image.network(
          reference.value,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const _ImageErrorMessage();
          },
        );
      }

      return Dialog.fullscreen(
        backgroundColor: AppColors.overlayDark,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: imageContent)),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    AppIcons.close,
                    color: AppColors.onPrimary,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ImageErrorMessage extends StatelessWidget {
  const _ImageErrorMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Unable to load image',
      style: AppTextStyles.body.copyWith(color: AppColors.card),
    );
  }
}
