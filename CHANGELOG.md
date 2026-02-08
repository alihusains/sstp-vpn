# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-02-08

### Added
- Initial release of SSTP VPN application
- SSTP protocol support for secure VPN connections
- Real-time IP address tracking before and after VPN connection
- Multiple VPN server management (add, edit, delete)
- Secure credential storage using flutter_secure_storage
- Auto-reconnect feature on network restoration
- Connection duration tracking
- Material Design 3 UI with animated connection button
- Android native implementation with VpnService
- iOS native implementation with NetworkExtension
- Settings screen with auto-reconnect toggle
- Server list with selection support
- IP information display from freeipapi.com API
- Production-ready state management with Provider
- Comprehensive error handling and user feedback
- Persistent notifications for active VPN connections (Android)
- Background VPN service support

### Technical Features
- Flutter 3.0+ support
- Android SDK 21+ (Android 5.0+)
- iOS 12.0+
- Provider state management pattern
- Platform channel communication
- Secure storage implementation
- Connectivity monitoring
- Permission handling

## [Unreleased]

### Planned
- Connection statistics (data usage, speed)
- Multiple protocol support (IKEv2, OpenVPN)
- Server location map view
- Dark theme improvements
- Connection logs export
- Server performance testing
- Split tunneling support
- Favorite servers
- Quick connect widget
- Biometric authentication for connection
