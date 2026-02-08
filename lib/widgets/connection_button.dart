import 'package:flutter/material.dart';
import '../models/vpn_status.dart';
import '../constants/app_constants.dart';

class ConnectionButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onPressed;
  final bool enabled;

  const ConnectionButton({
    super.key,
    required this.status,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends State<ConnectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getButtonColor() {
    if (!widget.enabled) {
      return Colors.grey;
    }
    
    switch (widget.status) {
      case VpnStatus.connected:
        return AppConstants.connectedColor;
      case VpnStatus.connecting:
      case VpnStatus.disconnecting:
        return AppConstants.connectingColor;
      case VpnStatus.error:
        return AppConstants.errorColor;
      case VpnStatus.disconnected:
        return AppConstants.disconnectedColor;
    }
  }

  IconData _getButtonIcon() {
    switch (widget.status) {
      case VpnStatus.connected:
        return Icons.stop;
      case VpnStatus.connecting:
      case VpnStatus.disconnecting:
        return Icons.hourglass_empty;
      case VpnStatus.disconnected:
      case VpnStatus.error:
        return Icons.power_settings_new;
    }
  }

  String _getButtonText() {
    switch (widget.status) {
      case VpnStatus.connected:
        return 'Disconnect';
      case VpnStatus.connecting:
        return 'Connecting...';
      case VpnStatus.disconnecting:
        return 'Disconnecting...';
      case VpnStatus.disconnected:
        return 'Connect';
      case VpnStatus.error:
        return 'Retry';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTransitioning = widget.status.isTransitioning;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.enabled && !isTransitioning) {
          widget.onPressed();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getButtonColor(),
            boxShadow: [
              BoxShadow(
                color: _getButtonColor().withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isTransitioning)
                const SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getButtonIcon(),
                    size: AppConstants.largeIconSize,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getButtonText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
