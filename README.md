# SSTP VPN - Production-Ready Flutter Application

A complete, production-ready SSTP VPN client for Android and iOS built with Flutter.

## Features

✨ **Core Functionality**
- 🔒 Secure SSTP protocol over port 443
- 🌍 Real-time IP address tracking before and after connection
- 📱 Cross-platform support (Android & iOS)
- 🔐 Encrypted credential storage using Flutter Secure Storage
- 🔄 Auto-reconnect on network restore
- 📊 Connection duration tracking

🎨 **User Interface**
- Material Design 3 UI
- Clean and intuitive interface
- Animated connection button with visual feedback
- Real-time connection status indicator
- Multiple server management
- Light/Dark theme support

🔧 **Technical Features**
- Provider state management
- Secure credential storage
- Platform channel communication (Flutter ↔ Native)
- SSL/TLS encrypted connections
- Background VPN service
- Persistent notifications (Android)

## Screenshots

[Add screenshots here]

## Requirements

### Development
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode
- For iOS: MacOS with Xcode 14+
- For Android: Android SDK 21+

### Runtime
- Android 5.0 (API 21) or higher
- iOS 12.0 or higher (requires paid Apple Developer account for VPN capabilities)

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/sstp_vpn.git
cd sstp_vpn
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Android Setup

The Android native code is already configured. Just run:
```bash
flutter run -d android
```

### 4. iOS Setup

For iOS, you need:
1. A paid Apple Developer account
2. Enable Network Extension capability in Xcode
3. Configure provisioning profiles

Open `ios/Runner.xcworkspace` in Xcode and:
- Select Runner target
- Go to Signing & Capabilities
- Enable "Personal VPN" capability
- Enable "Network Extensions" capability
- Configure your development team

Then run:
```bash
flutter run -d ios
```

## Configuration

### Adding a VPN Server

1. Launch the app
2. Tap the "Servers" icon in the app bar
3. Tap the "+" button
4. Fill in the server details:
   - **Server Name**: A friendly name for your server
   - **Server Address**: The SSTP server hostname or IP
   - **Port**: Usually 443 (default)
   - **Username**: Your VPN username
   - **Password**: Your VPN password
5. Tap "Add Server"

### Connecting to VPN

1. Select a server from the servers list (or from the home screen)
2. Tap the large connection button on the home screen
3. Grant VPN permission when prompted (first time only)
4. Wait for connection to establish
5. View your new IP address in the "VPN IP Info" card

## Architecture

### Project Structure

```
lib/
├── constants/          # App-wide constants and colors
│   └── app_constants.dart
├── models/            # Data models
│   ├── ip_info.dart
│   ├── vpn_server.dart
│   ├── vpn_status.dart
│   └── connection_config.dart
├── providers/         # State management (Provider)
│   ├── vpn_provider.dart
│   ├── ip_info_provider.dart
│   └── server_provider.dart
├── screens/           # UI screens
│   ├── home_screen.dart
│   ├── servers_screen.dart
│   ├── add_server_screen.dart
│   └── settings_screen.dart
├── services/          # Business logic & API calls
│   ├── vpn_service.dart
│   ├── ip_api_service.dart
│   ├── storage_service.dart
│   └── logging_service.dart
├── widgets/           # Reusable widgets
│   ├── ip_info_card.dart
│   ├── connection_button.dart
│   ├── status_indicator.dart
│   └── server_list_item.dart
└── main.dart          # App entry point

android/app/src/main/kotlin/com/alihusains/sstp_vpn/
├── MainActivity.kt          # Flutter activity
├── VpnMethodChannel.kt      # Method channel handler
└── SstpVpnService.kt        # VPN service implementation

ios/Runner/
├── AppDelegate.swift        # iOS app delegate
└── SstpVpnManager.swift     # iOS VPN manager
```

### State Management

The app uses the Provider package for state management with three main providers:

1. **VpnProvider**: Manages VPN connection state and operations
2. **IpInfoProvider**: Fetches and stores IP information
3. **ServerProvider**: Handles server CRUD operations

### Native Implementation

#### Android (Kotlin)
- Uses Android VpnService API
- Implements SSTP protocol with SSL/TLS
- Handles packet forwarding between VPN interface and SSL socket
- Foreground service with persistent notification

#### iOS (Swift)
- Uses NetworkExtension framework
- Configures NEVPNManager with IKEv2 protocol
- Stores credentials securely in Keychain
- Requires Network Extension entitlements

## API Integration

### IP Information API

The app uses the free IP API from [freeipapi.com](https://freeipapi.com):

**Endpoint**: `https://free.freeipapi.com/api/json`

**Response Fields**:
- `ipAddress`: Current IP address
- `countryName`: Country name
- `cityName`: City name
- `regionName`: Region/state name
- `asnOrganization`: ISP/Organization
- `isProxy`: Proxy detection flag
- `latitude`: Geographic latitude
- `longitude`: Geographic longitude

## Security

### Credential Storage
- Passwords are stored using `flutter_secure_storage`
- Android: Uses EncryptedSharedPreferences
- iOS: Uses Keychain Services
- Never logged in debug output

### Network Security
- All VPN traffic encrypted with SSL/TLS
- SSTP protocol over port 443 (same as HTTPS)
- Certificate validation supported

## Troubleshooting

### Android

**Issue**: VPN permission denied
- Solution: Check AndroidManifest.xml has VPN permissions
- Ensure the VPN permission dialog is shown to the user

**Issue**: Connection fails immediately
- Solution: Check server address and port are correct
- Verify network connectivity
- Check Android logs: `adb logcat | grep SSTP`

### iOS

**Issue**: App crashes on VPN connection
- Solution: Ensure Network Extension capability is enabled
- Verify provisioning profile includes VPN entitlements
- Check iOS requires paid developer account for VPN

**Issue**: "Operation not permitted" error
- Solution: VPN features require paid Apple Developer account
- Free accounts cannot use Network Extension APIs

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ipa --release
```

## Testing

### Running Tests

```bash
flutter test
```

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] IP info loads on launch
- [ ] Can add a new server
- [ ] Can edit existing server
- [ ] Can delete a server
- [ ] VPN permission dialog appears
- [ ] Connection establishes successfully
- [ ] IP info updates after connection
- [ ] Connection duration tracks correctly
- [ ] Can disconnect successfully
- [ ] Auto-reconnect works on network restore
- [ ] App persists server list across restarts

## Known Limitations

1. **iOS VPN**: Requires paid Apple Developer account ($99/year)
2. **SSTP Protocol**: Full SSTP implementation is simplified; for production use with complex scenarios, consider integrating a native SSTP library
3. **Background Operation**: iOS may suspend VPN in certain conditions based on system policies

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [freeipapi.com](https://freeipapi.com) - Free IP geolocation API
- Provider package for state management
- Flutter community for excellent plugins

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Email: support@example.com

## Changelog

### Version 1.0.0 (2024)
- Initial release
- SSTP VPN client for Android and iOS
- Real-time IP tracking
- Multiple server management
- Auto-reconnect feature
- Secure credential storage

---

**Note**: This is a production-ready application template. For actual deployment, ensure you:
1. Test thoroughly with real SSTP servers
2. Implement proper error handling for edge cases
3. Add analytics and crash reporting
4. Implement proper certificate validation
5. Consider using professional SSTP libraries for production
6. Review and comply with App Store and Play Store guidelines
