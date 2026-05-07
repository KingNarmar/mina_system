import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
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

    return FutureBuilder<String>(
      future: _resolveTransactionImageUrl(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const EmptyDetailsBox(text: 'Loading image...');
        }

        final imageUrl = snapshot.data;

        if (imageUrl == null || imageUrl.trim().isEmpty) {
          return const EmptyDetailsBox(text: 'Unable to load image');
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showTransactionImagePreview(context, imageUrl);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const EmptyDetailsBox(text: 'Unable to load image');
              },
            ),
          ),
        );
      },
    );
  }

  Future<String> _resolveTransactionImageUrl(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return Supabase.instance.client.storage
        .from('transaction-proofs')
        .createSignedUrl(path, 60 * 60);
  }
}

class EmptyDetailsBox extends StatelessWidget {
  const EmptyDetailsBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
