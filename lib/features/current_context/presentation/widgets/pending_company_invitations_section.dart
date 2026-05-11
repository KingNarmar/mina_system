import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/widgets/pending_company_invitation_card.dart';

class PendingCompanyInvitationsSection extends StatelessWidget {
  const PendingCompanyInvitationsSection({
    super.key,
    required this.invitations,
    required this.isSubmitting,
  });

  final List<CompanyInvitationModel> invitations;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Invitations', style: AppTextStyles.title),
        const Gap(12),
        Column(
          children: invitations.map((invitation) {
            return PendingCompanyInvitationCard(
              invitation: invitation,
              isSubmitting: isSubmitting,
            );
          }).toList(),
        ),
      ],
    );
  }
}
