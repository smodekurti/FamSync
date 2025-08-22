import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/domain/models/user_profile.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/users/users_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';

class MonthViewNew extends ConsumerWidget {
  const MonthViewNew({super.key});

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

    // Set the familyId in the calendar state for proper stream invalidation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarNotifierProvider.notifier).setFamilyId(familyId);
    });

    final monthEventsAsync = ref.watch(monthEventsProvider(familyId));
    
    // Debug logging
    monthEventsAsync.whenData((events) {
      print('📅 MonthViewNew: Received ${events.length} events for ${currentMonth.year}-${currentMonth.month}');
      if (events.isNotEmpty) {
        print('📅 First event: ${events.first.title} on ${events.first.startTime}');
        print('📅 Event category: ${events.first.category}, priority: ${events.first.priority}');
      }
    });

    return monthEventsAsync.when(
      data: (events) => _buildCalendarView(context, ref, events, selectedDate),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading calendar events...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh the data - familyId is guaranteed to be non-null here
                // since we return early if familyId is null
                ref.invalidate(monthEventsProvider(familyId));
              },
              child: Text('Retry'),
            ),
            if (kDebugMode) ...[
              SizedBox(height: 16),
              Text(
                'Debug Info:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Family ID: $familyId\nMonth: ${currentMonth.year}-${currentMonth.month}\nError: $error',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, WidgetRef ref, List<Event> events, DateTime selectedDate) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    // Convert our Event model to NeatCleanCalendarEvent
    final calendarEvents = _convertToCalendarEvents(events);
    
    // Show helpful message if no events
    if (events.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spaces.xs,
                vertical: spaces.xs / 2,
              ),
              child: Calendar(
                startOnMonday: true,
                weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                eventsList: calendarEvents,
                initialDate: selectedDate, // Set the initial date to selected date
                      isExpandable: true,
        isExpanded: false, // Start collapsed to prevent overflow
              eventDoneColor: colors.primary,
              selectedColor: colors.primary,
              selectedTodayColor: colors.primary,
              todayColor: colors.primaryContainer,
              eventColor: colors.secondary,
              locale: 'en_US',
              todayButtonText: 'Today',
              allDayEventText: 'All Day',
              multiDayEndText: 'End',
              expandableDateFormat: 'EEEE, MMMM d, yyyy',
              datePickerType: DatePickerType.date,
              dayOfWeekStyle: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              displayMonthTextStyle: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              bottomBarColor: colors.surfaceContainerHighest,
              bottomBarArrowColor: colors.onSurfaceVariant,
              eventTileHeight: null, // Let the widget calculate optimal height
              onDateSelected: (date) {
                ref.read(calendarNotifierProvider.notifier).setSelectedDate(date);
              },
              onMonthChanged: (date) {
                print('📅 Month changed to: ${date.year}-${date.month}');
                ref.read(calendarNotifierProvider.notifier).setCurrentMonth(date);
              },
              onEventSelected: (calendarEvent) {
                // For now, show a simple dialog with event info
                // TODO: Implement proper event details navigation
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Event Selected'),
                    content: const Text('Event details coming soon...'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              onEventLongPressed: (calendarEvent) {
                // Handle long press if needed
              },
              onTodayButtonPressed: (_) {
                ref.read(calendarNotifierProvider.notifier).goToToday();
              },
              showEvents: true,
              forceEventListView: true, // Force the event list view to show
              showEventListViewIcon: true,
            ),
          ),
        ),
          // Helpful message for empty calendar
          Container(
            padding: EdgeInsets.all(spaces.md),
            child: Column(
              children: [
                Icon(
                  Icons.event_note,
                  size: 48,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(height: spaces.sm),
                Text(
                  'No events this month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: spaces.xs),
                Text(
                  'Tap the + button to add your first event!',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        // Calendar widget
        Calendar(
            startOnMonday: true,
            weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            eventsList: calendarEvents,
            initialDate: selectedDate, // Set the initial date to selected date
            isExpandable: true,
            isExpanded: false, // Start collapsed to prevent overflow
            eventDoneColor: colors.primary,
            selectedColor: colors.primary,
            selectedTodayColor: colors.primary,
            todayColor: colors.primaryContainer,
            eventColor: colors.secondary,
            locale: 'en_US',
            todayButtonText: 'Today',
            allDayEventText: 'All Day',
            multiDayEndText: 'End',
            expandableDateFormat: 'EEEE, MMMM d, yyyy',
            datePickerType: DatePickerType.date,
            dayOfWeekStyle: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            displayMonthTextStyle: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            bottomBarColor: colors.surfaceContainerHighest,
            bottomBarArrowColor: colors.onSurfaceVariant,
            eventTileHeight: null, // Let the widget calculate optimal height
            onDateSelected: (date) {
              ref.read(calendarNotifierProvider.notifier).setSelectedDate(date);
            },
            onMonthChanged: (date) {
              print('📅 Month changed to: ${date.year}-${date.month}');
              ref.read(calendarNotifierProvider.notifier).setCurrentMonth(date);
            },
            onEventSelected: (calendarEvent) {
              // For now, show a simple dialog with event info
              // TODO: Implement proper event details navigation
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Event Selected'),
                  content: const Text('Event details coming soon...'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            onEventLongPressed: (calendarEvent) {
              // Handle long press if needed
            },
            onTodayButtonPressed: (_) {
              ref.read(calendarNotifierProvider.notifier).goToToday();
            },
            showEvents: false, // Hide built-in event list
            forceEventListView: false,
            showEventListViewIcon: false,
          ),
        
        // Custom event list for selected date
        if (events.isNotEmpty) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
            decoration: BoxDecoration(
              color: Colors.white, // Same white background as calendar
              borderRadius: BorderRadius.circular(spaces.sm),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(spaces.sm),
              itemCount: events.length,
              itemBuilder: (context, index) => _buildEventCard(context, events[index], spaces, colors),
            ),
          ),
        ],
      ],
    );
  }

  List<NeatCleanCalendarEvent> _convertToCalendarEvents(List<Event> events) {
    return events.map((event) {
      // Determine if it's an all-day event
      final isAllDay = event.startTime.hour == 0 && 
                      event.startTime.minute == 0 && 
                      event.endTime.hour == 23 && 
                      event.endTime.minute == 59;
      
      // Determine if it's a multi-day event
      final isMultiDay = event.startTime.day != event.endTime.day ||
                         event.startTime.month != event.endTime.month ||
                         event.startTime.year != event.endTime.year;
      
      // Get event color based on category and priority
      final eventColor = _getEventColor(event.category, event.priority);
      
      return NeatCleanCalendarEvent(
        event.title,
        startTime: event.startTime,
        endTime: event.endTime,
        color: eventColor,
        isAllDay: isAllDay,
        isMultiDay: isMultiDay,
        description: event.description,
        // Add any additional properties you want to display
      );
    }).toList();
  }

  Color _getEventColor(EventCategory category, EventPriority priority) {
    // Base color based on category
    Color baseColor;
    switch (category) {
      case EventCategory.school:
        baseColor = Colors.blue;
        break;
      case EventCategory.work:
        baseColor = Colors.orange;
        break;
      case EventCategory.family:
        baseColor = Colors.green;
        break;
      case EventCategory.personal:
        baseColor = Colors.purple;
        break;
      case EventCategory.medical:
        baseColor = Colors.red;
        break;
      case EventCategory.sports:
        baseColor = Colors.teal;
        break;
      case EventCategory.travel:
        baseColor = Colors.indigo;
        break;
      case EventCategory.other:
        baseColor = Colors.grey;
        break;
    }
    
    // Adjust color based on priority
    switch (priority) {
      case EventPriority.urgent:
        return baseColor.withValues(alpha: 1.0); // Most vibrant
      case EventPriority.high:
        return baseColor.withValues(alpha: 0.9); // More vibrant
      case EventPriority.medium:
        return baseColor.withValues(alpha: 0.7); // Standard
      case EventPriority.low:
        return baseColor.withValues(alpha: 0.5); // More muted
    }
  }



  // Build creator avatar using the same pattern as Hub timeline
  Widget _buildEventCreatorAvatar(UserProfile user, BuildContext context) {
    // Generate consistent colors for family members (same as Hub timeline)
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    final colorIndex = user.hashCode % colors.length;
    final avatarColor = colors[colorIndex];
    
    // Get initial from display name (same as Hub timeline)
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
    
    return Container(
      width: context.spaces.lg,
      height: context.spaces.lg,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.spaces.xs + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // Default avatar when user data is not available
  Widget _buildDefaultAvatar(AppSpacing spaces) {
    return Container(
      width: spaces.lg,
      height: spaces.lg,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: spaces.xs + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, AppSpacing spaces, ColorScheme colors) {
    final duration = event.endTime.difference(event.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';
    
    // Format time as AM/PM
    final hour = event.startTime.hour;
    final minute = event.startTime.minute;
    final isAM = hour < 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeString = '${displayHour}:${minute.toString().padLeft(2, '0')} ${isAM ? 'AM' : 'PM'}';
    
    // Determine if event is in the past, current, or future
    final now = DateTime.now();
    final isPast = event.startTime.isBefore(now);
    
    // Set vertical bar color based on time status
    final barColor = isPast ? Colors.red : Colors.green;
    
    return Container(
      margin: EdgeInsets.only(bottom: spaces.xs),
      padding: EdgeInsets.symmetric(horizontal: spaces.md, vertical: spaces.sm),
      decoration: BoxDecoration(
        color: Colors.white, // Same white background as calendar
        borderRadius: BorderRadius.circular(spaces.sm),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column (left side)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontSize: spaces.md,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              Text(
                durationText,
                style: TextStyle(
                  fontSize: spaces.sm,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          SizedBox(width: spaces.md),
          
          // Vertical bar (middle)
          Container(
            width: 4,
            height: spaces.xl * 2, // Fixed height for the vertical bar
            margin: EdgeInsets.symmetric(horizontal: spaces.md),
            decoration: BoxDecoration(
              color: barColor, // Red for past, green for current/future
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          SizedBox(width: spaces.md),
          
          // Event details (right side)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event title
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: spaces.md,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Event description (if available)
                if (event.description.isNotEmpty) ...[
                  SizedBox(height: spaces.xs / 2),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: spaces.sm,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Creator avatar underneath
                SizedBox(height: spaces.xs),
                Consumer(
                  builder: (context, ref, child) {
                    final profileAsync = ref.watch(userProfileStreamProvider);
                    return profileAsync.when(
                      data: (profile) {
                        final familyId = profile?.familyId;
                        if (familyId == null) return const SizedBox.shrink();
                        
                        final usersAsync = ref.watch(familyUsersProvider(familyId));
                        return usersAsync.when(
                          data: (users) {
                            // Find the creator user by matching the createdByUid
                            final creator = users.firstWhere(
                              (user) => user.uid == event.createdByUid,
                              orElse: () => users.isNotEmpty ? users.first : UserProfile(
                                uid: event.createdByUid,
                                displayName: 'Unknown',
                                email: '',
                                familyId: familyId,
                                role: UserRole.child,
                                onboarded: false,
                              ),
                            );
                            
                            return _buildEventCreatorAvatar(creator, context);
                          },
                          loading: () => _buildDefaultAvatar(spaces),
                          error: (_, __) => _buildDefaultAvatar(spaces),
                        );
                      },
                      loading: () => _buildDefaultAvatar(spaces),
                                                error: (_, __) => _buildDefaultAvatar(spaces),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
