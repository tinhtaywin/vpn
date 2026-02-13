import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class AppSelectorHeader extends StatelessWidget {
  final int totalApps;
  final int selectedApps;
  final bool showSystemApps;
  final ValueChanged<bool> onShowSystemAppsChanged;
  final ValueChanged<bool> onSelectAllChanged;
  final bool isAllSelected;

  const AppSelectorHeader({
    Key? key,
    required this.totalApps,
    required this.selectedApps,
    required this.showSystemApps,
    required this.onShowSystemAppsChanged,
    required this.onSelectAllChanged,
    required this.isAllSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    GlowButton(
                      onPressed: () => onSelectAllChanged(!isAllSelected),
                      color: isAllSelected ? AppTheme.secondaryColor : AppTheme.primaryColor,
                      glowColor: isAllSelected ? AppTheme.secondaryColor.withOpacity(0.5) : AppTheme.primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                GlowCheckbox(
                  value: showSystemApps,
                  onChanged: onShowSystemAppsChanged,
                  activeColor: AppTheme.accentColor,
                  checkColor: AppTheme.backgroundColor,
                  side: BorderSide(color: AppTheme.borderColor, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  glowRadius: showSystemApps ? 10 : 0,
                  glowColor: AppTheme.accentColor.withOpacity(0.5),
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