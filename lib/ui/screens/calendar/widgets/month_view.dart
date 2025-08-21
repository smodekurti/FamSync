import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/calendar_day.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/calendar_header.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';

class MonthView extends ConsumerWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final familyId = ref.watch(userProfileStreamProvider).when(
      data: (profile) => profile?.familyId,
      loading: () => null,
      error: (_, __) => null,
    );

    if (familyId == null) {
      return const Center(child: Text('No family context'));
    }

    final monthEventsAsync = ref.watch(monthEventsProvider(familyId));

    return monthEventsAsync.when(
      data: (events) => _buildMonthGrid(context, ref, currentMonth, selectedDate, events),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading events')),
    );
  }

  Widget _buildMonthGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime currentMonth,
    DateTime selectedDate,
    List<Event> events,
  ) {
    final dates = CalendarUtils.getMonthDates(currentMonth);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);

    return Column(
      children: [
        // Calendar header with navigation
        CalendarHeader(
          currentMonth: currentMonth,
          onPreviousMonth: () => calendarNotifier.previousMonth(),
          onNextMonth: () => calendarNotifier.nextMonth(),
          onToday: () => calendarNotifier.goToToday(),
        ),
        
        SizedBox(height: context.spaces.md),
        
        // Day names header
        Row(
          children: [
            for (int i = 0; i < 7; i++)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    CalendarUtils.getDayName(dates[i]),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        SizedBox(height: context.spaces.xs),
        
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isCurrentMonth = CalendarUtils.isCurrentMonth(date, currentMonth);
              final isToday = CalendarUtils.isToday(date);
              final isSelected = CalendarUtils.isSelected(date, selectedDate);
              final dayEvents = CalendarUtils.getEventsForDate(events, date);
              
              return CalendarDay(
                date: date,
                events: dayEvents,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                isSelected: isSelected,
                onTap: () => calendarNotifier.setSelectedDate(date),
              );
            },
          ),
        ),
      ],
    );
  }
}
