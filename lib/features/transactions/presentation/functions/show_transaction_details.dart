import 'package:flutter/material.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_dialog.dart';

void showTransactionDetails(
  BuildContext context,
  TransactionModel transaction,
) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TransactionDetailsDialog(transaction: transaction),
          ),
        ),
      );
    },
  );
}
