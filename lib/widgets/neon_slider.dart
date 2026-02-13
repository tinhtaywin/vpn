import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class NeonSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final String? Function(double)? valueLabelBuilder;
  final Color? activeColor;
  final Color? inactiveColor;
  final EdgeInsetsGeometry? margin;

  const NeonSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.valueLabelBuilder,
    this.activeColor,
    this.inactiveColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeColorColor = activeColor ?? AppTheme.primaryColor;
    final inactiveColorColor = inactiveColor ?? AppTheme.borderColor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTheme.neonSubtitle,
              ),
              Text(
                valueLabelBuilder != null
                    ? valueLabelBuilder!(value)
                    : value.toStringAsFixed(1),
                style: AppTheme.neonSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlowSlider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: activeColorColor,
            inactiveColor: inactiveColorColor,
            thumbColor: activeColorColor,
            overlayColor: activeColorColor.withOpacity(0.2),
            divisions: ((max - min) * 10).toInt(),
            label: valueLabelBuilder != null ? valueLabelBuilder!(value) : null,
          ),
        ],
      ),
    );
  }
}