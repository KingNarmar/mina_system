import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/theme/app_icons.dart';

enum _TransactionImageSource { camera, file }

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

  bool get _canCapturePhoto {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) {
        if (isRequired && (imagePath == null || imagePath!.trim().isEmpty)) {
          return 'Proof image is required for this transaction';
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
              onTap: () {
                _onPickerPressed(context, fieldState);
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
                          ? AppIcons.image
                          : AppIcons.addPhotoAlternateOutlined,
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
                            ? 'Attach proof photo *'
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
                    const Gap(8),
                    Icon(
                      _canCapturePhoto
                          ? AppIcons.keyboardArrowUpRounded
                          : AppIcons.attachFileRounded,
                      color: AppColors.textSecondary,
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

  Future<void> _onPickerPressed(
    BuildContext context,
    FormFieldState<String> fieldState,
  ) async {
    if (!_canCapturePhoto) {
      await _chooseFile(context, fieldState);
      return;
    }

    final selectedSource = await showModalBottomSheet<_TransactionImageSource>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ImageSourceOptionTile(
                  icon: AppIcons.photoCameraOutlined,
                  title: 'Take Photo',
                  subtitle: 'Capture a new proof image using the camera.',
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(_TransactionImageSource.camera);
                  },
                ),
                _ImageSourceOptionTile(
                  icon: AppIcons.attachFileRounded,
                  title: 'Choose File',
                  subtitle: 'Select an existing JPG, PNG, or WEBP image.',
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(_TransactionImageSource.file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || selectedSource == null) {
      return;
    }

    switch (selectedSource) {
      case _TransactionImageSource.camera:
        await _takePhoto(context, fieldState);
      case _TransactionImageSource.file:
        await _chooseFile(context, fieldState);
    }
  }

  Future<void> _takePhoto(
    BuildContext context,
    FormFieldState<String> fieldState,
  ) async {
    try {
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);

      if (photo == null) {
        return;
      }

      _setSelectedImagePath(photo.path, fieldState);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showPickerError(
        context,
        'Could not open the camera. Please choose a file instead.',
      );
    }
  }

  Future<void> _chooseFile(
    BuildContext context,
    FormFieldState<String> fieldState,
  ) async {
    try {
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

      _setSelectedImagePath(selectedPath, fieldState);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showPickerError(
        context,
        'Could not choose the image file. Please try again.',
      );
    }
  }

  void _setSelectedImagePath(
    String selectedPath,
    FormFieldState<String> fieldState,
  ) {
    onImageSelected(selectedPath);
    fieldState.didChange(selectedPath);
  }

  void _showPickerError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getFileName(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.split('/').last;
  }
}

class _ImageSourceOptionTile extends StatelessWidget {
  const _ImageSourceOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      onTap: onTap,
    );
  }
}
