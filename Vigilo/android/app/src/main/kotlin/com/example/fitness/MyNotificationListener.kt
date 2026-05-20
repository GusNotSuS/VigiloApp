package com.example.fitness

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
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
    private val processedNotifications = mutableSetOf<String>()

    // Recupera dinamicamente o IP salvo pelo Flutter no SharedPreferences
    private val backendUrl: String
        get() {
            val sharedPref = getSharedPreferences("VigiloPrefs", Context.MODE_PRIVATE)
            // Caso não encontre nenhum IP salvo ainda, usa o último válido como fallback
            val ip = sharedPref.getString("server_ip", "10.115.245.25")
            return "http://$ip:8080/api/v1/messages/"
        }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Vigilio Monitor")
            .setContentText("Monitorando mensagens capturadas...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .build()

        startForeground(1, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                channelId,
                "Vigilio Monitoramento",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val packageName = sbn?.packageName ?: return
        val extras = sbn.notification?.extras
        val title = extras?.getString("android.title") ?: ""
        val text = extras?.getCharSequence("android.text")?.toString() ?: ""

        val allowedPackages = setOf(
            "com.whatsapp",
            "com.google.android.apps.messaging",
            "com.android.mms",
            "com.sec.android.app.messaging"
        )

        if (!allowedPackages.contains(packageName)) return
        if (text.isBlank()) return

        val isUnknown = title.startsWith("+") || title.any { it.isDigit() }
        if (!isUnknown) {
            Log.d("VIGILO_DEBUG", "Ignorado: Contato salvo ($title)")
            return
        }

        // FILTRO DE DUPLICIDADE
        val msgKey = "$title|$text"
        if (processedNotifications.contains(msgKey)) {
            Log.d("VIGILO_DEBUG", "Ignorado: Mensagem duplicada")
            return
        }
        processedNotifications.add(msgKey)
        if (processedNotifications.size > 100) processedNotifications.clear()

        val fullContent = if (title.isNotBlank()) "$title: $text" else text
        
        Log.i("VIGILO_DEBUG", ">>> ENVIANDO PARA BACKEND ($backendUrl): $fullContent")
        sendToBackend(fullContent)
    }

    private fun sendToBackend(content: String) {
        val payload = JSONObject().apply {
            put("content", content)
        }

        val requestBody = payload.toString()
            .toRequestBody("application/json; charset=utf-8".toMediaType())

        val request = Request.Builder()
            .url(backendUrl)
            .post(requestBody)
            .build()

        Thread {
            try {
                client.newCall(request).execute().use { response ->
                    val body = response.body?.string()

                    if (!response.isSuccessful || body.isNullOrBlank()) {
                        Log.e("VIGILO_DEBUG", "Erro backend: ${response.code}")
                        sendFallbackMessage(content)
                        return@use
                    }

                    val json = JSONObject(body)

                    // VERIFICAÇÃO DE PHISHING
                    val isPhishing = json.optBoolean("is_phishing", false)
                    if (isPhishing) {
                        Log.w("VIGILO_DEBUG", "ALERTA: Phishing confirmado pelo backend!")
                        showPhishingAlert(content)
                    }

                    val result = hashMapOf<String, Any?>(
                        "id" to json.optString("id"),
                        "content" to json.optString("content"),
                        "result_link" to if (json.has("result_link")) json.get("result_link") else null,
                        "has_social_engineering" to if (json.has("has_social_engineering")) json.get("has_social_engineering") else null,
                        "is_phishing" to if (json.has("is_phishing")) json.get("is_phishing") else null,
                        "is_safe" to if (json.has("is_safe")) json.get("is_safe") else null,
                        "created_at" to if (json.has("created_at")) json.optString("created_at") else null,
                        "updated_at" to if (json.has("updated_at")) json.optString("updated_at") else null
                    )

                    Log.i("VIGILO_DEBUG", "Mensagem analisada com sucesso")
                    NotificationEventBridge.sendMessage(result)
                }
            } catch (e: IOException) {
                Log.e("VIGILO_DEBUG", "Falha ao enviar ao backend: ${e.message}")
                sendFallbackMessage(content)
            } catch (e: Exception) {
                Log.e("VIGILO_DEBUG", "Erro inesperado: ${e.message}")
                sendFallbackMessage(content)
            }
        }.start()
    }

    private fun sendFallbackMessage(content: String) {
        val fallback = hashMapOf<String, Any?>(
            "id" to System.currentTimeMillis().toString(),
            "content" to content,
            "result_link" to null,
            "has_social_engineering" to null,
            "is_phishing" to null,
            "is_safe" to null,
            "created_at" to null,
            "updated_at" to null
        )

        NotificationEventBridge.sendMessage(fallback)
    }

    private fun showPhishingAlert(messageContent: String) {
        val notificationManager = getSystemService(NotificationManager::class.java)
        val notificationId = 2

        val alertNotification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("⚠️ Alerta de Phishing!")
            .setContentText("Uma mensagem suspeita foi detectada.")
            .setStyle(NotificationCompat.BigTextStyle().bigText("Conteúdo suspeito: $messageContent"))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(notificationId, alertNotification)
    }
}