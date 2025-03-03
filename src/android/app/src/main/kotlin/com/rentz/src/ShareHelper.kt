package com.rentz.src

import android.content.Intent
import android.content.Context
import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class ShareHelper(private val activity: Activity, flutterEngine: FlutterEngine) {
    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.channel.shared.data")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText" -> {
                        val text = call.argument<String>("text")
                        val title = call.argument<String>("title")

                        if (text != null && title != null) {
                            val sendIntent = Intent().apply {
                                action = Intent.ACTION_SEND
                                putExtra(Intent.EXTRA_TEXT, text)
                                type = "text/plain"
                            }

                            val shareIntent = Intent.createChooser(sendIntent, title)
                            shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                            activity.startActivity(shareIntent)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENTS", "Text and title are required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}