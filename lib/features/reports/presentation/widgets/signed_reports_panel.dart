import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/company_date_time_formatter.dart';
import 'package:mina_system/features/reports/data/models/signed_report_model.dart';
import 'package:mina_system/features/reports/presentation/cubit/signed_reports_cubit.dart';
import 'package:mina_system/features/reports/presentation/cubit/signed_reports_state.dart';
import 'package:mina_system/features/reports/presentation/widgets/loading/signed_reports_loading_view.dart';

class SignedReportsPanel extends StatefulWidget {
  const SignedReportsPanel({
    super.key,
    required this.companyId,
    this.companyTimezone,
  });

  final String companyId;
  final String? companyTimezone;

  @override
  State<SignedReportsPanel> createState() => _SignedReportsPanelState();
}

class _SignedReportsPanelState extends State<SignedReportsPanel> {
  late final SignedReportsCubit _signedReportsCubit;
  late final TextEditingController _searchController;

  String? _selectedReportType;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  static const List<_SignedReportTypeOption> _reportTypeOptions = [
    _SignedReportTypeOption(
      value: 'worker_custody_report',
      label: 'Worker Custody Report',
    ),
    _SignedReportTypeOption(
      value: 'tool_history_report',
      label: 'Tool History Report',
    ),
    _SignedReportTypeOption(
      value: 'transactions_report',
      label: 'Transactions Report',
    ),
    _SignedReportTypeOption(
      value: 'lost_damaged_report',
      label: 'Lost & Damaged Report',
    ),
    _SignedReportTypeOption(
      value: 'loss_damage_report',
      label: 'Lost/Damaged Approval Report',
    ),
    _SignedReportTypeOption(
      value: 'tool_summary_report',
      label: 'Tool Summary Report',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _signedReportsCubit = SignedReportsCubit();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSignedReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _signedReportsCubit.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignedReportsCubit>.value(
      value: _signedReportsCubit,
      child: BlocConsumer<SignedReportsCubit, SignedReportsState>(
        listener: (context, state) {
          final errorMessage = state.errorMessage;

          if (errorMessage == null || errorMessage.trim().isEmpty) {
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(state),
                const Gap(18),
                _buildFilters(state),
                const Gap(18),
                _buildContent(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SignedReportsState state) {
    final refreshLabel = state.isRefreshing
        ? 'Refreshing...'
        : state.isLoading
        ? 'Loading...'
        : 'Refresh';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Signed Reports', style: AppTextStyles.title),
              Gap(6),
              Text(
                'Search and open saved signed PDF evidence records.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        Chip(
          avatar: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: Text('${state.reports.length} saved'),
          backgroundColor: AppColors.accent.withValues(alpha: 0.08),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.16)),
        ),
        OutlinedButton.icon(
          onPressed: state.isLoading ? null : _loadSignedReports,
          icon: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_outlined),
          label: Text(refreshLabel),
        ),
      ],
    );
  }

  Widget _buildFilters(SignedReportsState state) {
    final isLoading = state.isLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 840;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchField(expand: true, enabled: !isLoading),
              const Gap(10),
              _buildReportTypePicker(expand: true, enabled: !isLoading),
              const Gap(10),
              _buildDateButton(
                label: 'From',
                date: _dateFrom,
                expand: true,
                enabled: !isLoading,
                onPressed: () => _pickDate(isFrom: true),
              ),
              const Gap(10),
              _buildDateButton(
                label: 'To',
                date: _dateTo,
                expand: true,
                enabled: !isLoading,
                onPressed: () => _pickDate(isFrom: false),
              ),
              const Gap(10),
              OutlinedButton.icon(
                onPressed: isLoading ? null : _clearFilters,
                icon: const Icon(Icons.clear_outlined),
                label: const Text('Clear'),
              ),
              const Gap(10),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _loadSignedReports,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_outlined),
                label: Text(isLoading ? 'Searching...' : 'Search'),
              ),
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildSearchField(expand: false, enabled: !isLoading),
            _buildReportTypePicker(expand: false, enabled: !isLoading),
            _buildDateButton(
              label: 'From',
              date: _dateFrom,
              expand: false,
              enabled: !isLoading,
              onPressed: () => _pickDate(isFrom: true),
            ),
            _buildDateButton(
              label: 'To',
              date: _dateTo,
              expand: false,
              enabled: !isLoading,
              onPressed: () => _pickDate(isFrom: false),
            ),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _clearFilters,
                icon: const Icon(Icons.clear_outlined),
                label: const Text('Clear'),
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _loadSignedReports,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_outlined),
                label: Text(isLoading ? 'Searching...' : 'Search'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField({required bool expand, required bool enabled}) {
    final field = TextField(
      controller: _searchController,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        labelText: 'Search',
        hintText: 'Worker, HR, TRX, report no...',
        prefixIcon: Icon(Icons.search_outlined),
        border: OutlineInputBorder(),
      ),
      onSubmitted: enabled ? (_) => _loadSignedReports() : null,
    );

    if (expand) {
      return field;
    }

    return SizedBox(width: 300, child: field);
  }

  Widget _buildReportTypePicker({required bool expand, required bool enabled}) {
    final selectedLabel = _getSelectedReportTypeLabel();

    final picker = PopupMenuButton<String?>(
      enabled: enabled,
      tooltip: 'Select report type',
      initialValue: _selectedReportType,
      onSelected: (value) {
        setState(() {
          _selectedReportType = value;
        });
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String?>(
            value: null,
            child: Text('All report types'),
          ),
          ..._reportTypeOptions.map((option) {
            return PopupMenuItem<String?>(
              value: option.value,
              child: Text(option.label),
            );
          }),
        ];
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Report Type',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(
          selectedLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );

    if (expand) {
      return picker;
    }

    return SizedBox(width: 280, height: 56, child: picker);
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required bool expand,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    final button = SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.calendar_today_outlined, size: 18),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              date == null ? 'Any date' : _formatDate(date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );

    if (expand) {
      return button;
    }

    return SizedBox(width: 150, child: button);
  }

  Widget _buildContent(SignedReportsState state) {
    if (state.isInitialLoading) {
      return const SignedReportsLoadingView();
    }

    if (!state.hasReports) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 42,
              color: AppColors.textSecondary,
            ),
            Gap(10),
            Text('No signed reports found.', style: AppTextStyles.body),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.isRefreshing) ...[
          const LinearProgressIndicator(minHeight: 2),
          const Gap(12),
        ],
        ...state.reports.map((report) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SignedReportCard(
              report: report,
              isOpening: state.isOpeningReport(report.id),
              timezone: widget.companyTimezone,
              onOpen: () => _signedReportsCubit.openSignedReport(report),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();

    final initialDate = isFrom
        ? _dateFrom ?? _dateTo ?? now
        : _dateTo ?? _dateFrom ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      if (isFrom) {
        _dateFrom = pickedDate;

        if (_dateTo != null && _dateTo!.isBefore(_dateFrom!)) {
          _dateTo = _dateFrom;
        }
      } else {
        _dateTo = pickedDate;

        if (_dateFrom != null && _dateFrom!.isAfter(_dateTo!)) {
          _dateFrom = _dateTo;
        }
      }
    });
  }

  void _clearFilters() {
    if (_signedReportsCubit.state.isLoading) {
      return;
    }

    setState(() {
      _searchController.clear();
      _selectedReportType = null;
      _dateFrom = null;
      _dateTo = null;
    });

    _loadSignedReports();
  }

  Future<void> _loadSignedReports() {
    if (_signedReportsCubit.state.isLoading) {
      return Future<void>.value();
    }

    return _signedReportsCubit.loadSignedReports(
      companyId: widget.companyId,
      searchTerm: _searchController.text,
      reportType: _selectedReportType,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );
  }

  String _getSelectedReportTypeLabel() {
    if (_selectedReportType == null) {
      return 'All report types';
    }

    for (final option in _reportTypeOptions) {
      if (option.value == _selectedReportType) {
        return option.label;
      }
    }

    return 'All report types';
  }

  String _formatDate(DateTime dateTime) {
    return CompanyDateTimeFormatter.formatCompanyDateWithMonthName(dateTime);
  }
}

class _SignedReportCard extends StatelessWidget {
  const _SignedReportCard({
    required this.report,
    required this.isOpening,
    required this.timezone,
    required this.onOpen,
  });

  final SignedReportModel report;
  final bool isOpening;
  final String? timezone;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.reportNumber, style: AppTextStyles.title),
              const Gap(6),
              Text(report.reportTypeLabel, style: AppTextStyles.body),
              const Gap(12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.person_outline,
                    text: report.workerNameSnapshot?.trim().isNotEmpty == true
                        ? report.workerNameSnapshot!
                        : report.signedByName,
                  ),
                  if (report.workerHrCodeSnapshot?.trim().isNotEmpty == true)
                    _InfoChip(
                      icon: Icons.badge_outlined,
                      text: report.workerHrCodeSnapshot!,
                    ),
                  if (report.transactionCodeSnapshot?.trim().isNotEmpty == true)
                    _InfoChip(
                      icon: Icons.receipt_long_outlined,
                      text: report.transactionCodeSnapshot!,
                    ),
                  _InfoChip(
                    icon: Icons.event_outlined,
                    text: _formatDateTime(report.signedAt),
                  ),
                  _InfoChip(
                    icon: Icons.data_object_outlined,
                    text: _formatFileSize(report.fileSize),
                  ),
                ],
              ),
              const Gap(10),
              Text(
                'Created by ${report.createdByDisplayName}',
                style: AppTextStyles.caption,
              ),
            ],
          );

          final openButton = ElevatedButton.icon(
            onPressed: isOpening ? null : onOpen,
            icon: isOpening
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new_outlined),
            label: Text(isOpening ? 'Opening...' : 'Open PDF'),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [details, const Gap(14), openButton],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              const Gap(16),
              openButton,
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return CompanyDateTimeFormatter.formatDateTimeWithMonthName(
      dateTime,
      timezone: timezone,
      includeTimezone: true,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.border),
    );
  }
}

class _SignedReportTypeOption {
  const _SignedReportTypeOption({required this.value, required this.label});

  final String value;
  final String label;
}
