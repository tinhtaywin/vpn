import 'package:flutter/material.dart';

class NeonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;

  NeonSwitch({
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      activeTrackColor: activeColor?.withOpacity(0.5),
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor?.withOpacity(0.3),
    );
  }
}
