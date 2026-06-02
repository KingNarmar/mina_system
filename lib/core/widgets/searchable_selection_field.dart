import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

class SearchableSelectionField<T> extends StatelessWidget {
  const SearchableSelectionField({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedItem,
    required this.itemLabelBuilder,
    required this.onItemSelected,
    required this.searchMatcher,
    this.validator,
  });

  final String hint;
  final List<T> items;
  final T? selectedItem;
  final String Function(T item) itemLabelBuilder;
  final void Function(T item) onItemSelected;
  final bool Function(T item, String query) searchMatcher;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showSearchBottomSheet(context);
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          validator: (_) {
            return validator?.call(selectedItem);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: AppColors.border,
            hintText: selectedItem == null
                ? hint
                : itemLabelBuilder(selectedItem as T),
            hintStyle: selectedItem == null
                ? AppTextStyles.caption
                : AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            suffixIcon: const Icon(AppIcons.search),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return _SearchableSelectionBottomSheet<T>(
          hint: hint,
          items: items,
          itemLabelBuilder: itemLabelBuilder,
          onItemSelected: (item) {
            onItemSelected(item);
            Navigator.pop(context);
          },
          searchMatcher: searchMatcher,
        );
      },
    );
  }
}

class _SearchableSelectionBottomSheet<T> extends StatefulWidget {
  const _SearchableSelectionBottomSheet({
    required this.hint,
    required this.items,
    required this.itemLabelBuilder,
    required this.onItemSelected,
    required this.searchMatcher,
  });

  final String hint;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final void Function(T item) onItemSelected;
  final bool Function(T item, String query) searchMatcher;

  @override
  State<_SearchableSelectionBottomSheet<T>> createState() =>
      _SearchableSelectionBottomSheetState<T>();
}

class _SearchableSelectionBottomSheetState<T>
    extends State<_SearchableSelectionBottomSheet<T>> {
  final _searchController = TextEditingController();

  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);

    final isCompactDevice = mediaSize.shortestSide < AppBreakpoints.tablet;
    final isLandscape = mediaSize.width > mediaSize.height;
    final isKeyboardOpen = viewInsets.bottom > 0;
    final isCompactLandscape = isCompactDevice && isLandscape;

    final horizontalPadding = isCompactLandscape ? 16.0 : 20.0;
    final verticalPadding = isCompactLandscape ? 10.0 : 20.0;
    final contentGap = isCompactLandscape ? 8.0 : 16.0;

    final usableHeight = math.max(
      0.0,
      mediaSize.height -
          viewInsets.bottom -
          viewPadding.top -
          viewPadding.bottom -
          (verticalPadding * 2),
    );

    final preferredHeight = isCompactLandscape || isKeyboardOpen
        ? usableHeight
        : mediaSize.height * 0.75;

    final sheetHeight = math.min(preferredHeight, usableHeight);
    final shouldShowTitle = !(isCompactLandscape && isKeyboardOpen);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          viewInsets.bottom + verticalPadding,
        ),
        child: SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shouldShowTitle) ...[
                Text(
                  widget.hint,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(contentGap),
              ],
              CustomTextFormField(
                hint: 'Search...',
                controller: _searchController,
                icon: const Icon(AppIcons.search),
                onChanged: _onSearchChanged,
              ),
              Gap(contentGap),
              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No results found',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredItems.length,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 1,
                            color: AppColors.border,
                          );
                        },
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];

                          return ListTile(
                            title: Text(
                              widget.itemLabelBuilder(item),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              widget.onItemSelected(item);
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

  void _onSearchChanged(String query) {
    final cleanQuery = query.trim().toLowerCase();

    setState(() {
      if (cleanQuery.isEmpty) {
        _filteredItems = widget.items;
        return;
      }

      _filteredItems = widget.items.where((item) {
        return widget.searchMatcher(item, cleanQuery);
      }).toList();
    });
  }
}
