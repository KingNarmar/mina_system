import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

void showTransactionImagePreview(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog.fullscreen(
        backgroundColor: AppColors.overlayDark,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: _TransactionFullImage(imagePath: imagePath),
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
                    Icons.close,
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

class _TransactionFullImage extends StatelessWidget {
  const _TransactionFullImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _ImageErrorMessage();
        },
      );
    }

    return Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const _ImageErrorMessage();
      },
    );
  }
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
