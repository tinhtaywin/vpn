import 'package:flutter/material.dart';
import '../models/vpn_status.dart';
import '../theme/app_theme.dart';

class ConnectionStatusIndicator extends StatefulWidget {
  final VpnStatus status;
  final double size;
  final bool showText;

  const ConnectionStatusIndicator({
    super.key,
    required this.status,
    this.size = 40,
    this.showText = true,
  });

  @override
  _ConnectionStatusIndicatorState createState() => _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _setupAnimations();
    _startAnimations();
  }

  @override
  void didUpdateWidget(covariant ConnectionStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.state != widget.status.state) {
      _setupAnimations();
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    switch (widget.status.state) {
      case VpnState.connected:
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _colorAnimation = ColorTween(begin: AppTheme.primaryColor, end: AppTheme.secondaryColor).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case VpnState.connecting:
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
        );
        _colorAnimation = ColorTween(begin: AppTheme.primaryColor, end: AppTheme.accentColor).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case VpnState.disconnecting:
        _scaleAnimation = Tween<double>(begin: 1.2, end: 0.8).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _colorAnimation = ColorTween(begin: AppTheme.secondaryColor, end: AppTheme.primaryColor).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case VpnState.error:
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _colorAnimation = ColorTween(begin: AppTheme.primaryColor, end: Colors.red).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case VpnState.disconnected:
      default:
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _colorAnimation = ColorTween(begin: AppTheme.primaryColor, end: AppTheme.primaryColor).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _opacityAnimation = Tween<double>(begin: 0.3, end: 0.3).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
    }
  }

  void _startAnimations() {
    _controller.reset();
    _controller.repeat(reverse: true);
  }

  Color _getStatusColor() {
    switch (widget.status.state) {
      case VpnState.connected:
        return AppTheme.secondaryColor;
      case VpnState.connecting:
        return AppTheme.accentColor;
      case VpnState.disconnecting:
        return AppTheme.primaryColor;
      case VpnState.error:
        return Colors.red;
      case VpnState.disconnected:
      default:
        return AppTheme.borderColor;
    }
  }

  String _getStatusText() {
    switch (widget.status.state) {
      case VpnState.connected:
        return 'Connected';
      case VpnState.connecting:
        return 'Connecting';
      case VpnState.disconnecting:
        return 'Disconnecting';
      case VpnState.error:
        return 'Error';
      case VpnState.disconnected:
      default:
        return 'Disconnected';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status.state) {
      case VpnState.connected:
        return Icons.vpn_lock;
      case VpnState.connecting:
        return Icons.sync;
      case VpnState.disconnecting:
        return Icons.vpn_key;
      case VpnState.error:
        return Icons.error;
      case VpnState.disconnected:
      default:
        return Icons.vpn_lock_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(widget.size / 2),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Icon(
            statusIcon,
            size: widget.size * 0.8,
            color: statusColor,
          ),
        ),
        if (widget.showText) ...[
          const SizedBox(height: 8),
          Text(
            statusText,
            style: AppTheme.neonSecondary.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

class PulsingConnectionIndicator extends StatelessWidget {
  final VpnStatus status;
  final double size;

  const PulsingConnectionIndicator({
    super.key,
    required this.status,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getStatusIcon(),
          size: size * 0.6,
          color: statusColor,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.state) {
      case VpnState.connected:
        return AppTheme.secondaryColor;
      case VpnState.connecting:
        return AppTheme.accentColor;
      case VpnState.disconnecting:
        return AppTheme.primaryColor;
      case VpnState.error:
        return Colors.red;
      case VpnState.disconnected:
      default:
        return AppTheme.borderColor;
    }
  }

  IconData _getStatusIcon() {
    switch (status.state) {
      case VpnState.connected:
        return Icons.vpn_lock;
      case VpnState.connecting:
        return Icons.sync;
      case VpnState.disconnecting:
        return Icons.vpn_key;
      case VpnState.error:
        return Icons.error;
      case VpnState.disconnected:
      default:
        return Icons.vpn_lock_outlined;
    }
  }
}