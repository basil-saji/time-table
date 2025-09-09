package com.basil.time_table

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.*

object AlarmScheduler {
    
    fun scheduleWeeklyAlarm(
        context: Context,
        id: Int,
        weekday: Int, // 1-7 (Monday-Sunday)
        hour: Int,
        minute: Int,
        message: String
    ): Boolean {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("message", message)
            putExtra("weekday", weekday)
            putExtra("hour", hour)
            putExtra("minute", minute)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            
            // Convert Flutter weekday (1-7, Mon-Sun) to Calendar weekday (2-7,1, Mon-Sun)
            val calendarWeekday = if (weekday == 7) Calendar.SUNDAY else weekday + 1
            set(Calendar.DAY_OF_WEEK, calendarWeekday)
            
            // If the time has passed this week, schedule for next week
            if (before(Calendar.getInstance())) {
                add(Calendar.WEEK_OF_YEAR, 1)
            }
        }
        
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setRepeating(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    AlarmManager.INTERVAL_DAY * 7,
                    pendingIntent
                )
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
    
    fun cancelAlarm(context: Context, id: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }
}
