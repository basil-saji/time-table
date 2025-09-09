class NotificationItem {
  final int id;
  final int weekday; // 1-7 (Monday-Sunday)
  final int hour;
  final int minute;
  final String message;
  final bool enabled;

  NotificationItem({
    required this.id,
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.message,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekday': weekday,
      'hour': hour,
      'minute': minute,
      'message': message,
      'enabled': enabled,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      weekday: json['weekday'],
      hour: json['hour'],
      minute: json['minute'],
      message: json['message'],
      enabled: json['enabled'] ?? true,
    );
  }

  String get weekdayName {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String get timeString {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  NotificationItem copyWith({
    int? id,
    int? weekday,
    int? hour,
    int? minute,
    String? message,
    bool? enabled,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
    );
  }
}
