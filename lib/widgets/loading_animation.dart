import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;
  final double strokeWidth;

  const NeonLoadingSpinner({
    super.key,
    this.size = 40,
    this.color,
    this.text,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? AppTheme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                color: spinnerColor.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            strokeWidth: strokeWidth,
          ),
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
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final baseColorColor = baseColor ?? AppTheme.cardColor;
    final highlightColorColor = highlightColor ?? AppTheme.primaryColor.withOpacity(0.3);
    final animationDuration = duration ?? const Duration(milliseconds: 1500);

    return AnimatedContainer(
      duration: animationDuration,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColorColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: highlightColorColor,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const Shimmer({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.period,
  });

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
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.color,
  });

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
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final iconColorColor = iconColor ?? AppTheme.primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: iconColorColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Icon(
                icon!,
                size: 48,
                color: iconColorColor,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.neonSubtitle,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry!,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18),
                  const SizedBox(width: 8),
                  Text('Try Again'),
                ],
              ),
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
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
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
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: onDismiss!,
                  iconSize: 32,
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
            ElevatedButton(
              onPressed: onRetry!,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18),
                  const SizedBox(width: 8),
                  Text('Retry'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}