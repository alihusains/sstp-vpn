# API Documentation - SSTP VPN

## Flutter-Native Platform Channels

### Overview

The app communicates between Flutter (Dart) and native platforms (Android/iOS) using platform channels.

**Channel Name:** `com.alihusains.sstp_vpn/vpn`
**Event Channel:** `com.alihusains.sstp_vpn/status`

## Method Calls

### 1. Request Permission

**Method:** `requestPermission`
**Platform:** Android, iOS
**Purpose:** Requests VPN permission from the user

**Flutter Call:**
```dart
final result = await _channel.invokeMethod('requestPermission');
```

**Parameters:** None

**Returns:** `bool`
- `true` - Permission granted
- `false` - Permission denied

**Android Implementation:**
```kotlin
private fun requestVpnPermission(result: MethodChannel.Result) {
    val intent = VpnService.prepare(this)
    if (intent != null) {
        startActivityForResult(intent, VPN_REQUEST_CODE)
    } else {
        result.success(true)
    }
}
```

**iOS Implementation:**
```swift
case "requestPermission":
    result(true) // iOS handles permission internally
```

---

### 2. Connect to VPN

**Method:** `connect`
**Platform:** Android, iOS
**Purpose:** Establishes VPN connection to specified server

**Flutter Call:**
```dart
final result = await _channel.invokeMethod('connect', {
  'serverAddress': 'vpn.example.com',
  'port': 443,
  'username': 'user',
  'password': 'pass'
});
```

**Parameters:**
- `serverAddress` (String) - SSTP server hostname or IP
- `port` (int) - Server port (typically 443)
- `username` (String) - VPN username
- `password` (String) - VPN password

**Returns:** `bool`
- `true` - Connection initiated successfully
- `false` - Connection failed

**Errors:**
- `INVALID_ARGUMENTS` - Missing required parameters
- `VPN_ERROR` - Connection error with message

**Android Implementation:**
```kotlin
"connect" -> {
    val serverAddress = call.argument<String>("serverAddress")
    val port = call.argument<Int>("port")
    val username = call.argument<String>("username")
    val password = call.argument<String>("password")
    
    vpnMethodChannel?.connect(serverAddress, port, username, password, result)
}
```

**iOS Implementation:**
```swift
case "connect":
    guard let args = call.arguments as? [String: Any],
          let serverAddress = args["serverAddress"] as? String,
          let port = args["port"] as? Int,
          let username = args["username"] as? String,
          let password = args["password"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", 
                          message: "Missing required arguments",
                          details: nil))
        return
    }
    
    connect(serverAddress: serverAddress,
           port: port,
           username: username,
           password: password,
           result: result)
```

---

### 3. Disconnect from VPN

**Method:** `disconnect`
**Platform:** Android, iOS
**Purpose:** Closes VPN connection

**Flutter Call:**
```dart
final result = await _channel.invokeMethod('disconnect');
```

**Parameters:** None

**Returns:** `bool`
- `true` - Disconnection initiated successfully
- `false` - Disconnection failed

**Android Implementation:**
```kotlin
"disconnect" -> {
    vpnMethodChannel?.disconnect(result)
}
```

**iOS Implementation:**
```swift
case "disconnect":
    disconnect(result: result)
```

---

### 4. Get VPN Status

**Method:** `getStatus`
**Platform:** Android, iOS
**Purpose:** Retrieves current VPN connection status

**Flutter Call:**
```dart
final status = await _channel.invokeMethod('getStatus');
```

**Parameters:** None

**Returns:** `String` - One of:
- `"disconnected"` - Not connected
- `"connecting"` - Connection in progress
- `"connected"` - Successfully connected
- `"disconnecting"` - Disconnection in progress
- `"error"` - Error state

**Android Implementation:**
```kotlin
"getStatus" -> {
    result.success(SstpVpnService.currentStatus)
}
```

**iOS Implementation:**
```swift
case "getStatus":
    result(currentStatus)
```

---

## Event Streams

### VPN Status Stream

**Channel:** `com.alihusains.sstp_vpn/status`
**Type:** EventChannel
**Purpose:** Real-time VPN status updates

**Flutter Subscription:**
```dart
_vpnService.statusStream.listen((status) {
  print('Status changed: $status');
});
```

**Events:** `String` - Same values as `getStatus` method

**Android Implementation:**
```kotlin
eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        SstpVpnService.statusCallback = { status ->
            eventSink?.success(status)
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        SstpVpnService.statusCallback = null
    }
})
```

**iOS Implementation:**
```swift
extension SstpVpnManager: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, 
                 eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        events(currentStatus)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
```

---

## REST API Integration

### IP Information API

**Provider:** freeipapi.com
**Base URL:** `https://free.freeipapi.com/api/json`
**Method:** GET
**Authentication:** None required

#### Get Current IP Information

**Endpoint:** `/api/json`

**Example Request:**
```dart
final response = await http.get(
  Uri.parse('https://free.freeipapi.com/api/json')
);
```

**Response:** JSON Object

```json
{
  "ipAddress": "123.45.67.89",
  "countryName": "United States",
  "cityName": "New York",
  "regionName": "New York",
  "asnOrganization": "Example ISP Inc.",
  "isProxy": false,
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

**Flutter Model:**
```dart
class IpInfo {
  final String ipAddress;
  final String countryName;
  final String cityName;
  final String regionName;
  final String asnOrganization;
  final bool isProxy;
  final double? latitude;
  final double? longitude;

  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ipAddress: json['ipAddress'] ?? '',
      countryName: json['countryName'] ?? 'Unknown',
      cityName: json['cityName'] ?? 'Unknown',
      regionName: json['regionName'] ?? 'Unknown',
      asnOrganization: json['asnOrganization'] ?? 'Unknown',
      isProxy: json['isProxy'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}
```

**Rate Limits:** None specified (free tier)
**Timeout:** 10 seconds recommended

---

## Local Storage APIs

### Secure Storage (Credentials)

**Package:** `flutter_secure_storage`
**Platform:** Android (EncryptedSharedPreferences), iOS (Keychain)

#### Store Credential
```dart
await _secureStorage.write(key: 'password', value: password);
```

#### Read Credential
```dart
final password = await _secureStorage.read(key: 'password');
```

#### Delete Credential
```dart
await _secureStorage.delete(key: 'password');
```

#### Clear All
```dart
await _secureStorage.deleteAll();
```

---

### Shared Preferences (Settings)

**Package:** `shared_preferences`

#### Store Setting
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('auto_reconnect', true);
await prefs.setString('server_id', '123');
await prefs.setInt('connection_count', 5);
```

#### Read Setting
```dart
final prefs = await SharedPreferences.getInstance();
final autoReconnect = prefs.getBool('auto_reconnect') ?? false;
final serverId = prefs.getString('server_id');
final count = prefs.getInt('connection_count') ?? 0;
```

#### Remove Setting
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('auto_reconnect');
```

---

## Data Models

### VpnServer

```dart
class VpnServer {
  final String id;
  final String name;
  final String serverAddress;
  final int port;
  final String username;
  final String password;
  
  VpnServer({
    required this.id,
    required this.name,
    required this.serverAddress,
    required this.port,
    required this.username,
    required this.password,
  });
  
  factory VpnServer.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### VpnStatus (Enum)

```dart
enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error
}
```

### IpInfo

```dart
class IpInfo {
  final String ipAddress;
  final String countryName;
  final String cityName;
  final String regionName;
  final String asnOrganization;
  final bool isProxy;
  final double? latitude;
  final double? longitude;
}
```

### ConnectionConfig

```dart
class ConnectionConfig {
  final VpnServer server;
  final Duration timeout;
  final bool autoReconnect;
  
  ConnectionConfig({
    required this.server,
    this.timeout = const Duration(seconds: 30),
    this.autoReconnect = false,
  });
}
```

---

## Error Codes

### Platform Errors

| Code | Description | Platform |
|------|-------------|----------|
| `INVALID_ARGUMENTS` | Missing or invalid method arguments | Android, iOS |
| `VPN_ERROR` | VPN operation failed | Android, iOS |
| `PERMISSION_DENIED` | User denied VPN permission | Android |
| `NETWORK_ERROR` | Network connection failed | Android, iOS |

### HTTP Errors

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 404 | Not Found |
| 429 | Too Many Requests (Rate Limit) |
| 500 | Server Error |
| 503 | Service Unavailable |

---

## Testing APIs

### Mock VPN Service

For testing without actual VPN connection:

```dart
class MockVpnService extends VpnService {
  @override
  Future<bool> connect(VpnServer server) async {
    await Future.delayed(Duration(seconds: 2));
    return true;
  }
  
  @override
  Future<bool> disconnect() async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
  
  @override
  Future<VpnStatus> getStatus() async {
    return VpnStatus.disconnected;
  }
}
```

### Mock IP API

```dart
class MockIpApiService extends IpApiService {
  @override
  Future<IpInfo?> fetchIpInfo() async {
    await Future.delayed(Duration(seconds: 1));
    return IpInfo(
      ipAddress: '192.168.1.1',
      countryName: 'Test Country',
      cityName: 'Test City',
      regionName: 'Test Region',
      asnOrganization: 'Test ISP',
      isProxy: false,
      latitude: 0.0,
      longitude: 0.0,
    );
  }
}
```

---

## Best Practices

1. **Always handle errors** - Wrap API calls in try-catch blocks
2. **Implement timeouts** - Prevent indefinite waiting
3. **Validate inputs** - Check parameters before sending to native
4. **Log appropriately** - Never log passwords or sensitive data
5. **Handle edge cases** - Network loss, permission denial, etc.
6. **Use secure storage** - For all credentials and sensitive data

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-02-08 | Initial API documentation |

---

For implementation examples, see the source code in:
- `lib/services/vpn_service.dart`
- `lib/services/ip_api_service.dart`
- `lib/services/storage_service.dart`
- `android/app/src/main/kotlin/com/alihusains/sstp_vpn/`
- `ios/Runner/SstpVpnManager.swift`
