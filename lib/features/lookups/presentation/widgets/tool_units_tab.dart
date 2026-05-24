import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_tool_unit_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_tool_unit_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/restore_tool_unit_lookup.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_add_row.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_card.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_list_tile.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_status_toggle.dart';

class ToolUnitsTab extends StatefulWidget {
  const ToolUnitsTab({
    super.key,
    required this.canCreateLookups,
    required this.canDeleteLookups,
    required this.canRestoreLookups,
    this.isCompactInputMode = false,
    this.onLookupInputFocusChanged,
  });

  final bool canCreateLookups;
  final bool canDeleteLookups;
  final bool canRestoreLookups;
  final bool isCompactInputMode;
  final ValueChanged<bool>? onLookupInputFocusChanged;

  @override
  State<ToolUnitsTab> createState() => _ToolUnitsTabState();
}

class _ToolUnitsTabState extends State<ToolUnitsTab> {
  final _unitController = TextEditingController();
  bool _showInactive = false;

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(
      widget.isCompactInputMode ? 16 : 24,
      widget.isCompactInputMode ? 8 : 24,
      widget.isCompactInputMode ? 16 : 24,
      bottomInset > 0 ? bottomInset + 16 : 24,
    );

    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, state) {
        final units = _showInactive ? state.inactiveToolUnits : state.toolUnits;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: LookupCard(
            title: 'Manage Tool Units',
            child: Column(
              children: [
                LookupStatusToggle(
                  showInactive: _showInactive,
                  onChanged: (value) {
                    setState(() {
                      _showInactive = value;
                    });
                  },
                ),
                const Gap(16),
                if (!_showInactive && widget.canCreateLookups) ...[
                  LookupAddRow(
                    hint: 'Unit Name',
                    controller: _unitController,
                    isCompactInputMode: widget.isCompactInputMode,
                    onFocusChanged: widget.onLookupInputFocusChanged,
                    onAdd: () async {
                      final isAdded = await addToolUnitLookup(
                        context: context,
                        unit: _unitController.text,
                        units: state.toolUnits,
                      );

                      if (isAdded) {
                        _unitController.clear();
                      }
                    },
                  ),
                  const Gap(20),
                ],
                if (units.isEmpty)
                  EmptyLookupMessage(
                    message: _showInactive
                        ? 'No inactive tool units found'
                        : 'No active tool units found',
                  )
                else
                  ...units.map((unit) {
                    return LookupListTile(
                      title: unit,
                      subtitle: _showInactive
                          ? 'Inactive Tool Unit'
                          : 'Active Tool Unit',
                      onDelete: !_showInactive && widget.canDeleteLookups
                          ? () {
                              confirmDeleteLookup(
                                context: context,
                                title: 'Deactivate Tool Unit',
                                message:
                                    'Are you sure you want to deactivate $unit?',
                                onConfirm: () async {
                                  await deleteToolUnitLookup(
                                    context: context,
                                    unit: unit,
                                  );
                                },
                              );
                            }
                          : null,
                      onRestore: _showInactive && widget.canRestoreLookups
                          ? () async {
                              await restoreToolUnitLookup(
                                context: context,
                                unit: unit,
                              );
                            }
                          : null,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
