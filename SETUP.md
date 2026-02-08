# SSTP VPN - Setup Guide

This guide will help you set up the development environment and run the SSTP VPN application.

## Prerequisites

### Required Software

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. **Dart SDK** (3.0.0 or higher)
   - Comes bundled with Flutter

3. **Android Studio** (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK (API 21 or higher)
   - Install Android SDK Build-Tools
   - Install Android Emulator (optional)

4. **Xcode** (for iOS development, macOS only)
   - Install from Mac App Store
   - Install Xcode Command Line Tools: `xcode-select --install`
   - Open Xcode and accept license agreements

5. **Git**
   - Download from: https://git-scm.com/downloads

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd sstp_vpn
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

### 3. Verify Flutter Installation

```bash
flutter doctor -v
```

Fix any issues reported by Flutter Doctor before proceeding.

### 4. Android Setup

#### Configure Android SDK

1. Open Android Studio
2. Go to Preferences > Appearance & Behavior > System Settings > Android SDK
3. Ensure SDK Platforms API 21+ are installed
4. Ensure SDK Tools are installed:
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android Emulator

#### Create Android Local Properties

The `android/local.properties` file is already created. Update the SDK path if needed:

```properties
sdk.dir=/path/to/your/Android/sdk
flutter.sdk=/path/to/your/flutter
```

#### Run on Android

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run -d android
```

### 5. iOS Setup (macOS Only)

#### Install CocoaPods

```bash
sudo gem install cocoapods
```

#### Configure iOS Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Select your development team
5. Enable the following capabilities:
   - **Personal VPN**
   - **Network Extensions**

**Important:** VPN capabilities require a paid Apple Developer account ($99/year).

#### Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

#### Run on iOS

```bash
# List available iOS simulators
flutter devices

# Run on simulator
flutter run -d iPhone

# Run on physical device (with developer account configured)
flutter run -d <device-id>
```

### 6. Running the Application

#### Debug Mode

```bash
# Run on any connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload enabled (default)
flutter run --hot
```

#### Release Mode

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS IPA
flutter build ipa --release
```

## Project Structure

```
sstp_vpn/
├── android/              # Android native code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/  # Kotlin native implementation
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle
│   └── build.gradle
├── ios/                  # iOS native code
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── SstpVpnManager.swift
│   │   └── Info.plist
│   └── Runner.xcodeproj/
├── lib/                  # Flutter/Dart code
│   ├── constants/       # App constants
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── screens/         # UI screens
│   ├── services/        # Business logic
│   ├── widgets/         # Reusable widgets
│   └── main.dart        # Entry point
├── test/                # Unit tests
├── assets/              # Images, fonts, etc.
├── pubspec.yaml         # Dependencies
└── README.md            # Documentation
```

## Configuration

### API Configuration

The app uses the free IP API from freeipapi.com. No API key is required.

API Endpoint: `https://free.freeipapi.com/api/json`

### Customization

#### Change App Name

1. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application android:label="Your App Name">
   ```

2. Update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleDisplayName</key>
   <string>Your App Name</string>
   ```

3. Update `lib/constants/app_constants.dart`:
   ```dart
   static const String appName = 'Your App Name';
   ```

#### Change Bundle ID

1. Android: Update `android/app/build.gradle`:
   ```gradle
   applicationId "com.yourcompany.sstp_vpn"
   ```

2. iOS: Update in Xcode under Runner target > General > Bundle Identifier

#### Change App Colors

Edit `lib/constants/app_constants.dart`:
```dart
static const Color primaryColor = Color(0xFF2196F3);
```

## Testing

### Run Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/widget_test.dart
```

### Test Coverage

```bash
flutter test --coverage
```

## Troubleshooting

### Common Issues

#### 1. "Waiting for another flutter command to release the startup lock"

```bash
rm ~/.flutter/bin/cache/lockfile
```

#### 2. Android build fails with "Execution failed for task ':app:processDebugResources'"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. iOS build fails with "CocoaPods not installed"

```bash
sudo gem install cocoapods
cd ios
pod install
```

#### 4. "VPN permission not available" on iOS

- Ensure you have a paid Apple Developer account
- Enable Personal VPN capability in Xcode
- Enable Network Extensions capability in Xcode

#### 5. Gradle version issues

Update `android/gradle/wrapper/gradle-wrapper.properties` to use a compatible Gradle version.

### Getting Help

- Check the [README.md](README.md) for general information
- Review the [CHANGELOG.md](CHANGELOG.md) for version history
- Open an issue on GitHub
- Check Flutter documentation: https://flutter.dev/docs

## Development Workflow

### 1. Create a New Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Edit files in `lib/`, `android/`, or `ios/` directories.

### 3. Test Changes

```bash
flutter test
flutter run
```

### 4. Format Code

```bash
flutter format .
```

### 5. Analyze Code

```bash
flutter analyze
```

### 6. Commit Changes

```bash
git add .
git commit -m "Description of changes"
```

### 7. Push Changes

```bash
git push origin feature/your-feature-name
```

## Production Deployment

### Android Play Store

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=key
   storeFile=<path-to-key.jks>
   ```

3. Build release:
   ```bash
   flutter build appbundle --release
   ```

4. Upload to Play Console

### iOS App Store

1. Archive in Xcode: Product > Archive
2. Upload to App Store Connect
3. Submit for review

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Android Developer Documentation](https://developer.android.com/docs)
- [iOS Developer Documentation](https://developer.apple.com/documentation/)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)

## Next Steps

1. Configure your SSTP VPN server details
2. Test the connection with a real SSTP server
3. Customize the UI to match your brand
4. Add additional features as needed
5. Deploy to App Store and Play Store

For more information, see the main [README.md](README.md) file.
