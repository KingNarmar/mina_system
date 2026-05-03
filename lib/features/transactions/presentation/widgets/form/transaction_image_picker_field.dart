import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:gap/gap.dart';

class TransactionImagePickerField extends StatelessWidget {
  const TransactionImagePickerField({
    super.key,
    required this.imagePath,
    required this.isRequired,
    required this.onImageSelected,
  });

  final String? imagePath;
  final bool isRequired;
  final ValueChanged<String> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) {
        if (isRequired && (imagePath == null || imagePath!.trim().isEmpty)) {
          return 'Image is required for issue transactions';
        }

        return null;
      },
      builder: (fieldState) {
        final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                  allowMultiple: false,
                );

                if (result == null || result.files.isEmpty) {
                  return;
                }

                final file = result.files.single;
                final selectedPath = file.path ?? file.name;

                onImageSelected(selectedPath);
                fieldState.didChange(selectedPath);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: fieldState.hasError
                        ? AppColors.error
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasImage
                          ? Icons.image_outlined
                          : Icons.add_photo_alternate_outlined,
                      color: hasImage
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        hasImage
                            ? _getFileName(imagePath!)
                            : isRequired
                            ? 'Attach issue photo *'
                            : 'Attach photo (optional)',
                        style: AppTextStyles.caption.copyWith(
                          color: hasImage
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: hasImage
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getFileName(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.split('/').last;
  }
}
