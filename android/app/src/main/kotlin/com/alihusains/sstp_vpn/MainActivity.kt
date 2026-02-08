package com.alihusains.sstp_vpn

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.Intent
import android.net.VpnService
import android.app.Activity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.alihusains.sstp_vpn/vpn"
    private val EVENT_CHANNEL = "com.alihusains.sstp_vpn/status"
    private val VPN_REQUEST_CODE = 24
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var pendingResult: MethodChannel.Result? = null
    private var vpnMethodChannel: VpnMethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        vpnMethodChannel = VpnMethodChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    requestVpnPermission(result)
                }
                "connect" -> {
                    val serverAddress = call.argument<String>("serverAddress")
                    val port = call.argument<Int>("port")
                    val username = call.argument<String>("username")
                    val password = call.argument<String>("password")
                    
                    if (serverAddress != null && port != null && username != null && password != null) {
                        vpnMethodChannel?.connect(serverAddress, port, username, password, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                "disconnect" -> {
                    vpnMethodChannel?.disconnect(result)
                }
                "getStatus" -> {
                    vpnMethodChannel?.getStatus(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestVpnPermission(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            pendingResult = result
            startActivityForResult(intent, VPN_REQUEST_CODE)
        } else {
            result.success(true)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == VPN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }
}
