import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/add_tool_category_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/confirm_delete_lookup.dart';
import 'package:mina_system/features/lookups/presentation/functions/delete_tool_category_lookup.dart';
import 'package:mina_system/features/lookups/presentation/widgets/empty_lookup_message.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_add_row.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_card.dart';
import 'package:mina_system/features/lookups/presentation/widgets/lookup_list_tile.dart';
import 'package:gap/gap.dart';

class ToolCategoriesTab extends StatefulWidget {
  const ToolCategoriesTab({super.key});

  @override
  State<ToolCategoriesTab> createState() => _ToolCategoriesTabState();
}

class _ToolCategoriesTabState extends State<ToolCategoriesTab> {
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupsCubit, LookupsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LookupCard(
            title: 'Manage Tool Categories',
            child: Column(
              children: [
                LookupAddRow(
                  hint: 'Category Name',
                  controller: _categoryController,
                  onAdd: () {
                    final isAdded = addToolCategoryLookup(
                      context: context,
                      category: _categoryController.text,
                      categories: state.toolCategories,
                    );

                    if (isAdded) {
                      _categoryController.clear();
                    }
                  },
                ),
                const Gap(20),
                if (state.toolCategories.isEmpty)
                  const EmptyLookupMessage(message: 'No tool categories found')
                else
                  ...state.toolCategories.map((category) {
                    return LookupListTile(
                      title: category,
                      subtitle: 'Tool Category',
                      onDelete: () {
                        confirmDeleteLookup(
                          context: context,
                          title: 'Delete Tool Category',
                          message: 'Are you sure you want to delete $category?',
                          onConfirm: () {
                            deleteToolCategoryLookup(
                              context: context,
                              category: category,
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
