package com.rentz.src

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NotificationHelper(private val activity: Activity, flutterEngine: FlutterEngine) {
    private val channelId = "rentz_high_importance_channel"
    private val channelName = "Notificaciones Rentz"
    private val notificationManager = NotificationManagerCompat.from(activity)

    init {
        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.channel.notification")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showNotification" -> {
                        try {
                            val title = call.argument<String>("title")
                            val body = call.argument<String>("body")
                            val id = call.argument<Int>("id") ?: 0
                            val data = call.argument<Map<String, Any>>("data")

                            if (title != null && body != null) {
                                showNotification(
                                    notificationId = id,
                                    title = title,
                                    message = body,
                                    data = data
                                )
                                result.success(true)
                            } else {
                                result.error(
                                    "INVALID_ARGUMENTS",
                                    "Title and body are required",
                                    null
                                )
                            }
                        } catch (e: Exception) {
                            result.error(
                                "NOTIFICATION_ERROR",
                                "Error showing notification: ${e.message}",
                                null
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Canal para notificaciones importantes de Rentz"
                enableLights(true)
                lightColor = Color.BLUE
                enableVibration(true)
                vibrationPattern = longArrayOf(100, 200, 300, 400, 500)
            }

            val notificationManager = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(
        notificationId: Int,
        title: String,
        message: String,
        data: Map<String, Any>?
    ) {
        // Crear intent para abrir la app
        val intent = Intent(activity, activity.javaClass).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP

            // Agregar datos extras si existen
            data?.forEach { (key, value) ->
                putExtra(key, value.toString())
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            activity,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(activity, channelId)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVibrate(longArrayOf(100, 200, 300, 400, 500))
            .setLights(Color.BLUE, 1000, 1000)
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(notificationId, notification)
    }
}