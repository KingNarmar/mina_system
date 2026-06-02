part of '../document_template_card.dart';

class _DocumentTemplateHeader extends StatelessWidget {
  const _DocumentTemplateHeader({
    required this.title,
    required this.documentCode,
    required this.revisionNo,
    required this.isActive,
    required this.isSaving,
    required this.onSavePressed,
    required this.onAuditPressed,
  });

  final String title;
  final String documentCode;
  final String revisionNo;
  final bool isActive;
  final bool isSaving;
  final VoidCallback onSavePressed;
  final VoidCallback onAuditPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  AppIcons.documentTemplate,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DocumentTemplateInfoChip(
                          icon: AppIcons.tag,
                          label: documentCode.trim().isEmpty
                              ? 'No Code'
                              : documentCode.trim(),
                        ),
                        _DocumentTemplateInfoChip(
                          icon: AppIcons.revision,
                          label: revisionNo.trim().isEmpty
                              ? 'No Revision'
                              : 'Rev. ${revisionNo.trim()}',
                        ),
                        _DocumentTemplateStatusChip(isActive: isActive),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = _DocumentTemplateHeaderActions(
            isSaving: isSaving,
            onSavePressed: onSavePressed,
            onAuditPressed: onAuditPressed,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleBlock,
                const Gap(14),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const Gap(14),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _DocumentTemplateHeaderActions extends StatelessWidget {
  const _DocumentTemplateHeaderActions({
    required this.isSaving,
    required this.onSavePressed,
    required this.onAuditPressed,
  });

  final bool isSaving;
  final VoidCallback onSavePressed;
  final VoidCallback onAuditPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          height: 36,
          child: TextButton.icon(
            onPressed: onAuditPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(AppIcons.auditHistory, size: 17),
            label: const Text('Audit History'),
          ),
        ),
        SizedBox(
          width: 116,
          height: 36,
          child: MainButton(
            text: 'Save',
            isLoading: isSaving,
            onPressed: onSavePressed,
          ),
        ),
      ],
    );
  }
}
