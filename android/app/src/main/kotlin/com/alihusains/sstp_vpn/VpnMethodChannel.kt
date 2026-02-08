package com.alihusains.sstp_vpn

import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class VpnMethodChannel(
    private val context: Context,
    messenger: BinaryMessenger
) {
    private val eventChannel = EventChannel(messenger, "com.alihusains.sstp_vpn/status")
    private var eventSink: EventChannel.EventSink? = null
    
    init {
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
    }

    fun connect(
        serverAddress: String,
        port: Int,
        username: String,
        password: String,
        result: MethodChannel.Result
    ) {
        val intent = Intent(context, SstpVpnService::class.java).apply {
            action = SstpVpnService.ACTION_CONNECT
            putExtra("serverAddress", serverAddress)
            putExtra("port", port)
            putExtra("username", username)
            putExtra("password", password)
        }
        
        context.startService(intent)
        result.success(true)
    }

    fun disconnect(result: MethodChannel.Result) {
        val intent = Intent(context, SstpVpnService::class.java).apply {
            action = SstpVpnService.ACTION_DISCONNECT
        }
        
        context.startService(intent)
        result.success(true)
    }

    fun getStatus(result: MethodChannel.Result) {
        result.success(SstpVpnService.currentStatus)
    }
}
