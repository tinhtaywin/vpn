import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class NeonTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final void Function()? onSuffixIconPressed;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final Color? borderColor;
  final Color? focusColor;
  final Color? textColor;
  final Color? hintColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const NeonTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
    this.borderColor,
    this.focusColor,
    this.textColor,
    this.hintColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColorColor = borderColor ?? AppTheme.borderColor;
    final focusColorColor = focusColor ?? AppTheme.primaryColor;
    final textColorColor = textColor ?? AppTheme.textColor;
    final hintColorColor = hintColor ?? AppTheme.secondaryTextColor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                label,
                style: AppTheme.neonSecondary,
              ),
            ),
          GlowContainer(
            color: Colors.transparent,
            glowColor: focusColorColor.withOpacity(0.3),
            glowRadius: 10,
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTheme.neonSecondary.copyWith(color: hintColorColor),
                contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColorColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColorColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: focusColorColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: hintColorColor,
                        size: 20,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          suffixIcon,
                          color: hintColorColor,
                          size: 20,
                        ),
                        onPressed: onSuffixIconPressed,
                      )
                    : null,
                isDense: true,
              ),
              style: AppTheme.neonBody.copyWith(color: textColorColor),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              enabled: enabled,
              validator: validator,
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              maxLines: maxLines,
              maxLength: maxLength,
              cursorColor: focusColorColor,
              cursorHeight: 20,
              cursorWidth: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class NeonDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final Color? borderColor;
  final Color? focusColor;
  final Color? textColor;
  final Color? hintColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const NeonDropdownField({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    this.hintText,
    this.onChanged,
    this.borderColor,
    this.focusColor,
    this.textColor,
    this.hintColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColorColor = borderColor ?? AppTheme.borderColor;
    final focusColorColor = focusColor ?? AppTheme.primaryColor;
    final textColorColor = textColor ?? AppTheme.textColor;
    final hintColorColor = hintColor ?? AppTheme.secondaryTextColor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                label,
                style: AppTheme.neonSecondary,
              ),
            ),
          GlowContainer(
            color: Colors.transparent,
            glowColor: focusColorColor.withOpacity(0.3),
            glowRadius: 10,
            child: Container(
              padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value != null ? focusColorColor : borderColorColor,
                  width: value != null ? 2 : 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: hintText != null
                      ? Text(
                          hintText!,
                          style: AppTheme.neonSecondary.copyWith(color: hintColorColor),
                        )
                      : null,
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: AppTheme.neonBody.copyWith(color: textColorColor),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  style: AppTheme.neonBody.copyWith(color: textColorColor),
                  dropdownColor: AppTheme.backgroundColor,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: hintColorColor,
                  ),
                  isExpanded: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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