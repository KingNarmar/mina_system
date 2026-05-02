import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_tool_unit_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_tool_unit_lookup.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_card.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_list_tile.dart';

class ToolUnitsTab extends StatefulWidget {
  const ToolUnitsTab({super.key});

  @override
  State<ToolUnitsTab> createState() => _ToolUnitsTabState();
}

class _ToolUnitsTabState extends State<ToolUnitsTab> {
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LookupCard(
            title: 'Manage Tool Units',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        hint: 'Unit Name',
                        controller: _unitController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final isAdded = addToolUnitLookup(
                            context: context,
                            unit: _unitController.text,
                            units: state.toolUnits,
                          );

                          if (isAdded) {
                            _unitController.clear();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.toolUnits.isEmpty)
                  const EmptyLookupMessage(message: 'No tool units found')
                else
                  ...state.toolUnits.map((unit) {
                    return LookupListTile(
                      title: unit,
                      subtitle: 'Tool Unit',
                      onDelete: () {
                        confirmDeleteLookup(
                          context: context,
                          title: 'Delete Tool Unit',
                          message: 'Are you sure you want to delete $unit?',
                          onConfirm: () {
                            deleteToolUnitLookup(
                              context: context,
                              unit: unit,
                            );
                          },
                        );
                      },
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