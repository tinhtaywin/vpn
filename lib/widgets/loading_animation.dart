import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../theme/app_theme.dart';

class NeonLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;
  final double strokeWidth;

  const NeonLoadingSpinner({
    Key? key,
    this.size = 40,
    this.color,
    this.text,
    this.strokeWidth = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? AppTheme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlowCircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
          backgroundColor: AppTheme.borderColor,
          strokeWidth: strokeWidth,
          size: size,
          glowRadius: 15,
          glowColor: spinnerColor.withOpacity(0.5),
        ),
        if (text != null) ...[
          const SizedBox(height: 16),
          Text(
            text!,
            style: AppTheme.neonSecondary.copyWith(color: spinnerColor),
          ),
        ],
      ],
    );
  }
}

class NeonShimmer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const NeonShimmer({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    this.baseColor,
    this.highlightColor,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColorColor = baseColor ?? AppTheme.cardColor;
    final highlightColorColor = highlightColor ?? AppTheme.primaryColor.withOpacity(0.3);
    final animationDuration = duration ?? const Duration(milliseconds: 1500);

    return Shimmer.fromColors(
      baseColor: baseColorColor,
      highlightColor: highlightColorColor,
      period: animationDuration,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColorColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const Shimmer({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.period,
  }) : super(key: key);

  static ShimmerState of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>()!;
  }

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class NeonSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const NeonSkeleton({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skeletonColor = color ?? AppTheme.cardColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: skeletonColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.borderColor.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class NeonPlaceholder extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onRetry;

  const NeonPlaceholder({
    Key? key,
    required this.message,
    this.icon,
    this.iconColor,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColorColor = iconColor ?? AppTheme.primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            GlowIcon(
              icon!,
              size: 64,
              glowColor: iconColorColor.withOpacity(0.5),
              glowRadius: 20,
              color: iconColorColor,
            ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.neonSubtitle,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            NeonButton(
              text: 'Try Again',
              onPressed: onRetry!,
              color: AppTheme.primaryColor,
              icon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

class NeonErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const NeonErrorWidget({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      isGlowing: true,
      glowColor: Colors.red,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: AppTheme.neonSubtitle,
                ),
                const Spacer(),
                if (onDismiss != null)
                  NeonIconButton(
                    icon: Icons.close,
                    onPressed: onDismiss!,
                    size: 32,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTheme.neonBody,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: AppTheme.neonSecondary,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              NeonButton(
                text: 'Retry',
                onPressed: onRetry!,
                color: Colors.red,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}