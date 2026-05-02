import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_form.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transaction_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/transactions_table.dart';

class TransactionsDesktopLayout extends StatelessWidget {
  const TransactionsDesktopLayout({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TransactionSearchField(
                  onChanged: (value) {
                    context.read<TransactionsCubit>().searchTransactions(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showTransactionDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TransactionsTable(transactions: transactions),
          ),
        ],
      ),
    );
  }
}
