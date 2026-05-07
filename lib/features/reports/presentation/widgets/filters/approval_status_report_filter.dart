import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';

class ApprovalStatusReportFilter extends StatelessWidget {
  const ApprovalStatusReportFilter({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  static const String _allStatusesLabel = 'All statuses';

  static const Map<String, String> _statusLabels = {
    'not_required': 'Not Required',
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final selectedLabel = filters.approvalStatus == null
        ? _allStatusesLabel
        : _statusLabels[filters.approvalStatus] ?? _allStatusesLabel;

    return CustomDropdownFormField(
      hint: 'Approval Status',
      value: selectedLabel,
      items: const [
        _allStatusesLabel,
        'Not Required',
        'Pending',
        'Approved',
        'Rejected',
      ],
      onChanged: (value) {
        if (value == null || value == _allStatusesLabel) {
          onChanged(filters.copyWith(clearApprovalStatus: true));
          return;
        }

        final selectedStatus = _getStatusValue(value);

        if (selectedStatus == null) {
          onChanged(filters.copyWith(clearApprovalStatus: true));
          return;
        }

        onChanged(filters.copyWith(approvalStatus: selectedStatus));
      },
    );
  }

  String? _getStatusValue(String label) {
    final normalizedLabel = label.trim().toLowerCase();

    for (final entry in _statusLabels.entries) {
      if (entry.value.toLowerCase() == normalizedLabel) {
        return entry.key;
      }
    }

    return null;
  }
}
