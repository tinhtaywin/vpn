import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

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