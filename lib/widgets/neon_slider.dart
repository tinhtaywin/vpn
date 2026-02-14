import 'package:flutter/material.dart';

class NeonSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;

  NeonSlider({
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.activeColor,
    this.inactiveColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      label: label,
    );
  }
}
