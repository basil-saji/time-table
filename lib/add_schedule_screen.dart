import 'package:flutter/material.dart';
import 'models/notification_item.dart';
import 'services/notification_service.dart';

class AddScheduleScreen extends StatefulWidget {
  final NotificationItem? editItem;

  const AddScheduleScreen({super.key, this.editItem});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController _messageController = TextEditingController();
  int _selectedWeekday = 1;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _messageController.text = widget.editItem!.message;
      _selectedWeekday = widget.editItem!.weekday;
      _selectedTime = TimeOfDay(
        hour: widget.editItem!.hour,
        minute: widget.editItem!.minute,
      );
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveSchedule() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter a subject/activity'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notification = NotificationItem(
        id: widget.editItem?.id ?? NotificationService.generateId(),
        weekday: _selectedWeekday,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        message: _messageController.text.trim(),
      );

      if (widget.editItem != null) {
        await NotificationService.cancelNotification(widget.editItem!.id);
      }

      await NotificationService.scheduleNotification(notification);

      // Get current notifications and update
      final notifications = await NotificationService.getNotifications();
      if (widget.editItem != null) {
        final index =
            notifications.indexWhere((n) => n.id == widget.editItem!.id);
        if (index != -1) {
          notifications[index] = notification;
        }
      } else {
        notifications.add(notification);
      }

      await NotificationService.saveNotifications(notifications);

      if (mounted) {
        Navigator.pop(context, notification);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.editItem != null ? 'Edit Schedule' : 'Add New Schedule',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject/Activity Input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSubjectIcon(_messageController.text),
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Subject or Activity',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'e.g., Mathematics, Physics Lab, Lunch Break',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Day and Time Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Schedule Details',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekday Selection
                  Text(
                    'Day of the week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedWeekday,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      prefixIcon: Icon(
                        Icons.calendar_today_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(weekdays[index]),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedWeekday = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // Time Selection
                  Text(
                    'Time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedTime.format(context),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Save Button
            FilledButton(
              onPressed: _isLoading ? null : _saveSchedule,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.editItem != null
                            ? Icons.edit_rounded
                            : Icons.save_rounded),
                        const SizedBox(width: 8),
                        Text(
                          widget.editItem != null
                              ? 'Update Schedule'
                              : 'Save Schedule',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
