import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/notification_item.dart';
import 'services/notification_service.dart';
import 'add_schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<NotificationItem> _notifications = [];
  bool _isDarkMode = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await NotificationService.initialize();
      await _loadNotifications();
      await _loadThemePreference();
    } catch (e) {
      print('Error initializing app: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('dark_mode') ?? false;
      if (mounted) {
        setState(() {
          _isDarkMode = isDark;
        });
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  void _toggleDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = !_isDarkMode;
      });
      await prefs.setBool('dark_mode', _isDarkMode);

      // Update theme through provider if available, or restart app
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error toggling dark mode: $e');
    }
  }

  void _deleteNotification(int index) async {
    try {
      final notification = _notifications[index];
      await NotificationService.cancelNotification(notification.id);

      setState(() {
        _notifications.removeAt(index);
      });

      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildNotificationCard(notification, animation),
      );

      await NotificationService.saveNotifications(_notifications);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Schedule deleted'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void _navigateToAddSchedule([NotificationItem? editItem]) async {
    final result = await Navigator.push<NotificationItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(editItem: editItem),
      ),
    );

    if (result != null) {
      await _loadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                    editItem != null ? 'Schedule updated!' : 'Schedule added!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  IconData _getSubjectIcon(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('math') ||
        subjectLower.contains('calculus') ||
        subjectLower.contains('algebra')) {
      return Icons.calculate_rounded;
    } else if (subjectLower.contains('science') ||
        subjectLower.contains('physics') ||
        subjectLower.contains('chemistry')) {
      return Icons.science_rounded;
    } else if (subjectLower.contains('english') ||
        subjectLower.contains('literature')) {
      return Icons.book_rounded;
    } else if (subjectLower.contains('history') ||
        subjectLower.contains('social')) {
      return Icons.history_edu_rounded;
    } else if (subjectLower.contains('art') ||
        subjectLower.contains('design')) {
      return Icons.palette_rounded;
    } else if (subjectLower.contains('music')) {
      return Icons.music_note_rounded;
    } else if (subjectLower.contains('sport') ||
        subjectLower.contains('gym') ||
        subjectLower.contains('physical')) {
      return Icons.sports_rounded;
    } else if (subjectLower.contains('computer') ||
        subjectLower.contains('coding') ||
        subjectLower.contains('programming')) {
      return Icons.computer_rounded;
    } else if (subjectLower.contains('lunch') ||
        subjectLower.contains('break') ||
        subjectLower.contains('meal')) {
      return Icons.restaurant_rounded;
    }
    return Icons.school_rounded;
  }

  Color _getSubjectColor(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('math') ||
        subjectLower.contains('calculus') ||
        subjectLower.contains('algebra')) {
      return Colors.blue;
    } else if (subjectLower.contains('science') ||
        subjectLower.contains('physics') ||
        subjectLower.contains('chemistry')) {
      return Colors.green;
    } else if (subjectLower.contains('english') ||
        subjectLower.contains('literature')) {
      return Colors.orange;
    } else if (subjectLower.contains('history') ||
        subjectLower.contains('social')) {
      return Colors.brown;
    } else if (subjectLower.contains('art') ||
        subjectLower.contains('design')) {
      return Colors.purple;
    } else if (subjectLower.contains('music')) {
      return Colors.pink;
    } else if (subjectLower.contains('sport') ||
        subjectLower.contains('gym') ||
        subjectLower.contains('physical')) {
      return Colors.red;
    } else if (subjectLower.contains('computer') ||
        subjectLower.contains('coding') ||
        subjectLower.contains('programming')) {
      return Colors.indigo;
    } else if (subjectLower.contains('lunch') ||
        subjectLower.contains('break') ||
        subjectLower.contains('meal')) {
      return Colors.amber;
    }
    return Colors.teal;
  }

  Widget _buildNotificationCard(
      NotificationItem notification, Animation<double> animation) {
    final subjectColor = _getSubjectColor(notification.message);
    final subjectIcon = _getSubjectIcon(notification.message);

    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: Offset.zero).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => _navigateToAddSchedule(notification),
              onLongPress: () {
                final index = _notifications.indexOf(notification);
                _deleteNotification(index);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        subjectIcon,
                        color: subjectColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  notification.weekdayName,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      notification.timeString,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context).colorScheme.outline,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your schedule...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Table',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${_notifications.length} scheduled classes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _toggleDarkMode,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No classes scheduled',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first class schedule to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => _navigateToAddSchedule(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Schedule'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverAnimatedList(
                  key: _listKey,
                  initialItemCount: _notifications.length,
                  itemBuilder: (context, index, animation) {
                    return _buildNotificationCard(
                        _notifications[index], animation);
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddSchedule(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Schedule'),
      ),
    );
  }
}
