import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

String generateNextTransactionCodeFromList(
  List<TransactionModel> transactions,
) {
  const prefix = 'TRX-';
  var maxNumber = 0;

  for (final transaction in transactions) {
    final transactionCode = transaction.transactionCode.trim().toUpperCase();

    if (!transactionCode.startsWith(prefix)) {
      continue;
    }

    final numberPart = transactionCode.substring(prefix.length);
    final number = int.tryParse(numberPart);

    if (number != null && number > maxNumber) {
      maxNumber = number;
    }
  }

  final nextNumber = maxNumber + 1;

  return '$prefix${nextNumber.toString().padLeft(3, '0')}';
}
