import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_details.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

class AgendaView extends ConsumerWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final familyId = ref.watch(userProfileStreamProvider).when(
      data: (profile) => profile?.familyId,
      loading: () => null,
      error: (_, __) => null,
    );

    if (familyId == null) {
      return const Center(child: Text('No family context'));
    }

    final upcomingEventsAsync = ref.watch(upcomingEventsProvider(familyId));

    return upcomingEventsAsync.when(
      data: (events) => _buildAgendaList(context, ref, events, spaces),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaList(BuildContext context, WidgetRef ref, List<Event> events, AppSpacing spaces) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: spaces.xl * 2,
              color: Colors.grey,
            ),
            SizedBox(height: spaces.md),
            Text(
              'No upcoming events',
              style: TextStyle(
                fontSize: spaces.md,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: spaces.xs),
            const Text(
              'Tap the + button to create your first event',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Group events by date
    final groupedEvents = <DateTime, List<Event>>{};
    for (final event in events) {
      final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      groupedEvents.putIfAbsent(date, () => []).add(event);
    }

    final sortedDates = groupedEvents.keys.toList()..sort();

    return ListView.builder(
      padding: EdgeInsets.all(spaces.md),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayEvents = groupedEvents[date]!;
        
        return _buildDateSection(context, date, dayEvents, spaces);
      },
    );
  }

  Widget _buildDateSection(BuildContext context, DateTime date, List<Event> events, AppSpacing spaces) {
    final colors = Theme.of(context).colorScheme;
    final isToday = CalendarUtils.isToday(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Container(
          padding: EdgeInsets.symmetric(vertical: spaces.xs, horizontal: spaces.md),
          margin: EdgeInsets.only(bottom: spaces.xs),
          decoration: BoxDecoration(
            color: isToday ? colors.primaryContainer : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(spaces.xs),
          ),
          child: Row(
            children: [
              Text(
                CalendarUtils.getFullDayName(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday ? colors.primary : colors.onSurface,
                ),
              ),
                            SizedBox(width: spaces.xs),
              Text(
                '${date.day} ${_getMonthName(date.month)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isToday ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
                          // Events for this date
                  ...events.map((event) => _buildEventItem(context, event, spaces)),
        
        SizedBox(height: spaces.md),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, Event event, AppSpacing spaces) {
    final colors = Theme.of(context).colorScheme;
    final eventColor = CalendarUtils.getEventColor(event.category);
    final priorityColor = CalendarUtils.getPriorityColor(event.priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showEventDetails(context, event),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(spaces.md),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: spaces.xl * 1.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CalendarUtils.formatTime(event.startTime),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      CalendarUtils.formatTime(event.endTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: spaces.xs),
                        // Category indicator
                        Container(
                          width: spaces.xs,
                          height: spaces.xs,
                          decoration: BoxDecoration(
                            color: eventColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    
                    if (event.description.isNotEmpty) ...[
                      SizedBox(height: spaces.xs / 2),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    SizedBox(height: spaces.xs),
                    
                    // Event metadata
                    Row(
                      children: [
                        if (event.location != null && event.location!.isNotEmpty) ...[
                          Icon(
                            Icons.location_on,
                            size: spaces.sm,
                            color: colors.onSurfaceVariant,
                          ),
                          SizedBox(width: spaces.xs / 2),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: spaces.md),
                        ],
                        
                        // Priority indicator
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: spaces.xs / 2, vertical: spaces.xs / 4),
                          decoration: BoxDecoration(
                            color: priorityColor,
                            borderRadius: BorderRadius.circular(spaces.xs / 2),
                          ),
                          child: Text(
                            event.priority.name.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: spaces.xs,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    Navigator.of(context).push<EventDetails>(
      MaterialPageRoute<EventDetails>(
        builder: (context) => EventDetails(
          event: event,
          onDeleted: () {
            // TODO: Refresh calendar data
          },
          onEdited: () {
            // TODO: Refresh calendar data
          },
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
