package com.example.flutter_vless_vpn

import android.util.Log
import java.nio.ByteBuffer
import java.security.MessageDigest
import java.security.SecureRandom
import java.util.*
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import javax.net.ssl.SSLEngine
import javax.net.ssl.SSLEngineResult
import javax.net.ssl.SSLException

class VLESSProtocol {
    
    companion object {
        private const val TAG = "VLESSProtocol"
        
        // VLESS constants
        const val VLESS_VERSION = 0x00
        const val VLESS_CMD_TCP = 0x01
        const val VLESS_CMD_UDP = 0x02
        const val VLESS_ADDR_TYPE_IPV4 = 0x01
        const val VLESS_ADDR_TYPE_IPV6 = 0x02
        const val VLESS_ADDR_TYPE_DOMAIN = 0x03
        
        // Flow control
        const val FLOW_NONE = "none"
        const val FLOW_XTLS_RPRX_VISION = "xtls-rprx-vision"
        
        // Encryption types
        const val ENCRYPTION_NONE = "none"
        const val ENCRYPTION_ZERO = "zero"
    }
    
    data class VLESSConfig(
        val serverAddress: String,
        val serverPort: Int,
        val uuid: String,
        val publicKey: String,
        val shortId: String,
        val sni: String,
        val flow: String,
        val fingerprint: String,
        val encryption: String
    )
    
    private var config: VLESSConfig? = null
    private var sslEngine: SSLEngine? = null
    private var isHandshakeComplete = false
    private var clientRandom = ByteArray(32)
    private var serverRandom = ByteArray(32)
    
    fun initialize(config: VLESSConfig) {
        this.config = config
        this.isHandshakeComplete = false
        
        // Generate client random
        SecureRandom().nextBytes(clientRandom)
        
        Log.d(TAG, "VLESS protocol initialized with server: ${config.serverAddress}:${config.serverPort}")
    }
    
    fun buildVLESSHeader(destination: Destination): ByteArray {
        val config = this.config ?: throw IllegalStateException("VLESS not initialized")
        
        val header = mutableListOf<Byte>()
        
        // Version
        header.add(VLESS_VERSION.toByte())
        
        // Flow control
        val flowFlag = when (config.flow) {
            FLOW_XTLS_RPRX_VISION -> 0x08
            else -> 0x00
        }
        header.add(flowFlag.toByte())
        
        // UUID (16 bytes)
        val uuidBytes = parseUUID(config.uuid)
        header.addAll(uuidBytes)
        
        // Encryption method
        val encryptionFlag = when (config.encryption) {
            ENCRYPTION_NONE -> 0x00
            ENCRYPTION_ZERO -> 0x01
            else -> 0x00
        }
        header.add(encryptionFlag.toByte())
        
        // Address type and destination
        when (destination.type) {
            Destination.Type.IPv4 -> {
                header.add(VLESS_ADDR_TYPE_IPV4.toByte())
                header.addAll(destination.address.toByteArray())
            }
            Destination.Type.IPv6 -> {
                header.add(VLESS_ADDR_TYPE_IPV6.toByte())
                header.addAll(destination.address.toByteArray())
            }
            Destination.Type.Domain -> {
                header.add(VLESS_ADDR_TYPE_DOMAIN.toByte())
                header.add(destination.address.length.toByte())
                header.addAll(destination.address.toByteArray().toList())
            }
        }
        
        // Port
        val portBytes = ByteBuffer.allocate(2).putShort(destination.port.toShort()).array()
        header.addAll(portBytes.toList())
        
        // Add Reality header if configured
        if (config.publicKey.isNotEmpty() && config.shortId.isNotEmpty()) {
            buildRealityHeader(header)
        }
        
        return header.toByteArray()
    }
    
    private fun parseUUID(uuidString: String): List<Byte> {
        val cleanUUID = uuidString.replace("-", "")
        return cleanUUID.chunked(2).map { it.toInt(16).toByte() }
    }
    
    private fun buildRealityHeader(header: MutableList<Byte>) {
        val config = this.config ?: return
        
        // Reality header structure
        // Public Key (32 bytes)
        val publicKeyBytes = Base64.getUrlDecoder().decode(config.publicKey)
        header.addAll(publicKeyBytes.toList())
        
        // Short ID (8 bytes)
        val shortIdBytes = if (config.shortId.length == 16) {
            config.shortId.chunked(2).map { it.toInt(16).toByte() }
        } else {
            // Pad shortId to 8 bytes
            val padded = config.shortId.padEnd(16, '0').take(16)
            padded.chunked(2).map { it.toInt(16).toByte() }
        }
        header.addAll(shortIdBytes)
        
        // SNI length and data
        val sniBytes = config.sni.toByteArray()
        header.add(sniBytes.size.toByte())
        header.addAll(sniBytes.toList())
        
        // Fingerprint
        val fingerprintBytes = config.fingerprint.toByteArray()
        header.add(fingerprintBytes.size.toByte())
        header.addAll(fingerprintBytes.toList())
    }
    
    fun processHandshake(data: ByteBuffer): Boolean {
        try {
            if (sslEngine == null) {
                setupSSLEngine()
            }
            
            val result = sslEngine?.wrap(data, data)
            if (result != null && result.status == SSLEngineResult.Status.OK) {
                isHandshakeComplete = sslEngine?.handshakeStatus == SSLEngine.HandshakeStatus.FINISHED
                return isHandshakeComplete
            }
            
            return false
        } catch (e: SSLException) {
            Log.e(TAG, "SSL handshake error", e)
            return false
        }
    }
    
    private fun setupSSLEngine() {
        val config = this.config ?: return
        
        try {
            // Create SSL context for Reality
            sslEngine = SSLEngine()
            sslEngine?.useClientMode = true
            sslEngine?.enabledProtocols = arrayOf("TLSv1.3")
            sslEngine?.enabledCipherSuites = arrayOf(
                "TLS_AES_128_GCM_SHA256",
                "TLS_AES_256_GCM_SHA384"
            )
            
            // Set SNI
            if (config.sni.isNotEmpty()) {
                val sniHost = javax.net.ssl.SNIServerName(config.sni, config.sni.toByteArray())
                val params = sslEngine?.sslParameters
                params?.serverNames = listOf(sniHost)
                sslEngine?.sslParameters = params
            }
            
            // Set fingerprint
            if (config.fingerprint.isNotEmpty()) {
                val params = sslEngine?.sslParameters
                // Note: Fingerprint validation would be implemented here
                // This is a simplified version
                sslEngine?.sslParameters = params
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error setting up SSL engine", e)
        }
    }
    
    fun encryptData(data: ByteBuffer): ByteBuffer? {
        val config = this.config ?: return null
        
        return when (config.encryption) {
            ENCRYPTION_NONE -> data
            ENCRYPTION_ZERO -> {
                // Zero encryption - just pass through
                data
            }
            else -> data
        }
    }
    
    fun decryptData(data: ByteBuffer): ByteBuffer? {
        val config = this.config ?: return null
        
        return when (config.encryption) {
            ENCRYPTION_NONE -> data
            ENCRYPTION_ZERO -> {
                // Zero encryption - just pass through
                data
            }
            else -> data
        }
    }
    
    fun isHandshakeComplete(): Boolean = isHandshakeComplete
    
    fun close() {
        try {
            sslEngine?.closeOutbound()
            sslEngine?.closeInbound()
        } catch (e: Exception) {
            Log.e(TAG, "Error closing SSL engine", e)
        }
    }
    
    data class Destination(
        val type: Type,
        val address: String,
        val port: Int
    ) {
        enum class Type {
            IPv4, IPv6, Domain
        }
    }
    
    fun parseDestination(packet: ByteBuffer): Destination? {
        try {
            packet.position(0)
            val version = packet.get().toInt() shr 4
            
            return when (version) {
                4 -> {
                    // IPv4
                    packet.position(12) // Skip to source IP
                    val srcBytes = ByteArray(4)
                    packet.get(srcBytes)
                    
                    packet.position(16) // Skip to destination IP
                    val dstBytes = ByteArray(4)
                    packet.get(dstBytes)
                    
                    packet.position(0) // Reset for port parsing
                    packet.position(20) // Skip to source port
                    val srcPort = packet.short.toInt() and 0xFFFF
                    val dstPort = packet.short.toInt() and 0xFFFF
                    
                    Destination(
                        Destination.Type.IPv4,
                        dstBytes.joinToString("."),
                        dstPort
                    )
                }
                6 -> {
                    // IPv6 - simplified
                    Destination(
                        Destination.Type.IPv6,
                        "IPv6", // Full parsing would be more complex
                        0
                    )
                }
                else -> null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing destination", e)
            return null
        }
    }
    
    fun calculateChecksum(data: ByteArray): ByteArray {
        val md5 = MessageDigest.getInstance("MD5")
        return md5.digest(data)
    }
    
    fun validateChecksum(data: ByteArray, expectedChecksum: ByteArray): Boolean {
        val calculated = calculateChecksum(data)
        return calculated.contentEquals(expectedChecksum)
    }
}