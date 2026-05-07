import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_code_generator.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_filters.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({TransactionsRepo? transactionsRepo})
    : _transactionsRepo = transactionsRepo ?? TransactionsRepo(),
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

  Future<void> loadTransactions({required String companyId}) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final transactions = await _transactionsRepo.getTransactions(
        companyId: companyId,
      );

      emitUpdatedTransactions(transactions, isLoading: false);
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void searchTransactions(String query) {
    final filteredTransactions = filterTransactions(
      transactions: state.transactions,
      query: query,
      typeFilter: state.typeFilter,
    );

    emit(
      state.copyWith(
        searchQuery: query,
        filteredTransactions: filteredTransactions,
      ),
    );
  }

  void filterTransactionsByType(TransactionTypeFilter typeFilter) {
    final filteredTransactions = filterTransactions(
      transactions: state.transactions,
      query: state.searchQuery,
      typeFilter: typeFilter,
    );

    emit(
      state.copyWith(
        typeFilter: typeFilter,
        filteredTransactions: filteredTransactions,
      ),
    );
  }

  void searchCustodyBalances(String query) {
    emit(state.copyWith(custodyBalanceSearchQuery: query));
  }

  List<CustodyBalanceModel> getFilteredCustodyBalances() {
    final balances = getCustodyBalances();
    return filterCustodyBalances(balances, state.custodyBalanceSearchQuery);
  }

  void searchToolSummaries(String query) {
    emit(state.copyWith(toolSummarySearchQuery: query));
  }

  List<ToolCustodySummaryModel> getFilteredToolCustodySummaries() {
    final summaries = getToolCustodySummaries();
    return filterToolCustodySummaries(summaries, state.toolSummarySearchQuery);
  }

  Future<bool> addTransaction(
    TransactionModel transaction, {
    String? companyId,
    String? createdByProfileId,
  }) async {
    if (companyId == null || companyId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (createdByProfileId == null || createdByProfileId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Profile ID was not found'));
      return false;
    }

    if (transaction.workerId == null || transaction.workerId!.isEmpty) {
      emit(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    if (transaction.toolId == null || transaction.toolId!.isEmpty) {
      emit(state.copyWith(errorMessage: 'Tool ID was not found'));
      return false;
    }

    if (transaction.quantity <= 0) {
      emit(state.copyWith(errorMessage: 'Quantity must be greater than zero'));
      return false;
    }

    if (!_hasRequiredProofImage(transaction)) {
      emit(
        state.copyWith(
          errorMessage: 'Proof image is required for this transaction type',
        ),
      );
      return false;
    }

    if (!_hasRequiredNote(transaction)) {
      emit(
        state.copyWith(
          errorMessage: 'Note is required for lost or damaged transactions',
        ),
      );
      return false;
    }

    if (transaction.isClosingTransaction) {
      final currentBalance = getWorkerToolBalance(
        workerHrCode: transaction.workerHrCode,
        toolCode: transaction.toolCode,
      );

      if (transaction.quantity > currentBalance) {
        emit(
          state.copyWith(
            errorMessage:
                'Quantity cannot be greater than current custody balance',
          ),
        );
        return false;
      }
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final transactionCode = await _transactionsRepo
          .generateNextTransactionCode(companyId: companyId);

      final transactionToInsert = _applyApprovalRules(
        transaction.copyWith(
          companyId: companyId,
          transactionCode: transactionCode,
          createdByProfileId: createdByProfileId,
        ),
      );

      final addedTransaction = await _transactionsRepo.addTransaction(
        transaction: transactionToInsert,
      );

      emitUpdatedTransactions([
        addedTransaction,
        ...state.transactions,
      ], isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> updateTransaction({
    required TransactionModel updatedTransaction,
    String? companyId,
  }) async {
    final transactionId = updatedTransaction.id;

    if (companyId == null || companyId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (transactionId == null || transactionId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Transaction ID was not found'));
      return false;
    }

    if (updatedTransaction.workerId == null ||
        updatedTransaction.workerId!.isEmpty) {
      emit(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    if (updatedTransaction.toolId == null ||
        updatedTransaction.toolId!.isEmpty) {
      emit(state.copyWith(errorMessage: 'Tool ID was not found'));
      return false;
    }

    if (updatedTransaction.quantity <= 0) {
      emit(state.copyWith(errorMessage: 'Quantity must be greater than zero'));
      return false;
    }

    if (!_hasRequiredProofImage(updatedTransaction)) {
      emit(
        state.copyWith(
          errorMessage: 'Proof image is required for this transaction type',
        ),
      );
      return false;
    }

    if (!_hasRequiredNote(updatedTransaction)) {
      emit(
        state.copyWith(
          errorMessage: 'Note is required for lost or damaged transactions',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final transactionToUpdate = _applyApprovalRules(
        updatedTransaction.copyWith(companyId: companyId),
      );

      final savedTransaction = await _transactionsRepo.updateTransaction(
        transactionId: transactionId,
        transaction: transactionToUpdate,
      );

      _emitReplacedTransaction(savedTransaction, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> uploadApprovalDocument({
    required TransactionModel transaction,
    required String localDocumentPath,
  }) async {
    if (!_validateLostDamagedPendingTransaction(transaction)) {
      return false;
    }

    if (localDocumentPath.trim().isEmpty) {
      emit(
        state.copyWith(errorMessage: 'Approval document path was not found'),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo.uploadApprovalDocument(
        transaction: transaction,
        localDocumentPath: localDocumentPath,
      );

      _emitReplacedTransaction(savedTransaction, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> approveTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    String? decisionNote,
  }) async {
    if (!_validateLostDamagedPendingTransaction(transaction)) {
      return false;
    }

    if (!_validateProfileId(decidedByProfileId)) {
      return false;
    }

    if (!_hasApprovalDocument(transaction)) {
      emit(
        state.copyWith(
          errorMessage:
              'Signed approval document must be uploaded before approval',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo
          .approveLostDamagedTransaction(
            transaction: transaction,
            decidedByProfileId: decidedByProfileId,
            decisionNote: decisionNote,
          );

      _emitReplacedTransaction(savedTransaction, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> rejectTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    String? decisionNote,
  }) async {
    if (!_validateLostDamagedPendingTransaction(transaction)) {
      return false;
    }

    if (!_validateProfileId(decidedByProfileId)) {
      return false;
    }

    if (!_hasApprovalDocument(transaction)) {
      emit(
        state.copyWith(
          errorMessage:
              'Signed approval document must be uploaded before rejection',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo
          .rejectLostDamagedTransaction(
            transaction: transaction,
            decidedByProfileId: decidedByProfileId,
            decisionNote: decisionNote,
          );

      _emitReplacedTransaction(savedTransaction, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> settleTransaction({
    required TransactionModel transaction,
    required String settledByProfileId,
    String? settlementNote,
  }) async {
    final transactionId = transaction.id;

    if (transactionId == null || transactionId.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Transaction ID was not found'));
      return false;
    }

    if (!transaction.isLostOrDamaged) {
      emit(
        state.copyWith(
          errorMessage: 'Only lost or damaged transactions can be settled',
        ),
      );
      return false;
    }

    if (!transaction.isApprovalApproved) {
      emit(
        state.copyWith(
          errorMessage:
              'Only approved lost or damaged transactions can be settled',
        ),
      );
      return false;
    }

    if (!transaction.isPendingSettlement) {
      emit(
        state.copyWith(
          errorMessage: 'Only transactions pending settlement can be settled',
        ),
      );
      return false;
    }

    if (!_validateProfileId(settledByProfileId)) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo
          .settleApprovedLostDamagedTransaction(
            transaction: transaction,
            settledByProfileId: settledByProfileId,
            settlementNote: settlementNote,
          );

      _emitReplacedTransaction(savedTransaction, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  String generateNextTransactionCode() {
    return generateNextTransactionCodeFromList(state.transactions);
  }

  double getWorkerToolBalance({
    required String workerHrCode,
    required String toolCode,
  }) {
    return calculateWorkerToolBalance(
      transactions: state.transactions,
      workerHrCode: workerHrCode,
      toolCode: toolCode,
    );
  }

  bool hasWorkerTransactions(String workerHrCode) {
    return checkHasWorkerTransactions(state.transactions, workerHrCode);
  }

  bool hasToolTransactions(String toolCode) {
    return checkHasToolTransactions(state.transactions, toolCode);
  }

  List<CustodyBalanceModel> getCustodyBalances() {
    return calculateCustodyBalances(state.transactions);
  }

  List<ToolCustodySummaryModel> getToolCustodySummaries() {
    return calculateToolCustodySummaries(state.transactions);
  }

  int getClosedTodayCount() {
    return calculateClosedTodayCount(state.transactions);
  }

  void emitUpdatedTransactions(
    List<TransactionModel> transactions, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    emit(
      state.copyWith(
        transactions: transactions,
        filteredTransactions: filterTransactions(
          transactions: transactions,
          query: state.searchQuery,
          typeFilter: state.typeFilter,
        ),
        isLoading: isLoading,
        isSubmitting: isSubmitting,
        clearErrorMessage: true,
      ),
    );
  }

  TransactionModel _applyApprovalRules(TransactionModel transaction) {
    if (transaction.isLost || transaction.isDamaged) {
      return transaction.copyWith(
        approvalRequired: true,
        approvalStatus: transaction.approvalStatus == 'not_required'
            ? 'pending'
            : transaction.approvalStatus,
        settlementStatus: transaction.settlementStatus == 'not_required'
            ? 'not_required'
            : transaction.settlementStatus,
      );
    }

    return transaction.copyWith(
      approvalRequired: false,
      approvalStatus: 'not_required',
      settlementStatus: 'not_required',
    );
  }

  void _emitReplacedTransaction(
    TransactionModel savedTransaction, {
    bool? isSubmitting,
  }) {
    final updatedTransactions = state.transactions.map((transaction) {
      if (transaction.id == savedTransaction.id) {
        return savedTransaction;
      }

      return transaction;
    }).toList();

    emitUpdatedTransactions(updatedTransactions, isSubmitting: isSubmitting);
  }

  bool _validateLostDamagedPendingTransaction(TransactionModel transaction) {
    final transactionId = transaction.id;

    if (transactionId == null || transactionId.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Transaction ID was not found'));
      return false;
    }

    if (!transaction.isLostOrDamaged) {
      emit(
        state.copyWith(
          errorMessage:
              'This action is allowed only for lost or damaged transactions',
        ),
      );
      return false;
    }

    if (!transaction.isApprovalPending) {
      emit(
        state.copyWith(
          errorMessage: 'This action is allowed only while approval is pending',
        ),
      );
      return false;
    }

    return true;
  }

  bool _validateProfileId(String profileId) {
    if (profileId.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Profile ID was not found'));
      return false;
    }

    return true;
  }

  bool _hasApprovalDocument(TransactionModel transaction) {
    final approvalDocumentPath = transaction.approvalDocumentPath;

    return approvalDocumentPath != null &&
        approvalDocumentPath.trim().isNotEmpty;
  }

  bool _hasRequiredProofImage(TransactionModel transaction) {
    if (!transaction.isIssue && !transaction.isDamaged) {
      return true;
    }

    final imagePath = transaction.imagePath;

    return imagePath != null && imagePath.trim().isNotEmpty;
  }

  bool _hasRequiredNote(TransactionModel transaction) {
    if (!transaction.isLost && !transaction.isDamaged) {
      return true;
    }

    final note = transaction.note;

    return note != null && note.trim().isNotEmpty;
  }
}
