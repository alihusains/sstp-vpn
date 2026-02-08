import Foundation
import Flutter
import NetworkExtension

class SstpVpnManager: NSObject {
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    private var vpnManager: NEVPNManager?
    private var currentStatus = "disconnected"
    
    init(messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.alihusains.sstp_vpn/vpn",
            binaryMessenger: messenger
        )
        
        eventChannel = FlutterEventChannel(
            name: "com.alihusains.sstp_vpn/status",
            binaryMessenger: messenger
        )
        
        super.init()
        
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
        
        eventChannel.setStreamHandler(self)
        
        setupVpnManager()
        observeVpnStatus()
    }
    
    private func setupVpnManager() {
        vpnManager = NEVPNManager.shared()
        vpnManager?.loadFromPreferences { [weak self] error in
            if let error = error {
                print("Error loading VPN preferences: \(error.localizedDescription)")
            }
        }
    }
    
    private func observeVpnStatus() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusDidChange),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }
    
    @objc private func vpnStatusDidChange() {
        guard let status = vpnManager?.connection.status else { return }
        
        let statusString: String
        switch status {
        case .connecting:
            statusString = "connecting"
        case .connected:
            statusString = "connected"
        case .disconnecting:
            statusString = "disconnecting"
        case .disconnected:
            statusString = "disconnected"
        case .invalid, .reasserting:
            statusString = "error"
        @unknown default:
            statusString = "error"
        }
        
        currentStatus = statusString
        eventSink?(statusString)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermission":
            result(true)
            
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
            
        case "disconnect":
            disconnect(result: result)
            
        case "getStatus":
            result(currentStatus)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func connect(serverAddress: String,
                        port: Int,
                        username: String,
                        password: String,
                        result: @escaping FlutterResult) {
        guard let vpnManager = vpnManager else {
            result(FlutterError(code: "VPN_ERROR",
                              message: "VPN Manager not initialized",
                              details: nil))
            return
        }
        
        vpnManager.loadFromPreferences { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                result(FlutterError(code: "VPN_ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }
            
            let protocol = NEVPNProtocolIKEv2()
            protocol.serverAddress = serverAddress
            protocol.remoteIdentifier = serverAddress
            protocol.localIdentifier = username
            protocol.username = username
            protocol.passwordReference = self.savePasswordToKeychain(password: password, username: username)
            protocol.authenticationMethod = .none
            protocol.useExtendedAuthentication = true
            protocol.disconnectOnSleep = false
            
            vpnManager.protocolConfiguration = protocol
            vpnManager.localizedDescription = "SSTP VPN"
            vpnManager.isEnabled = true
            
            vpnManager.saveToPreferences { error in
                if let error = error {
                    result(FlutterError(code: "VPN_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                    return
                }
                
                vpnManager.loadFromPreferences { error in
                    if let error = error {
                        result(FlutterError(code: "VPN_ERROR",
                                          message: error.localizedDescription,
                                          details: nil))
                        return
                    }
                    
                    do {
                        try vpnManager.connection.startVPNTunnel()
                        result(true)
                    } catch {
                        result(FlutterError(code: "VPN_ERROR",
                                          message: error.localizedDescription,
                                          details: nil))
                    }
                }
            }
        }
    }
    
    private func disconnect(result: @escaping FlutterResult) {
        guard let vpnManager = vpnManager else {
            result(FlutterError(code: "VPN_ERROR",
                              message: "VPN Manager not initialized",
                              details: nil))
            return
        }
        
        vpnManager.connection.stopVPNTunnel()
        result(true)
    }
    
    private func savePasswordToKeychain(password: String, username: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: "com.alihusains.sstp_vpn",
            kSecValueData as String: password.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            let searchQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: username,
                kSecAttrService as String: "com.alihusains.sstp_vpn",
                kSecReturnPersistentRef as String: true
            ]
            
            var ref: AnyObject?
            SecItemCopyMatching(searchQuery as CFDictionary, &ref)
            return ref as? Data
        }
        
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SstpVpnManager: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        events(currentStatus)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
