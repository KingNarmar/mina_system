import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

void showTransactionImagePreview(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog.fullscreen(
        backgroundColor: AppColors.overlayDark,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
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
