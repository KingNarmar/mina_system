part of '../signed_reports_panel.dart';

class _SignedReportTypeOption {
  const _SignedReportTypeOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _SignedReportsFilters extends StatelessWidget {
  const _SignedReportsFilters({
    required this.isLoading,
    required this.searchController,
    required this.selectedReportType,
    required this.dateFrom,
    required this.dateTo,
    required this.onSearch,
    required this.onClear,
    required this.onPickDate,
    required this.onReportTypeChanged,
  });

  final bool isLoading;
  final TextEditingController searchController;
  final String? selectedReportType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final void Function(bool isFrom) onPickDate;
  final ValueChanged<String?> onReportTypeChanged;

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

  String _getSelectedReportTypeLabel() {
    if (selectedReportType == null) {
      return 'All report types';
    }

    for (final option in _reportTypeOptions) {
      if (option.value == selectedReportType) {
        return option.label;
      }
    }

    return 'All report types';
  }

  String _formatDate(DateTime dateTime) {
    return CompanyDateTimeFormatter.formatCompanyDateWithMonthName(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
                date: dateFrom,
                expand: true,
                enabled: !isLoading,
                onPressed: () => onPickDate(true),
              ),
              const Gap(10),
              _buildDateButton(
                label: 'To',
                date: dateTo,
                expand: true,
                enabled: !isLoading,
                onPressed: () => onPickDate(false),
              ),
              const Gap(10),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onClear,
                icon: const Icon(Icons.clear_outlined),
                label: const Text('Clear'),
              ),
              const Gap(10),
              ElevatedButton.icon(
                onPressed: isLoading ? null : onSearch,
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
              date: dateFrom,
              expand: false,
              enabled: !isLoading,
              onPressed: () => onPickDate(true),
            ),
            _buildDateButton(
              label: 'To',
              date: dateTo,
              expand: false,
              enabled: !isLoading,
              onPressed: () => onPickDate(false),
            ),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onClear,
                icon: const Icon(Icons.clear_outlined),
                label: const Text('Clear'),
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onSearch,
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
      controller: searchController,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        labelText: 'Search',
        hintText: 'Worker, HR, TRX, report no...',
        prefixIcon: Icon(Icons.search_outlined),
        border: OutlineInputBorder(),
      ),
      onSubmitted: enabled ? (_) => onSearch() : null,
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
      initialValue: selectedReportType,
      onSelected: onReportTypeChanged,
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
}
