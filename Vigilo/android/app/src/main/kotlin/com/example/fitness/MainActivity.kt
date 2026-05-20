package com.example.fitness

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val PERMISSION_CHANNEL = "com.example.fitness/notifications"
    private val MESSAGE_STREAM_CHANNEL = "com.example.fitness/messages_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // No configureFlutterEngine do seu MainActivity.kt
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PERMISSION_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    result.success(isNotificationServiceEnabled())
                }
                "openSettings" -> {
                    // ... seu código de abrir configurações ...
                }
                "updateIp" -> {
                    val ip = call.argument<String>("ip")
                    if (ip != null) {
                        // Salva o IP de forma persistente no Android
                        val sharedPref = getSharedPreferences("VigiloPrefs", android.content.Context.MODE_PRIVATE)
                        sharedPref.edit().putString("server_ip", ip).apply()
                        result.success(true)
                    } else {
                        result.error("BAD_ARGUMENT", "IP veio nulo", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MESSAGE_STREAM_CHANNEL
        ).setStreamHandler(NotificationEventBridge)
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val enabledListeners = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false

        return enabledListeners.contains(packageName)
    }
}