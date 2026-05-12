import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit_helpers.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit_validators.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_filters.dart';

part 'transactions_cubit_approval_workflow.dart';
part 'transactions_cubit_calculations.dart';
part 'transactions_cubit_crud.dart';
part 'transactions_cubit_load_search.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({
    TransactionsRepo? transactionsRepo,
    NetworkStatusService? networkStatusService,
  }) : _transactionsRepo = transactionsRepo ?? TransactionsRepo(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(
         const TransactionsState(
           transactions: [],
           filteredTransactions: [],
           searchQuery: '',
           custodyBalanceSearchQuery: '',
           toolSummarySearchQuery: '',
           typeFilter: TransactionTypeFilter.all,
         ),
       );

  final TransactionsRepo _transactionsRepo;
  final NetworkStatusService _networkStatusService;

  void emitState(TransactionsState state) => emit(state);

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }

  void emitUpdatedTransactions(
    List<TransactionModel> transactions, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    emit(
      TransactionsCubitHelpers.updateTransactionsList(
        state,
        transactions,
        isLoading: isLoading,
        isSubmitting: isSubmitting,
      ),
    );
  }

  void _emitReplacedTransaction(
    TransactionModel savedTransaction, {
    bool? isSubmitting,
  }) {
    final updatedTransactions =
        TransactionsCubitHelpers.replaceTransactionInList(
          state.transactions,
          savedTransaction,
        );

    emitUpdatedTransactions(updatedTransactions, isSubmitting: isSubmitting);
  }
}
