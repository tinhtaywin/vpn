import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neon_card_stub.dart';

class AppSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  const AppSearchBar({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NeonCard(
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