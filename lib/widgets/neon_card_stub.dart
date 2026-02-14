
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const NeonCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.white.withOpacity(0.1);
    final cardElevation = elevation ?? 0;
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: cardBorderRadius,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class NeonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final bool? enabled;

  NeonTextField({
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.onTap,
    this.onSubmitted,
    this.textInputAction,
    this.inputFormatters,
    this.style,
    this.decoration,
    this.validator,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText!,
        enabled: enabled,
        onTap: onTap != null ? () => onTap!(controller?.text ?? '') : null,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        style: style,
        decoration: decoration ?? InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
