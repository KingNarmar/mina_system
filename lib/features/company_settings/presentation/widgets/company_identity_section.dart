import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/company_profile_form.dart';
import 'package:mina_system/features/company_settings/presentation/widgets/profile/company_logo_picker.dart';

class CompanyIdentitySection extends StatelessWidget {
  const CompanyIdentitySection({
    super.key,
    required this.profile,
    required this.isUpdatingProfile,
    required this.isUploadingLogo,
    required this.canManageCompanyProfile,
    required this.canUploadCompanyLogo,
  });

  final CompanyProfileModel profile;
  final bool isUpdatingProfile;
  final bool isUploadingLogo;
  final bool canManageCompanyProfile;
  final bool canUploadCompanyLogo;

  @override
  Widget build(BuildContext context) {
    if (!canManageCompanyProfile && !canUploadCompanyLogo) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 1100;

        if (isWideLayout && canManageCompanyProfile && canUploadCompanyLogo) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CompanyProfileForm(
                  profile: profile,
                  isSaving: isUpdatingProfile,
                ),
              ),
              const Gap(18),
              SizedBox(
                width: 430,
                child: CompanyLogoPicker(
                  profile: profile,
                  isSaving: isUploadingLogo,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canManageCompanyProfile) ...[
              CompanyProfileForm(profile: profile, isSaving: isUpdatingProfile),
              if (canUploadCompanyLogo) const Gap(16),
            ],
            if (canUploadCompanyLogo)
              CompanyLogoPicker(profile: profile, isSaving: isUploadingLogo),
          ],
        );
      },
    );
  }
}
