package com.basil.time_table

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "time_table/native"
    private val NOTIFICATION_PERMISSION_CODE = 1001
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createNotificationChannel" -> {
                    createNotificationChannel()
                    result.success(null)
                }
                "requestNotificationPermission" -> {
                    val hasPermission = requestNotificationPermission()
                    result.success(hasPermission)
                }
                "scheduleAlarm" -> {
                    val args = call.arguments as Map<String, Any>
                    val success = AlarmScheduler.scheduleWeeklyAlarm(
                        this,
                        args["id"] as Int,
                        args["weekday"] as Int,
                        args["hour"] as Int,
                        args["minute"] as Int,
                        args["message"] as String
                    )
                    result.success(success)
                }
                "cancelAlarm" -> {
                    val args = call.arguments as Map<String, Any>
                    AlarmScheduler.cancelAlarm(this, args["id"] as Int)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "time_table_channel",
                "Class Schedule Reminders",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for class schedules and reminders"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun requestNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) 
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    this, 
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS), 
                    NOTIFICATION_PERMISSION_CODE
                )
                false
            } else {
                true
            }
        } else {
            true
        }
    }
}
