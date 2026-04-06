package com.example.fitness

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object NotificationEventBridge : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendMessage(message: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(message)
        }
    }
}