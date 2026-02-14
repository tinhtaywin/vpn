import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../theme/app_theme.dart';
import 'neon_card_stub.dart';

class AppSelectorItem extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool showSystemApps;

  const AppSelectorItem({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.showSystemApps = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showSystemApps && app.isSystemApp) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: NeonCard(
        onTap: onTap,
        child: Row(
          children: [
            // App Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor, width: 1),
              ),
              child: Center(
                child: app.iconPath != null
                    ? Icon(Icons.image, color: AppTheme.primaryColor, size: 28)
                    : Icon(
                        app.isSystemApp ? Icons.settings_applications : Icons.apps,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            
            // App Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: AppTheme.neonSubtitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        app.packageName,
                        style: AppTheme.neonSecondary.copyWith(
                          color: AppTheme.secondaryTextColor.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      if (app.versionName != null)
                        Text(
                          'v${app.versionName}',
                          style: AppTheme.neonSecondary.copyWith(
                            color: AppTheme.secondaryTextColor.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      const Spacer(),
                      if (app.isSystemApp)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.accentColor, width: 1),
                          ),
                          child: Text(
                            'System',
                            style: AppTheme.neonSecondary.copyWith(
                              color: AppTheme.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Checkbox
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => onTap(),
                activeColor: AppTheme.primaryColor,
                checkColor: AppTheme.backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSelectorList extends StatelessWidget {
  final List<AppInfo> apps;
  final List<AppInfo> selectedApps;
  final Function(AppInfo) onToggleApp;
  final Function(AppInfo) onAppLongPress;
  final bool showSystemApps;
  final String searchQuery;

  const AppSelectorList({
    super.key,
    required this.apps,
    required this.selectedApps,
    required this.onToggleApp,
    required this.onAppLongPress,
    this.showSystemApps = true,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final filteredApps = apps.where((app) {
      final matchesSearch = app.appName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           app.packageName.toLowerCase().contains(searchQuery.toLowerCase());
      final shouldShowSystem = showSystemApps || !app.isSystemApp;
      return matchesSearch && shouldShowSystem;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        final isSelected = selectedApps.any((selected) => selected.packageName == app.packageName);
        
        return AppSelectorItem(
          app: app,
          isSelected: isSelected,
          onTap: () => onToggleApp(app),
          onLongPress: () => onAppLongPress(app),
          showSystemApps: showSystemApps,
        );
      },
    );
  }
}