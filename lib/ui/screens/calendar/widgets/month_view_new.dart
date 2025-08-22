import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'dart:ui';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/domain/models/user_profile.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/users/users_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_form.dart';

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
    
    return Column(
      children: [
        // Calendar widget - simplified structure
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spaces.xs,
            vertical: spaces.sm,
          ),
          child: Calendar(
            startOnMonday: true,
            weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            eventsList: calendarEvents,
            initialDate: selectedDate,
            isExpandable: true,
            isExpanded: false,
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
              backgroundColor: Colors.white,
            ),
            bottomBarColor: colors.surfaceContainerHighest,
            bottomBarArrowColor: colors.onSurfaceVariant,
            eventTileHeight: null,
            onDateSelected: (date) {
              ref.read(calendarNotifierProvider.notifier).setSelectedDate(date);
            },
            onMonthChanged: (date) {
              print('📅 Month changed to: ${date.year}-${date.month}');
              // Update the current month provider to trigger stream rebuild
              ref.read(currentMonthProvider.notifier).state = date;
              print('📅 Updated currentMonthProvider to: ${date.year}-${date.month}');
              
              // Force a rebuild by invalidating the provider
              final currentFamilyId = ref.read(userProfileStreamProvider).when(
                data: (profile) => profile?.familyId,
                loading: () => null,
                error: (_, __) => null,
              );
              if (currentFamilyId != null) {
                print('📅 Force invalidating monthEventsProvider for family: $currentFamilyId');
                ref.invalidate(monthEventsProvider(currentFamilyId));
              }
            },
            onEventSelected: (calendarEvent) {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Event Selected'),
                  content: const Text('Tap on individual event cards to edit or delete them.'),
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
            showEvents: false,
            forceEventListView: false,
            showEventListViewIcon: false,
          ),
        ),
        
        // Custom event list for selected date
        Builder(
          builder: (context) {
            // Filter events for the selected date only
            final selectedDateEvents = events.where((event) {
              final eventDate = event.startTime;
              return eventDate.year == selectedDate.year &&
                     eventDate.month == selectedDate.month &&
                     eventDate.day == selectedDate.day;
            }).toList();
            
            // Debug logging for date filtering
            if (kDebugMode) {
              print('📅 Selected date: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}');
              print('📅 Total month events: ${events.length}');
              print('📅 Events for selected date: ${selectedDateEvents.length}');
              if (selectedDateEvents.isNotEmpty) {
                print('📅 Selected date events: ${selectedDateEvents.map((e) => '${e.title} on ${e.startTime}').join(', ')}');
              }
            }
            
            if (selectedDateEvents.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5FC),
                borderRadius: BorderRadius.circular(spaces.sm),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.all(spaces.sm),
                itemCount: selectedDateEvents.length,
                itemBuilder: (context, index) => _buildEventCard(context, selectedDateEvents[index], spaces, colors, ref),
              ),
            );
          },
        ),
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

  // Get priority color for chips
  Color _getPriorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.urgent:
        return Colors.red;
      case EventPriority.high:
        return Colors.orange;
      case EventPriority.medium:
        return Colors.blue;
      case EventPriority.low:
        return Colors.grey;
    }
  }

  // Get month name for display
  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
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

  Widget _buildEventCard(BuildContext context, Event event, AppSpacing spaces, ColorScheme colors, WidgetRef ref) {
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
    
    return GestureDetector(
      onTap: () => _showEventActions(context, ref, event),
      child: Container(
        margin: EdgeInsets.only(bottom: spaces.xs),
        padding: EdgeInsets.symmetric(horizontal: spaces.md, vertical: spaces.sm),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F5FC), // Light lavender background #f9f5fc
          borderRadius: BorderRadius.circular(spaces.sm),
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
    ));
  }

  // Show event actions bottom sheet with edit and delete options
  void _showEventActions(BuildContext context, WidgetRef ref, Event event) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    // Format event details
    final startTime = TimeOfDay.fromDateTime(event.startTime);
    final endTime = TimeOfDay.fromDateTime(event.endTime);
    final duration = event.endTime.difference(event.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';
    final dateText = '${event.startTime.day} ${_getMonthName(event.startTime.month)} ${event.startTime.year}';
    
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spaces.xl),
              topRight: Radius.circular(spaces.xl),
            ),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced handle bar
              Container(
                width: spaces.xl * 4,
                height: spaces.xs * 1.5,
                margin: EdgeInsets.symmetric(vertical: spaces.md),
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(spaces.xs),
                ),
              ),
              
              // Event header with gradient background
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(spaces.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.1),
                      colors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(spaces.xl),
                    topRight: Radius.circular(spaces.xl),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event icon and title row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(spaces.sm),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(spaces.md),
                          ),
                          child: Icon(
                            Icons.event,
                            color: colors.onPrimary,
                            size: spaces.lg,
                          ),
                        ),
                        SizedBox(width: spaces.md),
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: spaces.lg + 2,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: spaces.md),
                    
                    // Event category and priority chips
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spaces.sm,
                            vertical: spaces.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventColor(event.category, event.priority).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(spaces.sm),
                            border: Border.all(
                              color: _getEventColor(event.category, event.priority).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            event.category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: spaces.xs,
                              fontWeight: FontWeight.w600,
                              color: _getEventColor(event.category, event.priority),
                            ),
                          ),
                        ),
                        SizedBox(width: spaces.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spaces.sm,
                            vertical: spaces.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(event.priority).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(spaces.sm),
                            border: Border.all(
                              color: _getPriorityColor(event.priority).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            event.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: spaces.xs,
                              fontWeight: FontWeight.w600,
                              color: _getPriorityColor(event.priority),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Event details section
              Padding(
                padding: EdgeInsets.all(spaces.lg),
                child: Column(
                  children: [
                    // Date and time details
                    Container(
                      padding: EdgeInsets.all(spaces.md),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(spaces.md),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Date row
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: colors.primary,
                                size: spaces.md,
                              ),
                              SizedBox(width: spaces.sm),
                              Text(
                                dateText,
                                style: TextStyle(
                                  fontSize: spaces.md,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: spaces.sm),
                          
                          // Time row
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: colors.primary,
                                size: spaces.md,
                              ),
                              SizedBox(width: spaces.sm),
                              Text(
                                '${startTime.format(context)} - ${endTime.format(context)}',
                                style: TextStyle(
                                  fontSize: spaces.md,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                              SizedBox(width: spaces.md),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: spaces.xs,
                                  vertical: spaces.xs / 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(spaces.xs),
                                ),
                                child: Text(
                                  durationText,
                                  style: TextStyle(
                                    fontSize: spaces.xs,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Description section (if available)
                    if (event.description.isNotEmpty) ...[
                      SizedBox(height: spaces.md),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(spaces.md),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(spaces.md),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  color: colors.primary,
                                  size: spaces.md,
                                ),
                                SizedBox(width: spaces.sm),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: spaces.md,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spaces.sm),
                            Text(
                              event.description,
                              style: TextStyle(
                                fontSize: spaces.sm,
                                color: colors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: spaces.lg),
                    
                    // Action buttons with enhanced styling
                    Row(
                      children: [
                        // Edit button
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _editEvent(context, ref, event);
                            },
                            icon: Icon(Icons.edit, size: spaces.md),
                            label: Text(
                              'Edit Event',
                              style: TextStyle(
                                fontSize: spaces.md,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: spaces.lg,
                                vertical: spaces.md + 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(spaces.md),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: spaces.md),
                        
                        // Delete button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showDeleteConfirmation(context, ref, event);
                            },
                            icon: Icon(Icons.delete_outline, size: spaces.md, color: colors.error),
                            label: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: spaces.md,
                                fontWeight: FontWeight.w600,
                                color: colors.error,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: spaces.lg,
                                vertical: spaces.md + 2,
                              ),
                              side: BorderSide(color: colors.error, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(spaces.md),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: spaces.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
        )
    );
  }

  // Edit event functionality
  void _editEvent(BuildContext context, WidgetRef ref, Event event) {
    // Navigate to event form with pre-filled data
    Navigator.of(context).push<EventForm>(
      MaterialPageRoute<EventForm>(
        builder: (context) => EventForm(
          initialDate: event.startTime,
          event: event, // Pass the event to edit
          onSaved: () {
            // Refresh calendar data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event updated successfully!')),
            );
          },
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Event event) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spaces.lg),
          ),
          backgroundColor: colors.surface.withValues(alpha: 0.9),
          elevation: 20,
        title: Container(
          padding: EdgeInsets.all(spaces.md),
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(spaces.md),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(spaces.sm),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: BorderRadius.circular(spaces.sm),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: colors.onError,
                  size: spaces.lg,
                ),
              ),
              SizedBox(width: spaces.md),
              Expanded(
                child: Text(
                  'Delete Event',
                  style: TextStyle(
                    fontSize: spaces.lg,
                    fontWeight: FontWeight.w700,
                    color: colors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: EdgeInsets.symmetric(vertical: spaces.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this event?',
                style: TextStyle(
                  fontSize: spaces.md,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: spaces.sm),
              Container(
                padding: EdgeInsets.all(spaces.md),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(spaces.sm),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: colors.primary,
                      size: spaces.md,
                    ),
                    SizedBox(width: spaces.sm),
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          fontSize: spaces.md,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spaces.sm),
              Text(
                'This action cannot be undone and will permanently remove the event from your calendar.',
                style: TextStyle(
                  fontSize: spaces.sm,
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(spaces.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: spaces.lg,
                        vertical: spaces.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(spaces.md),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: spaces.md,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spaces.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteEvent(context, ref, event);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      padding: EdgeInsets.symmetric(
                        horizontal: spaces.lg,
                        vertical: spaces.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(spaces.md),
                      ),
                    ),
                    child: Text(
                      'Delete Event',
                      style: TextStyle(
                        fontSize: spaces.md,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        )
    );
  }

  // Delete event functionality
  void _deleteEvent(BuildContext context, WidgetRef ref, Event event) {
    final eventsRepository = ref.read(eventsRepositoryProvider);
    
    eventsRepository.deleteEvent(event.id).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event "${event.title}" deleted successfully'),
          backgroundColor: context.colors.primary,
        ),
      );
      
      // Refresh the calendar data
      ref.invalidate(monthEventsProvider);
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: $error'),
          backgroundColor: context.colors.error,
        ),
      );
    });
  }

  // Helper method to get category color
  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.family:
        return Colors.green;
      case EventCategory.work:
        return Colors.blue;
      case EventCategory.personal:
        return Colors.purple;
      case EventCategory.medical:
        return Colors.red;
      case EventCategory.school:
        return Colors.orange;
      case EventCategory.sports:
        return Colors.pink;
      case EventCategory.travel:
        return Colors.teal;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  // Helper method to get category icon
  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.family:
        return Icons.family_restroom;
      case EventCategory.work:
        return Icons.work;
      case EventCategory.personal:
        return Icons.person;
      case EventCategory.medical:
        return Icons.health_and_safety;
      case EventCategory.school:
        return Icons.school;
      case EventCategory.sports:
        return Icons.sports_soccer;
      case EventCategory.travel:
        return Icons.flight;
      case EventCategory.other:
        return Icons.event;
    }
  }

  // Helper method to format time
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  // Helper method to calculate duration
  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }
}
