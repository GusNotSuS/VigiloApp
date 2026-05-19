package com.example.fitness

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import androidx.core.app.NotificationCompat
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

class MyNotificationListener : NotificationListenerService() {
    private val channelId = "VigiloServiceChannel"
    private val client = OkHttpClient()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val backendUrl = "http://10.10.2.130:8080/api/v1/messages/"

    // PONTO 3 CORRIGIDO: Cache LRU estável que remove apenas o mais antigo ao passar de 100 itens
    private val processedNotifications = object : LinkedHashMap<String, Boolean>(101, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Boolean>?): Boolean {
            return size > 100
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Vigilio Monitor")
            .setContentText("Monitorando...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .build()
        startForeground(1, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(NotificationChannel(channelId, "Monitor", NotificationManager.IMPORTANCE_HIGH))
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val prefs = getSharedPreferences("VigilioPrefs", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("notifications_enabled", true)) return

        val packageName = sbn?.packageName ?: return
        val extras = sbn.notification?.extras
        val title = extras?.getString("android.title") ?: ""
        val text = extras?.getCharSequence("android.text")?.toString() ?: ""

        if (text.isBlank() || !setOf("com.whatsapp", "com.google.android.apps.messaging").contains(packageName)) return
        if (!(title.startsWith("+") || title.any { it.isDigit() })) return

        val msgKey = "$title|$text"
        
        // Verifica se já foi processada recentemente sem perigo de sofrer wipe total
        if (processedNotifications.containsKey(msgKey)) return
        processedNotifications[msgKey] = true

        sendToBackend(if (title.isNotBlank()) "$title: $text" else text)
    }

    private fun sendToBackend(content: String) {
        val request = Request.Builder().url(backendUrl)
            .post(JSONObject().apply { put("content", content) }.toString().toRequestBody("application/json".toMediaType()))
            .build()

        Thread {
            try {
                client.newCall(request).execute().use { response ->
                    val body = response.body?.string() ?: return@use
                    val json = JSONObject(body)
                    
                    val riskScore = json.optDouble("risk_score", 0.0)
                    val prefs = getSharedPreferences("VigilioPrefs", Context.MODE_PRIVATE)
                    val threshold = prefs.getFloat("min_risk_score", 0.8f)

                    // PONTO 1 CORRIGIDO: Todo o retorno que toca na UI ou serviços do Android executado na Main Thread
                    mainHandler.post {
                        if (riskScore >= threshold) {
                            showPhishingAlert(content, json.optString("reason", "Risco detectado"))
                        }

                        NotificationEventBridge.sendMessage(hashMapOf(
                            "id" to json.optString("id"),
                            "content" to content,
                            "is_safe" to json.optBoolean("is_safe"),
                            "is_phishing" to json.optBoolean("is_phishing"),
                            "has_social_engineering" to json.optBoolean("has_social_engineering"),
                            "risk_score" to riskScore,
                            "reason" to json.optString("reason")
                        ))
                    }
                }
            } catch (e: Exception) {
                Log.e("VIGILO", e.message ?: "Error")
            }
        }.start()
    }

    private fun showPhishingAlert(content: String, reason: String) {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(2, NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("⚠️ Alerta de Risco!")
            .setContentText(reason)
            .setStyle(NotificationCompat.BigTextStyle().bigText("Mensagem: $content\n\nMotivo: $reason"))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build())
    }
}