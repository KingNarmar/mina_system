import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

class CompanyLogoCard extends StatelessWidget {
  const CompanyLogoCard({
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Company logo uploaded.')));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Company Logo', style: AppTextStyles.title),
            const Gap(8),
            Text(
              hasLogo
                  ? 'Logo uploaded successfully. It will be used later in company reports and PDF documents.'
                  : 'No logo uploaded yet. Upload a logo to use later in reports and PDF documents.',
              style: AppTextStyles.body,
            ),
            const Gap(16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                child: MainButton(
                  text: hasLogo ? 'Change Logo' : 'Upload Logo',
                  isLoading: isSaving,
                  onPressed: () => _pickAndUploadLogo(context),
                ),
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

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
    );

    if (!context.mounted) return;

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    final extension = file.extension?.toLowerCase();

    if (bytes == null || extension == null) {
      _showMessage(context, 'Unable to read selected file.');
      return;
    }

    final contentType = _getContentType(extension);

    if (contentType == null) {
      _showMessage(context, 'Please select a PNG, JPG, JPEG, or WEBP image.');
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
