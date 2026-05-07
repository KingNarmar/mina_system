import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_approval_settlement_section.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_header.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_info_rows.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_note_section.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_proof_image_preview.dart';

class TransactionDetailsDialog extends StatelessWidget {
  const TransactionDetailsDialog({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDetailsHeader(transaction: transaction),
        const Gap(20),
        TransactionDetailsInfoRows(transaction: transaction),
        TransactionApprovalSettlementSection(transaction: transaction),
        const Gap(16),
        const SectionTitle(title: 'Photo'),
        const Gap(8),
        TransactionProofImagePreview(imagePath: transaction.imagePath ?? ''),
        const Gap(16),
        const SectionTitle(title: 'Note'),
        const Gap(8),
        TransactionNoteSection(note: transaction.note),
        const Gap(20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}
