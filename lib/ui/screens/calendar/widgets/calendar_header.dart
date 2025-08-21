import 'package:flutter/material.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        // Previous month button
        IconButton(
          onPressed: onPreviousMonth,
          icon: Icon(
            Icons.chevron_left,
            color: colors.onSurface,
          ),
          tooltip: 'Previous month',
        ),
        
        // Month and year display
        Expanded(
          child: Text(
            CalendarUtils.formatMonthYear(currentMonth),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ),
        
        // Next month button
        IconButton(
          onPressed: onNextMonth,
          icon: Icon(
            Icons.chevron_right,
            color: colors.onSurface,
          ),
          tooltip: 'Next month',
        ),
        
        // Today button
        TextButton.icon(
          onPressed: onToday,
          icon: Icon(
            Icons.today,
            size: 18,
            color: colors.primary,
          ),
          label: Text(
            'Today',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
