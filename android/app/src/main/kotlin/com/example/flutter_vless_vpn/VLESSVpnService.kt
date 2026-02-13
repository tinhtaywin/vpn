package com.example.flutter_vless_vpn

import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.annotation.RequiresApi
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.DatagramChannel
import java.nio.channels.SocketChannel
import java.util.concurrent.ConcurrentHashMap

class VLESSVpnService : VpnService() {
    
    companion object {
        private const val TAG = "VLESSVpnService"
        private const val VPN_INTERFACE_NAME = "vless0"
        private const val VPN_INTERFACE_ADDRESS = "10.0.0.1"
        private const val VPN_INTERFACE_PREFIX_LENGTH = 24
        private const val VPN_INTERFACE_MTU = 1500
        
        // Protocol constants
        private const val VLESS_VERSION = 0x00
        private const val VLESS_CMD_TCP = 0x01
        private const val VLESS_CMD_UDP = 0x02
        private const val VLESS_ADDR_TYPE_IPV4 = 0x01
        private const val VLESS_ADDR_TYPE_IPV6 = 0x02
        private const val VLESS_ADDR_TYPE_DOMAIN = 0x03
    }
    
    private var vpnInterface: ParcelFileDescriptor? = null
    private var isRunning = false
    private var job: Job? = null
    
    // Configuration
    private var serverAddress = ""
    private var serverPort = 0
    private var uuid = ""
    private var publicKey = ""
    private var shortId = ""
    private var sni = ""
    private var flow = ""
    private var fingerprint = ""
    private var allowedApps = ConcurrentHashMap<String, Boolean>()
    
    // Statistics
    private var uploadBytes = 0L
    private var downloadBytes = 0L
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "VLESS VPN Service created")
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            return START_NOT_STICKY
        }
        
        when (intent.action) {
            "start" -> {
                serverAddress = intent.getStringExtra("server_address") ?: ""
                serverPort = intent.getIntExtra("server_port", 0)
                uuid = intent.getStringExtra("uuid") ?: ""
                publicKey = intent.getStringExtra("public_key") ?: ""
                shortId = intent.getStringExtra("short_id") ?: ""
                sni = intent.getStringExtra("sni") ?: ""
                flow = intent.getStringExtra("flow") ?: ""
                fingerprint = intent.getStringExtra("fingerprint") ?: ""
                
                // Parse allowed apps
                val allowedAppsJson = intent.getStringExtra("allowed_apps") ?: "{}"
                // Parse JSON to ConcurrentHashMap (simplified for now)
                
                startVpn()
            }
            "stop" -> {
                stopVpn()
            }
        }
        
        return START_STICKY
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
        Log.d(TAG, "VLESS VPN Service destroyed")
    }
    
    private fun startVpn() {
        if (isRunning) return
        
        try {
            // Create VPN interface
            val builder = Builder()
            builder.setSession("VLESS VPN")
            builder.setConfigureIntent(null)
            
            // Set VPN interface configuration
            builder.addAddress(VPN_INTERFACE_ADDRESS, VPN_INTERFACE_PREFIX_LENGTH)
            builder.addRoute("0.0.0.0", 0) // Route all traffic
            builder.addDnsServer("8.8.8.8")
            builder.addDnsServer("8.8.4.4")
            builder.setMtu(VPN_INTERFACE_MTU)
            
            // Set allowed apps (split tunneling)
            updateAllowedApps(builder)
            
            vpnInterface = builder.establish()
            
            if (vpnInterface != null) {
                isRunning = true
                startForegroundService()
                startPacketProcessor()
                sendStatusUpdate("connected")
                Log.d(TAG, "VPN started successfully")
            } else {
                sendStatusUpdate("error", "Failed to establish VPN interface")
                Log.e(TAG, "Failed to establish VPN interface")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting VPN", e)
            sendStatusUpdate("error", e.message ?: "Unknown error")
        }
    }
    
    private fun stopVpn() {
        if (!isRunning) return
        
        isRunning = false
        job?.cancel()
        job = null
        
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e(TAG, "Error closing VPN interface", e)
        }
        
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        sendStatusUpdate("disconnected")
        Log.d(TAG, "VPN stopped")
    }
    
    private fun startForegroundService() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, 
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        val notification = androidx.core.app.NotificationCompat.Builder(this, "vpn_channel")
            .setContentTitle("VLESS VPN")
            .setContentText("VPN is active")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(1, notification, FOREGROUND_SERVICE_TYPE_VPN)
        } else {
            startForeground(1, notification)
        }
    }
    
    private fun updateAllowedApps(builder: Builder) {
        // Add all apps to allowed list by default (for now)
        // In a real implementation, you'd check the allowedApps map
        try {
            val packages = packageManager.getInstalledApplications(0)
            for (app in packages) {
                if (app.packageName != packageName) { // Don't route our own traffic
                    builder.addAllowedApplication(app.packageName)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting installed apps", e)
        }
    }
    
    private fun startPacketProcessor() {
        job = CoroutineScope(Dispatchers.IO).launch {
            try {
                val vpnInput = FileInputStream(vpnInterface!!.fileDescriptor)
                val vpnOutput = FileOutputStream(vpnInterface!!.fileDescriptor)
                
                val buffer = ByteBuffer.allocate(VPN_INTERFACE_MTU)
                
                while (isRunning) {
                    try {
                        // Read packet from VPN interface
                        val readBytes = vpnInput.read(buffer.array())
                        if (readBytes > 0) {
                            buffer.clear()
                            buffer.limit(readBytes)
                            
                            // Process packet
                            processPacket(buffer, vpnOutput)
                            
                            // Update statistics
                            uploadBytes += readBytes
                            sendTrafficUpdate(uploadBytes, downloadBytes)
                        }
                    } catch (e: Exception) {
                        if (isRunning) {
                            Log.e(TAG, "Error processing packet", e)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in packet processor", e)
                sendStatusUpdate("error", e.message ?: "Packet processor error")
            }
        }
    }
    
    private suspend fun processPacket(packet: ByteBuffer, vpnOutput: FileOutputStream) {
        try {
            // For now, implement a simple TCP tunnel
            // In a full implementation, this would handle VLESS protocol
            
            val destination = getDestinationAddress(packet)
            if (destination != null) {
                // Create connection to destination
                val socketChannel = SocketChannel.open()
                socketChannel.connect(InetSocketAddress(serverAddress, serverPort))
                
                // Send VLESS header
                sendVLESSHeader(socketChannel, destination)
                
                // Forward packet
                socketChannel.write(packet)
                
                // Read response
                val responseBuffer = ByteBuffer.allocate(VPN_INTERFACE_MTU)
                val bytesRead = socketChannel.read(responseBuffer)
                if (bytesRead > 0) {
                    responseBuffer.flip()
                    vpnOutput.write(responseBuffer.array(), 0, bytesRead)
                    downloadBytes += bytesRead
                }
                
                socketChannel.close()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing packet", e)
        }
    }
    
    private fun sendVLESSHeader(socketChannel: SocketChannel, destination: String) {
        try {
            val header = buildVLESSHeader(destination)
            socketChannel.write(ByteBuffer.wrap(header))
        } catch (e: Exception) {
            Log.e(TAG, "Error sending VLESS header", e)
        }
    }
    
    private fun buildVLESSHeader(destination: String): ByteArray {
        // Simplified VLESS header construction
        // In a real implementation, this would include proper UUID, encryption, etc.
        
        val header = mutableListOf<Byte>()
        
        // Version
        header.add(VLESS_VERSION.toByte())
        
        // Command (TCP)
        header.add(VLESS_CMD_TCP.toByte())
        
        // UUID (simplified)
        val uuidBytes = uuid.replace("-", "").chunked(2).map { it.toInt(16).toByte() }
        header.addAll(uuidBytes)
        
        // Address type and destination
        header.add(VLESS_ADDR_TYPE_DOMAIN.toByte())
        header.add(destination.length.toByte())
        header.addAll(destination.toByteArray().toList())
        
        return header.toByteArray()
    }
    
    private fun getDestinationAddress(packet: ByteBuffer): String? {
        // Simplified IP packet parsing
        // In a real implementation, you'd properly parse IP headers
        
        try {
            packet.position(0)
            val version = packet.get().toInt() shr 4
            if (version == 4) {
                packet.position(16) // Skip to destination IP
                val ipBytes = ByteArray(4)
                packet.get(ipBytes)
                return ipBytes.joinToString(".")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing packet", e)
        }
        
        return null
    }
    
    private fun sendStatusUpdate(status: String, message: String = "") {
        val intent = Intent("com.example.flutter_vless_vpn.VPN_STATUS")
        intent.putExtra("status", status)
        intent.putExtra("message", message)
        sendBroadcast(intent)
    }
    
    private fun sendTrafficUpdate(upload: Long, download: Long) {
        val intent = Intent("com.example.flutter_vless_vpn.TRAFFIC_UPDATE")
        intent.putExtra("upload", upload)
        intent.putExtra("download", download)
        sendBroadcast(intent)
    }
}