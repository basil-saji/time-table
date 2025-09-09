package com.basil.time_table

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONArray

class BootReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            
            rescheduleAllAlarms(context)
        }
    }
    
    private fun rescheduleAllAlarms(context: Context) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val schedulesJson = prefs.getString("flutter.time_table_schedules", "[]") ?: "[]"
        
        try {
            val jsonArray = JSONArray(schedulesJson)
            
            for (i in 0 until jsonArray.length()) {
                val schedule = jsonArray.getJSONObject(i)
                
                if (schedule.getBoolean("enabled")) {
                    AlarmScheduler.scheduleWeeklyAlarm(
                        context,
                        schedule.getInt("id"),
                        schedule.getInt("weekday"),
                        schedule.getInt("hour"),
                        schedule.getInt("minute"),
                        schedule.getString("message")
                    )
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
