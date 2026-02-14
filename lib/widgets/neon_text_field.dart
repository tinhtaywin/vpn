import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final bool? enabled;
  final int? maxLines;
  final int? maxLength;
  final String? initialValue;

  const NeonTextField({
    Key? key,
    this.controller,
    this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.inputFormatters,
    this.style,
    this.enabled,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        obscureText: obscureText!,
        enabled: enabled,
        onChanged: onChanged,
        validator: validator,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        style: style ?? const TextStyle(color: Colors.white),
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}