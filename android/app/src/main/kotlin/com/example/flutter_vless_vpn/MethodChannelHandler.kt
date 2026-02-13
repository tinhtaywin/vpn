package com.example.flutter_vless_vpn

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.VpnService
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap

class MethodChannelHandler : FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "MethodChannelHandler"
        private const val CHANNEL_NAME = "com.example.flutter_vless_vpn/vpn_service"
        private const val EVENT_CHANNEL_NAME = "com.example.flutter_vless_vpn/vpn_events"
        private const val VPN_REQUEST_CODE = 1001
    }
    
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: Activity? = null
    private var context: Context? = null
    
    // VPN Service reference
    private var vpnService: VLESSVpnService? = null
    
    // Event channel sink for streaming events
    private var eventSink: EventChannel.EventSink? = null
    
    // Broadcast receiver for VPN status updates
    private val vpnStatusReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.let { handleVpnStatusUpdate(it) }
        }
    }
    
    // Traffic update receiver
    private val trafficUpdateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.let { handleTrafficUpdate(it) }
        }
    }
    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
        
        context = flutterPluginBinding.applicationContext
        registerReceivers()
        
        Log.d(TAG, "Method channel handler attached")
    }
    
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        unregisterReceivers()
        
        context = null
        Log.d(TAG, "Method channel handler detached")
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(TAG, "Attached to activity: ${binding.activity.javaClass.simpleName}")
    }
    
    override fun onDetachedFromActivity() {
        activity = null
        Log.d(TAG, "Detached from activity")
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        Log.d(TAG, "Detached from activity for config changes")
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(TAG, "Reattached to activity for config changes")
    }
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "requestVpnPermission" -> {
                requestVpnPermission(result)
            }
            "connectVpn" -> {
                val config = parseVpnConfig(call)
                connectVpn(config, result)
            }
            "disconnectVpn" -> {
                disconnectVpn(result)
            }
            "getVpnStatus" -> {
                getVpnStatus(result)
            }
            "updateVpnConfig" -> {
                val config = parseVpnConfig(call)
                updateVpnConfig(config, result)
            }
            "setAllowedApps" -> {
                val allowedApps = call.argument<List<String>>("allowed_apps") ?: emptyList()
                setAllowedApps(allowedApps, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun requestVpnPermission(result: Result) {
        try {
            val activity = activity ?: throw IllegalStateException("Activity not available")
            val intent = VpnService.prepare(activity)
            
            if (intent != null) {
                // VPN permission not granted, request it
                activity.startActivityForResult(intent, VPN_REQUEST_CODE)
                result.success(false)
            } else {
                // VPN permission already granted
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting VPN permission", e)
            result.error("VPN_PERMISSION_ERROR", e.message, null)
        }
    }
    
    private fun connectVpn(config: VLESSVpnService.VLESSConfig, result: Result) {
        try {
            val context = context ?: throw IllegalStateException("Context not available")
            
            // Create intent to start VPN service
            val intent = Intent(context, VLESSVpnService::class.java)
            intent.action = "start"
            intent.putExtra("server_address", config.serverAddress)
            intent.putExtra("server_port", config.serverPort)
            intent.putExtra("uuid", config.uuid)
            intent.putExtra("public_key", config.publicKey)
            intent.putExtra("short_id", config.shortId)
            intent.putExtra("sni", config.sni)
            intent.putExtra("flow", config.flow)
            intent.putExtra("fingerprint", config.fingerprint)
            
            // Start service
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
            
            result.success(true)
            Log.d(TAG, "VPN connection requested")
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting VPN", e)
            result.error("VPN_CONNECT_ERROR", e.message, null)
        }
    }
    
    private fun disconnectVpn(result: Result) {
        try {
            val context = context ?: throw IllegalStateException("Context not available")
            
            val intent = Intent(context, VLESSVpnService::class.java)
            intent.action = "stop"
            
            context.startService(intent)
            result.success(true)
            Log.d(TAG, "VPN disconnection requested")
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting VPN", e)
            result.error("VPN_DISCONNECT_ERROR", e.message, null)
        }
    }
    
    private fun getVpnStatus(result: Result) {
        try {
            // For now, return basic status
            // In a real implementation, you'd query the VPN service
            val status = mapOf(
                "connected" to false,
                "server" to "",
                "upload" to 0L,
                "download" to 0L
            )
            result.success(status)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting VPN status", e)
            result.error("VPN_STATUS_ERROR", e.message, null)
        }
    }
    
    private fun updateVpnConfig(config: VLESSVpnService.VLESSConfig, result: Result) {
        try {
            // Update configuration
            // In a real implementation, you'd update the running VPN service
            result.success(true)
            Log.d(TAG, "VPN configuration updated")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating VPN config", e)
            result.error("VPN_CONFIG_ERROR", e.message, null)
        }
    }
    
    private fun setAllowedApps(allowedApps: List<String>, result: Result) {
        try {
            // Update allowed apps list
            // In a real implementation, you'd update the running VPN service
            result.success(true)
            Log.d(TAG, "Allowed apps updated: ${allowedApps.size} apps")
        } catch (e: Exception) {
            Log.e(TAG, "Error setting allowed apps", e)
            result.error("VPN_APPS_ERROR", e.message, null)
        }
    }
    
    private fun parseVpnConfig(call: MethodCall): VLESSVpnService.VLESSConfig {
        val serverAddress = call.argument<String>("server_address") ?: ""
        val serverPort = call.argument<Int>("server_port") ?: 443
        val uuid = call.argument<String>("uuid") ?: ""
        val publicKey = call.argument<String>("public_key") ?: ""
        val shortId = call.argument<String>("short_id") ?: ""
        val sni = call.argument<String>("sni") ?: ""
        val flow = call.argument<String>("flow") ?: "none"
        val fingerprint = call.argument<String>("fingerprint") ?: "chrome"
        val encryption = call.argument<String>("encryption") ?: "none"
        
        return VLESSVpnService.VLESSConfig(
            serverAddress = serverAddress,
            serverPort = serverPort,
            uuid = uuid,
            publicKey = publicKey,
            shortId = shortId,
            sni = sni,
            flow = flow,
            fingerprint = fingerprint,
            encryption = encryption
        )
    }
    
    // Event channel implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "Event channel listener attached")
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d(TAG, "Event channel listener cancelled")
    }
    
    private fun registerReceivers() {
        context?.let { ctx ->
            try {
                ctx.registerReceiver(vpnStatusReceiver, IntentFilter("com.example.flutter_vless_vpn.VPN_STATUS"))
                ctx.registerReceiver(trafficUpdateReceiver, IntentFilter("com.example.flutter_vless_vpn.TRAFFIC_UPDATE"))
                Log.d(TAG, "Broadcast receivers registered")
            } catch (e: Exception) {
                Log.e(TAG, "Error registering receivers", e)
            }
        }
    }
    
    private fun unregisterReceivers() {
        context?.let { ctx ->
            try {
                ctx.unregisterReceiver(vpnStatusReceiver)
                ctx.unregisterReceiver(trafficUpdateReceiver)
                Log.d(TAG, "Broadcast receivers unregistered")
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering receivers", e)
            }
        }
    }
    
    private fun handleVpnStatusUpdate(intent: Intent) {
        val status = intent.getStringExtra("status") ?: "unknown"
        val message = intent.getStringExtra("message") ?: ""
        
        val event = mapOf(
            "type" to "status_update",
            "status" to status,
            "message" to message
        )
        
        eventSink?.success(event)
        Log.d(TAG, "VPN status update: $status - $message")
    }
    
    private fun handleTrafficUpdate(intent: Intent) {
        val upload = intent.getLongExtra("upload", 0L)
        val download = intent.getLongExtra("download", 0L)
        
        val event = mapOf(
            "type" to "traffic_update",
            "upload" to upload,
            "download" to download
        )
        
        eventSink?.success(event)
        Log.d(TAG, "Traffic update: upload=$upload, download=$download")
    }
    
    // Helper method to send events to Flutter
    fun sendEvent(eventType: String, data: Map<String, Any>) {
        val event = mapOf(
            "type" to eventType,
            "data" to data
        )
        eventSink?.success(event)
    }
}