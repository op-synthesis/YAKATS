package com.example.yakats_new

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.yakats/background"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for background tasks
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startBackgroundService" -> {
                        startBackgroundService()
                        result.success("Background service started")
                    }
                    "stopBackgroundService" -> {
                        stopBackgroundService()
                        result.success("Background service stopped")
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun startBackgroundService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            RiskCheckJobService.scheduleJob(this)
        }
    }
    
    private fun stopBackgroundService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            RiskCheckJobService.cancelJob(this)
        }
    }
}