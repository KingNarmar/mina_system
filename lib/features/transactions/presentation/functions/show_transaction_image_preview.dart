import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

void showTransactionImagePreview(BuildContext context, String imagePathOrUrl) {
  final cleanValue = imagePathOrUrl.trim();

  showDialog(
    context: context,
    builder: (_) {
      final isNetworkImage =
          cleanValue.startsWith('http://') || cleanValue.startsWith('https://');

      final localFile = isNetworkImage ? null : File(cleanValue);
      final isLocalImage = localFile != null && localFile.existsSync();

      return Dialog.fullscreen(
        backgroundColor: AppColors.overlayDark,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: isLocalImage
                    ? Image.file(
                        localFile,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const _ImageErrorMessage();
                        },
                      )
                    : Image.network(
                        cleanValue,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const _ImageErrorMessage();
                        },
                      ),
              ),
            ),
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
