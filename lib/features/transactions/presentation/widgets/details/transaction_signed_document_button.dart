import 'package:flutter/material.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionSignedDocumentButton extends StatelessWidget {
  const TransactionSignedDocumentButton({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () {
          _openApprovalDocument(context, transaction);
        },
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text('View Signed Document'),
      ),
    );
  }

  Future<void> _openApprovalDocument(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    try {
      final signedUrl = await TransactionsRepo()
          .createApprovalDocumentSignedUrl(transaction: transaction);

      final uri = Uri.parse(signedUrl);

      if (!await canLaunchUrl(uri)) {
        if (!context.mounted) return;
        _showMessage(context, 'Unable to open signed document.');
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, error.toString());
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
