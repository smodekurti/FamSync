import 'package:flutter/material.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_details.dart';
import 'package:fam_sync/theme/app_theme.dart';

class CalendarDay extends StatelessWidget {
  final DateTime date;
  final List<Event> events;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const CalendarDay({
    super.key,
    required this.date,
    required this.events,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: EdgeInsets.all(spaces.xs / 4),
        decoration: BoxDecoration(
          color: _getBackgroundColor(colors),
          borderRadius: BorderRadius.circular(spaces.xs),
          border: Border.all(
            color: _getBorderColor(colors),
            width: isSelected ? spaces.xs / 2 : spaces.xs / 4,
          ),
        ),
        child: Column(
          children: [
            // Date number
            Container(
              padding: EdgeInsets.only(top: spaces.xs, right: spaces.xs),
              alignment: Alignment.topRight,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: spaces.sm,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: _getTextColor(colors),
                ),
              ),
            ),
            
            // Event indicators
            if (events.isNotEmpty) ...[
              SizedBox(height: spaces.xs / 2),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < events.length.clamp(0, 3); i++)
                      Container(
                        margin: EdgeInsets.only(bottom: spaces.xs / 4),
                        height: spaces.xs / 2,
                        decoration: BoxDecoration(
                          color: CalendarUtils.getEventColor(events[i].category),
                          borderRadius: BorderRadius.circular(spaces.xs / 4),
                        ),
                      ),
                    if (events.length > 3)
                      Text(
                        '+${events.length - 3}',
                        style: TextStyle(
                          fontSize: spaces.xs,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colors) {
    if (isSelected) {
      return colors.primary.withValues(alpha: 0.1);
    }
    if (isToday) {
      return colors.primaryContainer.withValues(alpha: 0.3);
    }
    return colors.surface;
  }

  Color _getBorderColor(ColorScheme colors) {
    if (isSelected) {
      return colors.primary;
    }
    if (isToday) {
      return colors.primary;
    }
    return colors.outlineVariant;
  }

  Color _getTextColor(ColorScheme colors) {
    if (!isCurrentMonth) {
      return colors.onSurfaceVariant.withValues(alpha: 0.5);
    }
    if (isSelected) {
      return colors.primary;
    }
    if (isToday) {
      return colors.primary;
    }
    return colors.onSurface;
  }

  void _handleTap(BuildContext context) {
    if (events.isNotEmpty) {
      // Show event details for the first event
      Navigator.of(context).push<EventDetails>(
        MaterialPageRoute<EventDetails>(
          builder: (context) => EventDetails(
            event: events.first,
            onDeleted: () {
              // TODO: Refresh calendar data
            },
            onEdited: () {
              // TODO: Refresh calendar data
            },
          ),
        ),
      );
    } else {
      // Just select the date
      onTap();
    }
  }
}
