import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neon_card_stub.dart';

class AppSelectorHeader extends StatelessWidget {
  final int totalApps;
  final int selectedApps;
  final bool showSystemApps;
  final ValueChanged<bool> onShowSystemAppsChanged;
  final ValueChanged<bool> onSelectAllChanged;
  final bool isAllSelected;

  const AppSelectorHeader({
    super.key,
    required this.totalApps,
    required this.selectedApps,
    required this.showSystemApps,
    required this.onShowSystemAppsChanged,
    required this.onSelectAllChanged,
    required this.isAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NeonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'App Selection',
                  style: AppTheme.neonSubtitle,
                ),
                Row(
                  children: [
                    Text(
                      '$selectedApps / $totalApps',
                      style: AppTheme.neonSecondary,
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => onSelectAllChanged(!isAllSelected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAllSelected ? AppTheme.secondaryColor : AppTheme.primaryColor,
                        foregroundColor: AppTheme.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        isAllSelected ? 'Deselect All' : 'Select All',
                        style: AppTheme.neonSecondary.copyWith(
                          color: AppTheme.backgroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: showSystemApps,
                  onChanged: (bool? value) => onShowSystemAppsChanged(value ?? false),
                  activeColor: AppTheme.accentColor,
                  checkColor: AppTheme.backgroundColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Show system apps',
                  style: AppTheme.neonSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}