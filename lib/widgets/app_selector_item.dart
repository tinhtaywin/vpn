import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../models/app_info.dart';
import '../theme/app_theme.dart';

class AppSelectorItem extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool showSystemApps;

  const AppSelectorItem({
    Key? key,
    required this.app,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.showSystemApps = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showSystemApps && app.isSystemApp) {
      return const SizedBox.shrink();
    }

    return NeonCard(
      isGlowing: isSelected,
      glowColor: isSelected ? AppTheme.primaryColor : Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    ? Image.file(
                        File(app.iconPath!),
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      )
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
              child: GlowCheckbox(
                value: isSelected,
                onChanged: (value) => onTap(),
                activeColor: AppTheme.primaryColor,
                checkColor: AppTheme.backgroundColor,
                side: BorderSide(color: AppTheme.borderColor, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                glowRadius: isSelected ? 15 : 0,
                glowColor: AppTheme.primaryColor.withOpacity(0.5),
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
    Key? key,
    required this.apps,
    required this.selectedApps,
    required this.onToggleApp,
    required this.onAppLongPress,
    this.showSystemApps = true,
    this.searchQuery = '',
  }) : super(key: key);

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

class AppSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  const AppSearchBar({
    Key? key,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppTheme.secondaryTextColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  hintStyle: AppTheme.neonSecondary.copyWith(color: AppTheme.secondaryTextColor.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTheme.neonBody,
                onChanged: onQueryChanged,
                controller: TextEditingController(text: query),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.clear,
                  color: AppTheme.secondaryTextColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}