import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

class WeekView extends ConsumerWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final familyId = ref.watch(userProfileStreamProvider).when(
      data: (profile) => profile?.familyId,
      loading: () => null,
      error: (_, __) => null,
    );

    if (familyId == null) {
      return const Center(child: Text('No family context'));
    }

    final weekDates = CalendarUtils.getWeekDates(selectedDate);
    final weekEventsAsync = ref.watch(monthEventsProvider(familyId));

    return weekEventsAsync.when(
      data: (events) => _buildWeekGrid(context, ref, weekDates, events),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading events')),
    );
  }

  Widget _buildWeekGrid(
    BuildContext context,
    WidgetRef ref,
    List<DateTime> weekDates,
    List<Event> events,
  ) {
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
    
    return Column(
      children: [
        // Week header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  final previousWeek = weekDates.first.subtract(const Duration(days: 7));
                  calendarNotifier.setSelectedDate(previousWeek);
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${CalendarUtils.formatDate(weekDates.first)} - ${CalendarUtils.formatDate(weekDates.last)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final nextWeek = weekDates.last.add(const Duration(days: 1));
                  calendarNotifier.setSelectedDate(nextWeek);
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Day names and events
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < 7; i++)
                                 Expanded(
                   child: _buildDayColumn(
                     context,
                     weekDates[i],
                     CalendarUtils.getEventsForDate(events, weekDates[i]),
                     () => calendarNotifier.setSelectedDate(weekDates[i]),
                   ),
                 ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    DateTime date,
    List<Event> dayEvents,
    VoidCallback onTap,
  ) {
    final isToday = CalendarUtils.isToday(date);
    final colors = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: colors.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            // Day header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? colors.primaryContainer : colors.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: colors.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    CalendarUtils.getDayName(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday ? colors.primary : colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? colors.primary : colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            // Events for this day
            Expanded(
              child: dayEvents.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dayEvents.length,
                      itemBuilder: (context, index) {
                        final event = dayEvents[index];
                        return _buildEventItem(context, event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {
    final colors = Theme.of(context).colorScheme;
    final eventColor = CalendarUtils.getEventColor(event.category);
    
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: eventColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: eventColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            CalendarUtils.formatTime(event.startTime),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
