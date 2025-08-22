import 'package:flutter/material.dart';
import 'package:fam_sync/domain/models/event.dart';

class CalendarUtils {
  // Get the first day of the month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get the last day of the month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Get the first day of the week (Sunday)
  static DateTime getFirstDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Get the last day of the week (Saturday)
  static DateTime getLastDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  // Get all dates for a month view (including padding days)
  static List<DateTime> getMonthDates(DateTime month) {
    final firstDay = getFirstDayOfMonth(month);
    final lastDay = getLastDayOfMonth(month);
    
    // Get the first day of the week that contains the first day of the month
    final firstWeekday = getFirstDayOfWeek(firstDay);
    
    final dates = <DateTime>[];
    DateTime current = firstWeekday;
    
    // Add dates until we've covered the entire month view
    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    // Ensure we have complete weeks (42 dates for 6 weeks)
    while (dates.length < 42) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  // Get all dates for a week view
  static List<DateTime> getWeekDates(DateTime date) {
    final firstDay = getFirstDayOfWeek(date);
    final dates = <DateTime>[];
    
    for (int i = 0; i < 7; i++) {
      dates.add(firstDay.add(Duration(days: i)));
    }
    
    return dates;
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Check if a date is in the current month
  static bool isCurrentMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  // Check if a date is selected
  static bool isSelected(DateTime date, DateTime selectedDate) {
    return date.year == selectedDate.year && 
           date.month == selectedDate.month && 
           date.day == selectedDate.day;
  }

  // Get events for a specific date
  static List<Event> getEventsForDate(List<Event> events, DateTime date) {
    return events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate.year == targetDate.year && 
             eventDate.month == targetDate.month && 
             eventDate.day == targetDate.day;
    }).toList();
  }

  // Format date for display
  static String formatDate(DateTime date) {
    return '${date.day}';
  }

  // Format month and year
  static String formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Format time for display
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  // Format date range
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${formatDate(start)} ${formatMonthYear(start)}';
    } else if (start.year == end.year) {
      return '${start.day} ${_getMonthName(start.month)} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
    } else {
      return '${start.day} ${_getMonthName(start.month)} ${start.year} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
    }
  }

  // Get month name
  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get day name
  static String getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Get full day name
  static String getFullDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  // Calculate duration between two times
  static String getDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Get event color based on category
  static Color getEventColor(EventCategory category) {
    switch (category) {
      case EventCategory.school:
        return Colors.blue;
      case EventCategory.work:
        return Colors.orange;
      case EventCategory.family:
        return Colors.green;
      case EventCategory.personal:
        return Colors.purple;
      case EventCategory.medical:
        return Colors.red;
      case EventCategory.sports:
        return Colors.teal;
      case EventCategory.travel:
        return Colors.indigo;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  // Get event priority color
  static Color getPriorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.low:
        return Colors.green;
      case EventPriority.medium:
        return Colors.orange;
      case EventPriority.high:
        return Colors.red;
      case EventPriority.urgent:
        return Colors.purple;
    }
  }
}
