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
import 'package:mina_system/core/theme/app_icons.dart';

part 'signed_reports/signed_reports_header.dart';
part 'signed_reports/signed_reports_filters.dart';
part 'signed_reports/signed_reports_list.dart';
part 'signed_reports/signed_report_card.dart';

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
                _SignedReportsHeader(
                  state: state,
                  onRefresh: _loadSignedReports,
                ),
                const Gap(18),
                _SignedReportsFilters(
                  isLoading: state.isLoading,
                  searchController: _searchController,
                  selectedReportType: _selectedReportType,
                  dateFrom: _dateFrom,
                  dateTo: _dateTo,
                  onSearch: _loadSignedReports,
                  onClear: _clearFilters,
                  onPickDate: (isFrom) => _pickDate(isFrom: isFrom),
                  onReportTypeChanged: (value) {
                    setState(() {
                      _selectedReportType = value;
                    });
                  },
                ),
                const Gap(18),
                _SignedReportsList(
                  state: state,
                  companyTimezone: widget.companyTimezone,
                  onOpenReport: (report) =>
                      _signedReportsCubit.openSignedReport(report),
                ),
              ],
            ),
          );
        },
      ),
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
}
