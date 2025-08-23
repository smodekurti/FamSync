import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/month_view_new.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_form.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/family/family_repository.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    
    final spaces = context.spaces;
    
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.calendarTitle),
      expandedHeight: _getResponsiveHeaderHeight(context), // Responsive header height
      fixedActions: [
        const Icon(AppIcons.reminder),
        SizedBox(width: spaces.sm),
        const Icon(AppIcons.profile),
        SizedBox(width: spaces.xs),
      ],
      headerBuilder: (context, controller) => _calendarHeader(context, ref),
      body: _buildCalendarBody(context, ref, calendarState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarBody(BuildContext context, WidgetRef ref, CalendarState state) {
    return const MonthViewNew();
  }

  void _showEventForm(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    
    Navigator.of(context).push<EventForm>(
      MaterialPageRoute<EventForm>(
        builder: (context) => EventForm(
          initialDate: selectedDate,
          onSaved: () {
            // Refresh calendar data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event saved successfully!')),
            );
          },
        ),
      ),
    );
  }

  Widget _calendarHeader(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final selectedDate = ref.watch(selectedDateProvider);
    final familyId = ref.watch(userProfileStreamProvider).when(
      data: (profile) => profile?.familyId,
      loading: () => null,
      error: (_, __) => null,
    );
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spaces.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // First line: Date and Time
          Text(
            _formatDateAndTime(now),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: _getResponsiveFontWeight(context),
              fontSize: _getResponsiveFontSize(context, 18, 22, 26),
            ),
          ),
          SizedBox(height: spaces.xs / 2),
          // Second line: Household name and events for the day
          _buildHouseholdEventsInfo(context, ref, familyId, selectedDate),
        ],
      ),
    );
  }







  String _formatDateAndTime(DateTime dateTime) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final dayName = days[dateTime.weekday - 1];
    final monthName = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteString = minute.toString().padLeft(2, '0');
    final timeString = '$displayHour:$minuteString $period';
    final dateString = '$dayName, $monthName $day';
    final fullString = '$dateString • $timeString';
    
    return fullString;
  }

  double _getResponsiveFontSize(BuildContext context, double small, double medium, double large) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spaces = context.spaces;
    
    // Use responsive breakpoints based on design tokens
    if (screenWidth < spaces.xxl * 10) return small;      // Small phones
    if (screenWidth < spaces.xxl * 20) return medium;     // Medium phones
    return large;                                          // Large phones/tablets
  }

  FontWeight _getResponsiveFontWeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spaces = context.spaces;
    
    // Responsive font weights based on screen size
    if (screenWidth < spaces.xxl * 10) return FontWeight.w500;  // Small phones
    if (screenWidth < spaces.xxl * 20) return FontWeight.w600;  // Medium phones
    return FontWeight.w700;                                     // Large phones/tablets
  }

  double _getResponsiveAlpha(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spaces = context.spaces;
    
    // Responsive alpha values for better contrast on different screen sizes
    if (screenWidth < spaces.xxl * 10) return 0.95;  // Small phones - higher contrast
    if (screenWidth < spaces.xxl * 20) return 0.9;   // Medium phones
    return 0.85;                                     // Large phones/tablets - lower contrast
  }

  double _getResponsiveHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spaces = context.spaces;
    
    // Responsive header height based on screen size
    if (screenWidth < spaces.xxl * 10) return spaces.xxl * 5;   // Small phones - compact
    if (screenWidth < spaces.xxl * 20) return spaces.xxl * 6;   // Medium phones - standard
    return spaces.xxl * 7;                                      // Large phones/tablets - spacious
  }

  Widget _buildHouseholdEventsInfo(BuildContext context, WidgetRef ref, String? familyId, DateTime selectedDate) {
    if (familyId == null) return const SizedBox.shrink();
    
    final colors = Theme.of(context).colorScheme;
    
    return Consumer(
      builder: (context, ref, child) {
        final eventsAsync = ref.watch(monthEventsProvider(familyId));
        final familyAsync = ref.watch(familyStreamProvider(familyId));
        final now = DateTime.now();
        
        return eventsAsync.when(
          data: (events) {
            final todayEvents = events.where((event) {
              final eventDate = event.startTime;
              return eventDate.year == now.year &&
                     eventDate.month == now.month &&
                     eventDate.day == now.day;
            }).toList();
            
            final eventText = todayEvents.isEmpty ? 'No Events Today' : '${todayEvents.length} Events Today';
            
            return familyAsync.when(
              data: (family) {
                final householdName = family?.name ?? 'Family';
                final displayText = '$householdName • $eventText';
                return Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: _getResponsiveAlpha(context)),
                    fontWeight: _getResponsiveFontWeight(context),
                    fontSize: _getResponsiveFontSize(context, 14, 16, 18),
                  ),
                );
              },
              loading: () => Text(
                'Loading family info...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onPrimary.withValues(alpha: _getResponsiveAlpha(context)),
                  fontWeight: _getResponsiveFontWeight(context),
                  fontSize: _getResponsiveFontSize(context, 14, 16, 18),
                ),
              ),
              error: (_, __) {
                final displayText = 'Family • $eventText';
                return Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: _getResponsiveAlpha(context)),
                    fontWeight: _getResponsiveFontWeight(context),
                    fontSize: _getResponsiveFontSize(context, 14, 16, 18),
                  ),
                );
              },
            );
          },
          loading: () => Text(
            'Loading events...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: _getResponsiveAlpha(context)),
              fontWeight: _getResponsiveFontWeight(context),
              fontSize: _getResponsiveFontSize(context, 14, 16, 18),
            ),
          ),
          error: (_, __) => Text(
            'Unable to load events',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: _getResponsiveAlpha(context)),
              fontWeight: _getResponsiveFontWeight(context),
              fontSize: _getResponsiveFontSize(context, 14, 16, 18),
            ),
          ),
        );
      },
    );
  }
}
