package com.example.flutter_vless_vpn

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "com.example.flutter_vless_vpn/vpn_service"
    private val EVENT_CHANNEL = "com.example.flutter_vless_vpn/vpn_events"
    
    private var methodChannelHandler: MethodChannelHandler? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize method channel handler
        methodChannelHandler = MethodChannelHandler()
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel
        methodChannelHandler?.onAttachedToEngine(
            flutterEngine.pluginRegistry.flutterEngine.plugins
        )
    }
    
    override fun onDestroy() {
        super.onDestroy()
        
        // Clean up method channel handler
        methodChannelHandler?.onDetachedFromEngine(
            flutterEngine?.pluginRegistry?.flutterEngine?.plugins ?: return
        )
        methodChannelHandler = null
    }
}
