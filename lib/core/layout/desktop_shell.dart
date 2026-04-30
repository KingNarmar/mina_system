import 'package:flutter/material.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/layout/app_top_bar.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'M.I.N.A System',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 32),
                ...List.generate(AppNavItems.items.length, (index) {
                  final item = AppNavItems.items[index];
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              item.title,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AppTopBar(title: AppNavItems.items[_selectedIndex].title),
                Expanded(child: AppNavItems.items[_selectedIndex].page),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
