import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
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

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        final transactions = state.filteredTransactions;

        final transactionsCubit = context.read<TransactionsCubit>();

        final custodyBalances = transactionsCubit.getFilteredCustodyBalances();

        final toolSummaries = transactionsCubit
            .getFilteredToolCustodySummaries();

        final pendingApprovalTransactions = _getPendingApprovalTransactions(
          state.transactions,
        );

        return Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

                return DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    backgroundColor: AppColors.background,
                    body: Column(
                      children: [
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
                                )
                              else
                                CustodyBalanceDesktopLayout(
                                  balances: custodyBalances,
                                ),
                              if (isMobile)
                                ToolCustodySummaryMobileLayout(
                                  summaries: toolSummaries,
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
            if (state.errorMessage != null)
              _TransactionsErrorBanner(message: state.errorMessage!),
            if (state.isLoading || state.isSubmitting)
              const _TransactionsLoadingOverlay(),
          ],
        );
      },
    );
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

class _TransactionsErrorBanner extends StatelessWidget {
  const _TransactionsErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Text(
          message,
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
      ),
    );
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
