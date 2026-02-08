import 'package:flutter/material.dart';
import '../models/vpn_status.dart';
import '../constants/app_constants.dart';

class StatusIndicator extends StatelessWidget {
  final VpnStatus status;
  final String? duration;

  const StatusIndicator({
    super.key,
    required this.status,
    this.duration,
  });

  Color _getStatusColor() {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.displayName,
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (duration != null && status == VpnStatus.connected) ...[
            const SizedBox(width: 8),
            Text(
              duration!,
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
