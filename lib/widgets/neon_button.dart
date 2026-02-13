import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.isLoading = false,
    this.icon,
    this.iconSize = 24,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryColor;
    final buttonTextColor = textColor ?? AppTheme.backgroundColor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GlowButton(
        onPressed: isLoading ? null : onPressed,
        color: buttonColor,
        glowColor: buttonColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        width: width,
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: buttonTextColor,
              ),
              const SizedBox(width: 8),
            ],
            if (isLoading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: AppTheme.neonButton.copyWith(color: buttonTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class NeonToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeonToggleButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedBtnColor = selectedColor ?? AppTheme.primaryColor;
    final unselectedBtnColor = unselectedColor ?? Colors.transparent;
    final buttonTextColor = textColor ?? AppTheme.textColor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GlowButton(
        onPressed: onPressed,
        color: isSelected ? selectedBtnColor : unselectedBtnColor,
        glowColor: isSelected ? selectedBtnColor.withOpacity(0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderWidth: isSelected ? 0 : 2,
        borderColor: AppTheme.borderColor,
        child: Text(
          text,
          style: AppTheme.neonSecondary.copyWith(
            color: isSelected ? buttonTextColor : AppTheme.secondaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const NeonIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryColor;
    final iconBtnColor = iconColor ?? AppTheme.backgroundColor;

    return GlowButton(
      onPressed: onPressed,
      color: buttonColor,
      glowColor: buttonColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(size / 2),
      padding: EdgeInsets.all((size - iconSize) / 2),
      width: size,
      height: size,
      child: Icon(
        icon,
        size: iconSize,
        color: iconBtnColor,
      ),
      tooltip: tooltip,
    );
  }
}