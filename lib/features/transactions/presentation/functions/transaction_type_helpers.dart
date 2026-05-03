import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

const List<String> transactionTypeLabels = [
  'Issue',
  'Return',
  'Lost',
  'Damaged',
];

String getTransactionTypeLabel(TransactionType type) {
  switch (type) {
    case TransactionType.issue:
      return 'Issue';
    case TransactionType.returnTool:
      return 'Return';
    case TransactionType.lost:
      return 'Lost';
    case TransactionType.damaged:
      return 'Damaged';
  }
}

TransactionType getTransactionTypeFromLabel(String label) {
  switch (label.trim().toLowerCase()) {
    case 'issue':
      return TransactionType.issue;
    case 'return':
      return TransactionType.returnTool;
    case 'lost':
      return TransactionType.lost;
    case 'damaged':
      return TransactionType.damaged;
    default:
      return TransactionType.issue;
  }
}

bool isClosingTransactionType(TransactionType type) {
  return type != TransactionType.issue;
}

Color getTransactionTypeColor(TransactionType type) {
  switch (type) {
    case TransactionType.issue:
      return AppColors.error;
    case TransactionType.returnTool:
      return AppColors.accent;
    case TransactionType.lost:
      return AppColors.error;
    case TransactionType.damaged:
      return AppColors.error;
  }
}

IconData getTransactionTypeIcon(TransactionType type) {
  switch (type) {
    case TransactionType.issue:
      return Icons.north_east_outlined;
    case TransactionType.returnTool:
      return Icons.south_west_outlined;
    case TransactionType.lost:
      return Icons.report_problem_outlined;
    case TransactionType.damaged:
      return Icons.construction_outlined;
  }
}
