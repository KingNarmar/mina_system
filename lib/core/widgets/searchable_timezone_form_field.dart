import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_timezones.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

class SearchableTimezoneFormField extends StatefulWidget {
  const SearchableTimezoneFormField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.hint = 'Company Timezone',
    this.helperText,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.contentPadding,
    this.hintStyle,
    this.textStyle,
  });

  final String? value;
  final void Function(String timezone) onChanged;
  final String? Function(String?)? validator;
  final String hint;
  final String? helperText;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  @override
  State<SearchableTimezoneFormField> createState() {
    return _SearchableTimezoneFormFieldState();
  }
}

class _SearchableTimezoneFormFieldState
    extends State<SearchableTimezoneFormField> {
  late final TextEditingController _controller;

  String get _safeValue {
    return AppTimezones.normalizeOrFallback(widget.value);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getDisplayLabel(_safeValue));
  }

  @override
  void didUpdateWidget(covariant SearchableTimezoneFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _controller.text = _getDisplayLabel(_safeValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helperText = widget.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          hint: widget.hint,
          controller: _controller,
          readOnly: true,
          icon: const Icon(Icons.schedule_rounded),
          fillColor: widget.fillColor,
          borderColor: widget.borderColor,
          focusedBorderColor: widget.focusedBorderColor,
          contentPadding: widget.contentPadding,
          hintStyle: widget.hintStyle,
          textStyle: widget.textStyle,
          validator: (_) {
            if (widget.validator == null) {
              return null;
            }

            return widget.validator!(_safeValue);
          },
          onTap: _openTimezonePicker,
        ),
        if (helperText != null && helperText.trim().isNotEmpty) ...[
          const Gap(6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              helperText.trim(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openTimezonePicker() async {
    final selectedTimezone = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _TimezonePickerSheet(selectedValue: _safeValue);
      },
    );

    if (selectedTimezone == null || selectedTimezone.trim().isEmpty) {
      return;
    }

    _controller.text = _getDisplayLabel(selectedTimezone);
    widget.onChanged(selectedTimezone);
  }

  String _getDisplayLabel(String timezone) {
    final option = AppTimezones.findByValue(timezone);

    if (option == null) {
      return AppTimezones.fallbackOption().label;
    }

    return option.label;
  }
}

class _TimezonePickerSheet extends StatefulWidget {
  const _TimezonePickerSheet({required this.selectedValue});

  final String selectedValue;

  @override
  State<_TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<_TimezonePickerSheet> {
  final _searchController = TextEditingController();
  late List<AppTimezoneOption> _options;

  @override
  void initState() {
    super.initState();
    _options = AppTimezones.search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      child: SizedBox(
        height: sheetHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const Gap(18),
              const Text('Select Company Timezone', style: AppTextStyles.title),
              const Gap(6),
              Text(
                'Used to display audit logs, transactions, and reports in your company local time.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Gap(16),
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: AppColors.background,
                  hintText: 'Search by country, city, or timezone',
                  hintStyle: AppTextStyles.caption,
                  prefixIcon: const Icon(Icons.search_rounded),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const Gap(14),
              Expanded(
                child: _options.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching timezones found.',
                          style: AppTextStyles.body,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _options.length,
                        separatorBuilder: (_, _) {
                          return const Divider(
                            height: 1,
                            color: AppColors.border,
                          );
                        },
                        itemBuilder: (context, index) {
                          final option = _options[index];
                          final isSelected =
                              option.value == widget.selectedValue;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              option.label,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              option.value,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.accent,
                                  )
                                : null,
                            onTap: () {
                              Navigator.of(context).pop(option.value);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _options = AppTimezones.search(value);
    });
  }
}
