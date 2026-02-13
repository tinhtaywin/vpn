import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isGlowing;
  final Color? glowColor;
  final double glowRadius;
  final VoidCallback? onTap;
  final bool showShadow;

  const NeonCard({
    Key? key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderRadius = 16,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.isGlowing = false,
    this.glowColor,
    this.glowRadius = 20,
    this.onTap,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.cardColor;
    final borderColorColor = borderColor ?? AppTheme.borderColor;
    final glowColorColor = glowColor ?? AppTheme.primaryColor;

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColorColor,
          width: isGlowing ? 2 : 1,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: isGlowing ? glowColorColor.withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: isGlowing ? 30 : 20,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: isGlowing
            ? GlowContainer(
                color: Colors.transparent,
                glowColor: glowColorColor,
                glowRadius: glowRadius,
                child: card,
              )
            : card,
      );
    }

    return isGlowing
        ? GlowContainer(
            color: Colors.transparent,
            glowColor: glowColorColor,
            glowRadius: glowRadius,
            child: card,
          )
        : card;
  }
}

class NeonInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool isHighlighted;

  const NeonInfoCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColorColor = iconColor ?? AppTheme.primaryColor;

    return NeonCard(
      isGlowing: isHighlighted,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColorColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.neonSecondary,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Text(
              title,
              style: AppTheme.neonSecondary,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: AppTheme.neonTitle.copyWith(
              fontSize: 24,
              foreground: isHighlighted
                  ? Paint()..shader = AppTheme.neonGradient.createShader(
                      Rect.fromLTWH(0, 0, 200, 100),
                    )
                  : null,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTheme.neonSecondary.copyWith(
                color: AppTheme.secondaryTextColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NeonStatusCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final bool isConnecting;

  const NeonStatusCard({
    Key? key,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    this.isConnecting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      isGlowing: statusColor == AppTheme.secondaryColor,
      glowColor: statusColor,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.neonSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: AppTheme.neonTitle.copyWith(
                  fontSize: 20,
                  color: statusColor,
                ),
              ),
              if (isConnecting) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}