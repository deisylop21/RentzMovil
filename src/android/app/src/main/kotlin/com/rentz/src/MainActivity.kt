package com.rentz.src

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private lateinit var notificationHelper: NotificationHelper
    private lateinit var shareHelper: ShareHelper

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        notificationHelper = NotificationHelper(this, flutterEngine)
        shareHelper = ShareHelper(this, flutterEngine)
    }
}