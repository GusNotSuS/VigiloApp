package com.example.fitness

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import android.util.Log

class MyNotificationListener : NotificationListenerService() {

    private val CHANNEL_ID = "VigiloServiceChannel"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        
        // Esta é a notificação que mantém o serviço vivo (Foreground)
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Vigilo Monitor")
            .setContentText("Monitorando mensagens de contatos desconhecidos...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .build()

        startForeground(1, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Vigilo Monitoramento",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        // 1. LOG DE ENTRADA: Roda para QUALQUER notificação que aparecer no celular
        Log.e("VIGILO_DEBUG", "------------------------------------------")
        Log.d("VIGILO_DEBUG", "App que enviou: ${sbn?.packageName}")

        val extras = sbn?.notification?.extras
        val title = extras?.getString("android.title") ?: "Título Vazio"
        val text = extras?.getCharSequence("android.text")?.toString() ?: "Conteúdo Vazio"

        // 2. LOG DE CONTEÚDO: Mostra o que foi lido independente do app
        Log.d("VIGILO_DEBUG", "Título: $title")
        Log.d("VIGILO_DEBUG", "Texto: $text")

        // 3. LOG DE FILTRO: Validação específica para o WhatsApp
        if (sbn?.packageName == "com.whatsapp") {
            Log.i("VIGILO_DEBUG", ">>> [WHATSAPP DETECTADO]")
            
            // Log extra para te ajudar com os contatos não salvos no futuro
            if (title.contains("+") || title.matches(".*\\d{5,}.*".toRegex())) {
                Log.w("VIGILO_DEBUG", "Status: Provável número não salvo (contém dígitos ou +)")
            } else {
                Log.d("VIGILO_DEBUG", "Status: Nome de contato comum")
            }
        }
        
        Log.d("VIGILO_DEBUG", "------------------------------------------")
    }
}