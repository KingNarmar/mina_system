import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/layouts/custody_balance_desktop_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/layouts/custody_balance_mobile_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/layouts/transactions_desktop_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/layouts/transactions_mobile_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/pending_approvals/pending_approvals_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/layouts/tool_custody_summary_desktop_layout.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/layouts/tool_custody_summary_mobile_layout.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TransactionsView();
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView();

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  bool _isTransactionSearchFocused = false;
  bool _isCustodyBalanceSearchFocused = false;
  bool _isToolSummarySearchFocused = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionsCubit, TransactionsState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        AppMessage.showError(context, state.errorMessage!);
        context.read<TransactionsCubit>().clearErrorMessage();
      },
      child: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          final transactions = state.filteredTransactions;

          final transactionsCubit = context.read<TransactionsCubit>();

          final custodyBalances = transactionsCubit
              .getFilteredCustodyBalances();

          final toolSummaries = transactionsCubit
              .getFilteredToolCustodySummaries();

          final pendingApprovalTransactions = _getPendingApprovalTransactions(
            state.transactions,
          );

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, _) {
                  final mediaSize = MediaQuery.sizeOf(context);
                  final isMobile =
                      mediaSize.shortestSide < AppBreakpoints.tablet;
                  final isCompactLandscape =
                      isMobile && mediaSize.width > mediaSize.height;
                  final isAnySearchFocused =
                      _isTransactionSearchFocused ||
                      _isCustodyBalanceSearchFocused ||
                      _isToolSummarySearchFocused;
                  final isCompactSearchMode =
                      isCompactLandscape && isAnySearchFocused;

                  return DefaultTabController(
                    length: 4,
                    child: Scaffold(
                      backgroundColor: AppColors.background,
                      body: Column(
                        children: [
                          if (!isCompactSearchMode)
                            Container(
                              color: AppColors.card,
                              child: const TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColors.accent,
                                unselectedLabelColor: AppColors.textSecondary,
                                indicatorColor: AppColors.accent,
                                tabs: [
                                  Tab(text: 'Transactions'),
                                  Tab(text: 'Pending Approvals'),
                                  Tab(text: 'Custody Balance'),
                                  Tab(text: 'Tool Summary'),
                                ],
                              ),
                            ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                if (isMobile)
                                  TransactionsMobileLayout(
                                    transactions: transactions,
                                    selectedFilter: state.typeFilter,
                                    isCompactSearchMode: isCompactSearchMode,
                                    onSearchFocusChanged:
                                        _onTransactionSearchFocusChanged,
                                  )
                                else
                                  TransactionsDesktopLayout(
                                    transactions: transactions,
                                    selectedFilter: state.typeFilter,
                                  ),
                                PendingApprovalsLayout(
                                  transactions: pendingApprovalTransactions,
                                  isMobile: isMobile,
                                ),
                                if (isMobile)
                                  CustodyBalanceMobileLayout(
                                    balances: custodyBalances,
                                    isCompactSearchMode: isCompactSearchMode,
                                    onSearchFocusChanged:
                                        _onCustodyBalanceSearchFocusChanged,
                                  )
                                else
                                  CustodyBalanceDesktopLayout(
                                    balances: custodyBalances,
                                  ),
                                if (isMobile)
                                  ToolCustodySummaryMobileLayout(
                                    summaries: toolSummaries,
                                    isCompactSearchMode: isCompactSearchMode,
                                    onSearchFocusChanged:
                                        _onToolSummarySearchFocusChanged,
                                  )
                                else
                                  ToolCustodySummaryDesktopLayout(
                                    summaries: toolSummaries,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (state.isLoading || state.isSubmitting)
                const _TransactionsLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  void _onTransactionSearchFocusChanged(bool isFocused) {
    if (_isTransactionSearchFocused == isFocused) {
      return;
    }

    setState(() {
      _isTransactionSearchFocused = isFocused;
    });
  }

  void _onCustodyBalanceSearchFocusChanged(bool isFocused) {
    if (_isCustodyBalanceSearchFocused == isFocused) {
      return;
    }

    setState(() {
      _isCustodyBalanceSearchFocused = isFocused;
    });
  }

  void _onToolSummarySearchFocusChanged(bool isFocused) {
    if (_isToolSummarySearchFocused == isFocused) {
      return;
    }

    setState(() {
      _isToolSummarySearchFocused = isFocused;
    });
  }

  List<TransactionModel> _getPendingApprovalTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((transaction) {
      if (!transaction.isLostOrDamaged) {
        return false;
      }

      if (transaction.isApprovalPending) {
        return true;
      }

      return transaction.isApprovalApproved && transaction.isPendingSettlement;
    }).toList();
  }
}

class _TransactionsLoadingOverlay extends StatelessWidget {
  const _TransactionsLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.72),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
