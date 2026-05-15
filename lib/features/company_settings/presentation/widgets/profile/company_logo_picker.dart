import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

class CompanyLogoPicker extends StatelessWidget {
  const CompanyLogoPicker({
    super.key,
    required this.profile,
    required this.isSaving,
  });

  final CompanyProfileModel profile;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final hasLogo = profile.logoPath != null && profile.logoPath!.isNotEmpty;

    return BlocListener<CompanySettingsCubit, CompanySettingsState>(
      listenWhen: (previous, current) {
        return previous is CompanySettingsLoaded &&
            previous.isUploadingLogo &&
            current is CompanySettingsLoaded &&
            !current.isUploadingLogo;
      },
      listener: (context, state) {
        final loadedState = state as CompanySettingsLoaded;

        if (loadedState.hasError) {
          AppMessage.showError(context, loadedState.errorMessage!);
          context.read<CompanySettingsCubit>().clearErrorMessage();
          return;
        }

        AppMessage.showSuccess(context, 'Company logo uploaded.');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayDark.withValues(alpha: 0.025),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompanyLogoHeader(hasLogo: hasLogo),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CompanyLogoStatusCard(
                    hasLogo: hasLogo,
                    logoPath: profile.logoPath,
                  ),
                  const Gap(14),
                  SizedBox(
                    width: double.infinity,
                    child: MainButton(
                      text: hasLogo ? 'Change Logo' : 'Upload Logo',
                      isLoading: isSaving,
                      onPressed: () => _pickAndUploadLogo(context),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    'Logo changes are tracked in the company audit history.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadLogo(BuildContext context) async {
    final companyId = context.requireCurrentCompanyId();
    final cubit = context.read<CompanySettingsCubit>();

    try {
      await NetworkStatusService().ensureOnline();
    } on NetworkUnavailableException catch (error) {
      if (!context.mounted) {
        return;
      }

      AppMessage.showError(context, error.message);
      return;
    }

    FilePickerResult? result;

    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      AppMessage.showError(
        context,
        AppErrorMessage.fromError(
          error,
          fallback: 'Unable to select company logo. Please try again.',
        ),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    final extension = file.extension?.toLowerCase();

    if (bytes == null || extension == null) {
      AppMessage.showError(context, 'Unable to read selected file.');
      return;
    }

    final contentType = _getContentType(extension);

    if (contentType == null) {
      AppMessage.showWarning(
        context,
        'Please select a PNG, JPG, JPEG, or WEBP image.',
      );
      return;
    }

    await cubit.uploadCompanyLogo(
      companyId: companyId,
      bytes: bytes,
      fileExtension: extension,
      contentType: contentType,
    );
  }

  String? _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }
}

class _CompanyLogoHeader extends StatelessWidget {
  const _CompanyLogoHeader({required this.hasLogo});

  final bool hasLogo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Branding',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const Gap(5),
                Text(
                  'Company logo used in reports and official documents.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          _CompanyLogoBadge(hasLogo: hasLogo),
        ],
      ),
    );
  }
}

class _CompanyLogoBadge extends StatelessWidget {
  const _CompanyLogoBadge({required this.hasLogo});

  final bool hasLogo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: hasLogo
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasLogo
              ? AppColors.success.withValues(alpha: 0.16)
              : AppColors.warning.withValues(alpha: 0.16),
        ),
      ),
      child: Icon(
        hasLogo ? Icons.check_rounded : Icons.priority_high_rounded,
        size: 15,
        color: hasLogo ? AppColors.success : AppColors.warning,
      ),
    );
  }
}

class _CompanyLogoStatusCard extends StatelessWidget {
  const _CompanyLogoStatusCard({required this.hasLogo, required this.logoPath});

  final bool hasLogo;
  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final cleanLogoPath = logoPath?.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CompanyLogoVisualState(hasLogo: hasLogo),
              const Gap(12),
              Expanded(
                child: Text(
                  hasLogo ? 'Logo configured' : 'Logo missing',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Text(
            hasLogo
                ? 'Branding is ready for report templates and generated PDFs.'
                : 'Upload a PNG, JPG, JPEG, or WEBP image to complete branding.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (hasLogo && cleanLogoPath != null && cleanLogoPath.isNotEmpty) ...[
            const Gap(12),
            _CompanyLogoPathInfo(logoPath: cleanLogoPath),
          ],
        ],
      ),
    );
  }
}

class _CompanyLogoVisualState extends StatelessWidget {
  const _CompanyLogoVisualState({required this.hasLogo});

  final bool hasLogo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: hasLogo
            ? AppColors.success.withValues(alpha: 0.10)
            : AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLogo
              ? AppColors.success.withValues(alpha: 0.18)
              : AppColors.warning.withValues(alpha: 0.18),
        ),
      ),
      child: Icon(
        hasLogo ? Icons.verified_rounded : Icons.add_photo_alternate_outlined,
        color: hasLogo ? AppColors.success : AppColors.warning,
        size: 22,
      ),
    );
  }
}

class _CompanyLogoPathInfo extends StatelessWidget {
  const _CompanyLogoPathInfo({required this.logoPath});

  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_outlined,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const Gap(7),
          Expanded(
            child: Text(
              logoPath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
