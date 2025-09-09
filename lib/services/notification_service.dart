import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('time_table/native');
  static const String _prefsKey = 'time_table_schedules';

  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('createNotificationChannel');
      await _requestNotificationPermission();
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  static Future<bool> _requestNotificationPermission() async {
    try {
      return await _channel.invokeMethod('requestNotificationPermission') ?? false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<List<NotificationItem>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey) ?? '[]';
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => NotificationItem.fromJson(json)).toList();
    } catch (e) {
      print('Error getting schedules: $e');
      return [];
    }
  }

  static Future<void> saveNotifications(List<NotificationItem> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      print('Error saving schedules: $e');
    }
  }

  static Future<void> scheduleNotification(NotificationItem notification) async {
    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'id': notification.id,
        'weekday': notification.weekday,
        'hour': notification.hour,
        'minute': notification.minute,
        'message': notification.message,
      });
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _channel.invokeMethod('cancelAlarm', {'id': id});
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }
}
