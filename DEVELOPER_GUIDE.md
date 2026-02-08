# Developer Guide - SSTP VPN

## Architecture Overview

### Design Pattern: Clean Architecture + Provider

The application follows clean architecture principles with clear separation of concerns:

```
Presentation Layer (UI)
    ↓
Provider Layer (State Management)
    ↓
Service Layer (Business Logic)
    ↓
Data Layer (Storage/API)
```

### State Management: Provider

We use the Provider package for state management with three main providers:

#### 1. VpnProvider
**Purpose:** Manages VPN connection state and operations

**Key Methods:**
- `connect(VpnServer)` - Establishes VPN connection
- `disconnect()` - Closes VPN connection
- `toggleAutoReconnect(bool)` - Enables/disables auto-reconnect

**State:**
- `status` - Current VPN status (disconnected, connecting, connected, etc.)
- `connectionDuration` - Duration of current connection
- `autoReconnect` - Auto-reconnect setting

#### 2. IpInfoProvider
**Purpose:** Fetches and manages IP information

**Key Methods:**
- `fetchBeforeConnectionInfo()` - Gets IP info before VPN
- `fetchAfterConnectionInfo()` - Gets IP info after VPN connection
- `clearAfterConnectionInfo()` - Clears VPN IP info

**State:**
- `beforeConnectionInfo` - Original IP info
- `afterConnectionInfo` - VPN IP info
- `isLoading` - Loading state

#### 3. ServerProvider
**Purpose:** Manages VPN server list

**Key Methods:**
- `addServer(VpnServer)` - Adds new server
- `updateServer(VpnServer)` - Updates existing server
- `deleteServer(String)` - Removes server
- `selectServer(VpnServer)` - Sets active server

**State:**
- `servers` - List of all servers
- `selectedServer` - Currently selected server

## Adding New Features

### 1. Adding a New Screen

Create a new file in `lib/screens/`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Screen'),
      ),
      body: Consumer<YourProvider>(
        builder: (context, provider, child) {
          return YourWidget();
        },
      ),
    );
  }
}
```

### 2. Adding a New Widget

Create reusable widgets in `lib/widgets/`:

```dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
```

### 3. Adding a New Model

Create data models in `lib/models/`:

```dart
class NewModel {
  final String id;
  final String name;

  NewModel({
    required this.id,
    required this.name,
  });

  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

### 4. Adding a New Service

Create business logic in `lib/services/`:

```dart
import 'logging_service.dart';

class NewService {
  final LoggingService _logger = LoggingService();

  Future<void> performOperation() async {
    try {
      _logger.log('Starting operation');
      // Your logic here
      _logger.log('Operation completed');
    } catch (e) {
      _logger.logError('Operation failed', e);
      rethrow;
    }
  }
}
```

### 5. Adding a New Provider

Create state management in `lib/providers/`:

```dart
import 'package:flutter/material.dart';
import '../services/new_service.dart';

class NewProvider with ChangeNotifier {
  final NewService _service = NewService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> performAction() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _service.performOperation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## Platform Channel Communication

### Flutter → Native

In `lib/services/vpn_service.dart`:

```dart
final result = await _channel.invokeMethod('methodName', {
  'param1': value1,
  'param2': value2,
});
```

### Android Native Implementation

In `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
methodChannel?.setMethodCallHandler { call, result ->
    when (call.method) {
        "methodName" -> {
            val param1 = call.argument<String>("param1")
            // Handle method
            result.success(true)
        }
    }
}
```

### iOS Native Implementation

In `ios/Runner/SstpVpnManager.swift`:

```swift
private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "methodName":
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(...))
            return
        }
        // Handle method
        result(true)
    }
}
```

## Storage Best Practices

### Secure Storage (Credentials)

Use `flutter_secure_storage` for sensitive data:

```dart
await _secureStorage.write(key: 'password', value: password);
final password = await _secureStorage.read(key: 'password');
```

### Shared Preferences (Settings)

Use `shared_preferences` for non-sensitive data:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('setting', true);
final setting = prefs.getBool('setting') ?? false;
```

## Error Handling

### User-Facing Errors

Show user-friendly messages:

```dart
try {
  await operation();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Operation failed: ${e.toString()}'),
      backgroundColor: AppConstants.errorColor,
    ),
  );
}
```

### Logging Errors

Always log errors for debugging:

```dart
try {
  await operation();
} catch (e, stackTrace) {
  _logger.logError('Operation failed', e, stackTrace);
}
```

## Testing

### Unit Tests

Test business logic in isolation:

```dart
void main() {
  group('VpnProvider Tests', () {
    test('Initial status is disconnected', () {
      final provider = VpnProvider();
      expect(provider.status, VpnStatus.disconnected);
    });
  });
}
```

### Widget Tests

Test UI components:

```dart
void main() {
  testWidgets('Button displays correct text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectionButton(
          status: VpnStatus.disconnected,
          onPressed: () {},
        ),
      ),
    );
    
    expect(find.text('Connect'), findsOneWidget);
  });
}
```

## Code Style Guidelines

### Naming Conventions

- **Classes:** PascalCase (`VpnService`)
- **Variables:** camelCase (`isConnected`)
- **Constants:** camelCase with const (`primaryColor`)
- **Private members:** _leadingUnderscore (`_privateMethod`)

### File Organization

```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/model.dart';

// 2. Class definition
class MyWidget extends StatelessWidget {
  // 3. Fields
  final String title;
  
  // 4. Constructor
  const MyWidget({super.key, required this.title});
  
  // 5. Public methods
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
  
  // 6. Private methods
  Widget _buildContent() {
    return Container();
  }
}
```

### Comments

```dart
// Good: Explains WHY
// We delay to allow the VPN connection to stabilize
await Future.delayed(const Duration(seconds: 2));

// Bad: Explains WHAT (obvious from code)
// Set isLoading to true
isLoading = true;
```

## Performance Optimization

### 1. Use const Constructors

```dart
// Good
const Text('Hello');

// Bad
Text('Hello');
```

### 2. Avoid Rebuilding Widgets

```dart
// Good: Only rebuilds when specific provider changes
Consumer<VpnProvider>(
  builder: (context, vpnProvider, child) {
    return Text(vpnProvider.status.displayName);
  },
)

// Bad: Rebuilds entire tree
Builder(
  builder: (context) {
    final vpnProvider = Provider.of<VpnProvider>(context);
    return Text(vpnProvider.status.displayName);
  },
)
```

### 3. Use ListView.builder for Lists

```dart
// Good: Lazy loading
ListView.builder(
  itemCount: servers.length,
  itemBuilder: (context, index) {
    return ServerListItem(server: servers[index]);
  },
)

// Bad: All items created at once
ListView(
  children: servers.map((s) => ServerListItem(server: s)).toList(),
)
```

## Debugging

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Print Debugging

Use the logging service:

```dart
_logger.log('Connection status: ${status.displayName}');
```

### Android Logs

```bash
adb logcat | grep "SSTP"
```

### iOS Logs

View in Xcode Console or:

```bash
xcrun simctl spawn booted log stream --level debug
```

## Common Tasks

### Update Dependencies

```bash
flutter pub upgrade
```

### Clean Build

```bash
flutter clean
flutter pub get
```

### Format Code

```bash
flutter format .
```

### Analyze Code

```bash
flutter analyze
```

## Security Considerations

1. **Never log passwords:** Use logging service that filters sensitive data
2. **Use secure storage:** Always use flutter_secure_storage for credentials
3. **Validate input:** Check all user input before processing
4. **Handle permissions:** Request permissions at appropriate times
5. **Use HTTPS:** Always use secure connections for API calls

## Resources

- [Flutter Best Practices](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#best-practices)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)

## Getting Help

- Check existing code for examples
- Review Flutter documentation
- Ask questions in GitHub Issues
- Join Flutter Discord/Slack communities
