package com.basil.time_table

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.*

class AlarmReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("id", 0)
        val message = intent.getStringExtra("message") ?: "Class Reminder"
        
        showNotification(context, id, message)
        
        // For Android 6+ (API 23+), reschedule for next week since setExactAndAllowWhileIdle doesn't repeat
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            rescheduleForNextWeek(context, intent)
        }
    }
    
    private fun showNotification(context: Context, id: Int, message: String) {
        val notification = NotificationCompat.Builder(context, "time_table_channel")
            .setContentTitle("Time Table")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .build()
        
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(id, notification)
    }
    
    private fun rescheduleForNextWeek(context: Context, originalIntent: Intent) {
        val id = originalIntent.getIntExtra("id", 0)
        val weekday = originalIntent.getIntExtra("weekday", 1)
        val hour = originalIntent.getIntExtra("hour", 9)
        val minute = originalIntent.getIntExtra("minute", 0)
        val message = originalIntent.getStringExtra("message") ?: "Class Reminder"
        
        // Reschedule for next week
        AlarmScheduler.scheduleWeeklyAlarm(context, id, weekday, hour, minute, message)
    }
}
