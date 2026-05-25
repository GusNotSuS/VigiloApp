package com.example.fitness

import android.content.Context
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PERMISSION_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    result.success(isNotificationServiceEnabled())
                }

                "openSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "OPEN_SETTINGS_ERROR",
                            "Não foi possível abrir as configurações.",
                            e.message
                        )
                    }
                }

                "updateIp" -> {
                    val ip = call.argument<String>("ip")
                    if (ip != null) {
                        val sharedPref = getSharedPreferences("VigiloPrefs", Context.MODE_PRIVATE)
                        sharedPref.edit().putString("server_ip", ip).apply()
                        result.success(true)
                    } else {
                        result.error("BAD_ARGUMENT", "IP veio nulo", null)
                    }
                }

                "updateNotificationSettings" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    val percentage = call.argument<Int>("percentage") ?: 80
                    val sharedPref = getSharedPreferences("VigiloPrefs", Context.MODE_PRIVATE)
                    sharedPref.edit()
                        .putBoolean("notifications_enabled", enabled)
                        .putInt("phishing_percentage", percentage)
                        .apply()
                    result.success(true)
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