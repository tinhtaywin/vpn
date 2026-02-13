import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class NeonSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final EdgeInsetsGeometry? margin;

  const NeonSwitch({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeColorColor = activeColor ?? AppTheme.primaryColor;
    final inactiveColorColor = inactiveColor ?? AppTheme.borderColor;
    final thumbColorColor = thumbColor ?? AppTheme.backgroundColor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.neonSubtitle,
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: AppTheme.neonSecondary,
                      ),
                  ],
                ),
              ),
              GlowSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: activeColorColor,
                inactiveThumbColor: thumbColorColor,
                inactiveTrackColor: inactiveColorColor,
                activeThumbColor: thumbColorColor,
                activeTrackColor: activeColorColor.withOpacity(0.3),
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Icon(
                        Icons.check,
                        color: activeColorColor,
                      );
                    }
                    return Icon(
                      Icons.close,
                      color: inactiveColorColor,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}