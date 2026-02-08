package com.alihusains.sstp_vpn

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetSocketAddress
import javax.net.ssl.SSLContext
import javax.net.ssl.SSLSocket
import java.nio.ByteBuffer

class SstpVpnService : VpnService() {
    
    companion object {
        const val ACTION_CONNECT = "com.alihusains.sstp_vpn.CONNECT"
        const val ACTION_DISCONNECT = "com.alihusains.sstp_vpn.DISCONNECT"
        const val NOTIFICATION_ID = 1
        const val CHANNEL_ID = "sstp_vpn_channel"
        
        var currentStatus = "disconnected"
        var statusCallback: ((String) -> Unit)? = null
        
        private fun updateStatus(status: String) {
            currentStatus = status
            statusCallback?.invoke(status)
        }
    }
    
    private var vpnInterface: ParcelFileDescriptor? = null
    private var sslSocket: SSLSocket? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> {
                val serverAddress = intent.getStringExtra("serverAddress") ?: return START_NOT_STICKY
                val port = intent.getIntExtra("port", 443)
                val username = intent.getStringExtra("username") ?: return START_NOT_STICKY
                val password = intent.getStringExtra("password") ?: return START_NOT_STICKY
                
                connect(serverAddress, port, username, password)
            }
            ACTION_DISCONNECT -> {
                disconnect()
            }
        }
        
        return START_STICKY
    }
    
    private fun connect(serverAddress: String, port: Int, username: String, password: String) {
        serviceScope.launch {
            try {
                updateStatus("connecting")
                createNotificationChannel()
                startForeground(NOTIFICATION_ID, createNotification("Connecting...", serverAddress))
                
                establishSstpConnection(serverAddress, port, username, password)
                
                updateStatus("connected")
                updateNotification("Connected", serverAddress)
            } catch (e: Exception) {
                e.printStackTrace()
                updateStatus("error")
                disconnect()
            }
        }
    }
    
    private fun establishSstpConnection(
        serverAddress: String,
        port: Int,
        username: String,
        password: String
    ) {
        val sslContext = SSLContext.getInstance("TLS")
        sslContext.init(null, null, null)
        
        val socketFactory = sslContext.socketFactory
        val socket = socketFactory.createSocket() as SSLSocket
        
        socket.connect(InetSocketAddress(serverAddress, port), 30000)
        socket.startHandshake()
        
        sslSocket = socket
        
        sendSstpControlPacket(socket, SSTP_MSG_CALL_CONNECT_REQUEST)
        
        val builder = Builder()
        builder.setSession("SSTP VPN")
        builder.addAddress("10.0.0.2", 24)
        builder.addRoute("0.0.0.0", 0)
        builder.addDnsServer("8.8.8.8")
        builder.addDnsServer("8.8.4.4")
        builder.setMtu(1400)
        
        vpnInterface = builder.establish()
        
        if (vpnInterface != null) {
            startPacketForwarding()
        } else {
            throw Exception("Failed to establish VPN interface")
        }
    }
    
    private fun sendSstpControlPacket(socket: SSLSocket, messageType: Byte) {
        val packet = ByteBuffer.allocate(8)
        packet.put(0x10.toByte())
        packet.put(0x01.toByte())
        packet.putShort(8)
        packet.putShort(messageType.toShort())
        packet.putShort(0)
        
        val outputStream = socket.outputStream
        outputStream.write(packet.array())
        outputStream.flush()
    }
    
    private fun startPacketForwarding() {
        serviceScope.launch {
            val vpnInput = FileInputStream(vpnInterface?.fileDescriptor)
            val vpnOutput = FileOutputStream(vpnInterface?.fileDescriptor)
            val sslInput = sslSocket?.inputStream
            val sslOutput = sslSocket?.outputStream
            
            if (sslInput == null || sslOutput == null) {
                return@launch
            }
            
            val vpnToSslJob = launch {
                try {
                    val buffer = ByteArray(32767)
                    while (isActive) {
                        val length = vpnInput.read(buffer)
                        if (length > 0) {
                            val sstpPacket = wrapInSstpPacket(buffer, length)
                            sslOutput.write(sstpPacket)
                            sslOutput.flush()
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            
            val sslToVpnJob = launch {
                try {
                    val buffer = ByteArray(32767)
                    while (isActive) {
                        val length = sslInput.read(buffer)
                        if (length > 0) {
                            val payload = extractSstpPayload(buffer, length)
                            if (payload != null) {
                                vpnOutput.write(payload)
                                vpnOutput.flush()
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            
            vpnToSslJob.join()
            sslToVpnJob.join()
        }
    }
    
    private fun wrapInSstpPacket(data: ByteArray, length: Int): ByteArray {
        val packet = ByteBuffer.allocate(length + 4)
        packet.put(0x10.toByte())
        packet.put(0x01.toByte())
        packet.putShort((length + 4).toShort())
        packet.put(data, 0, length)
        return packet.array()
    }
    
    private fun extractSstpPayload(data: ByteArray, length: Int): ByteArray? {
        if (length < 4) return null
        
        val buffer = ByteBuffer.wrap(data)
        val version = buffer.get()
        val reserved = buffer.get()
        val packetLength = buffer.short.toInt()
        
        if (version.toInt() != 0x10) return null
        
        val payloadLength = packetLength - 4
        if (payloadLength <= 0 || payloadLength > length - 4) return null
        
        val payload = ByteArray(payloadLength)
        buffer.get(payload)
        return payload
    }
    
    private fun disconnect() {
        serviceScope.launch {
            updateStatus("disconnecting")
            
            try {
                sslSocket?.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            try {
                vpnInterface?.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            vpnInterface = null
            sslSocket = null
            
            updateStatus("disconnected")
            stopForeground(true)
            stopSelf()
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN Connection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows VPN connection status"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(title: String, content: String): android.app.Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
    
    private fun updateNotification(title: String, content: String) {
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(NOTIFICATION_ID, createNotification(title, content))
    }
    
    override fun onDestroy() {
        serviceScope.cancel()
        disconnect()
        super.onDestroy()
    }
    
    companion object {
        private const val SSTP_MSG_CALL_CONNECT_REQUEST: Byte = 0x01
        private const val SSTP_MSG_CALL_CONNECT_ACK: Byte = 0x02
        private const val SSTP_MSG_CALL_CONNECTED: Byte = 0x04
        private const val SSTP_MSG_CALL_DISCONNECT: Byte = 0x05
    }
}
