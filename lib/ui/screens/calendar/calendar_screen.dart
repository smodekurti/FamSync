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

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    
    final spaces = context.spaces;
    
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.calendarTitle),
      expandedHeight: spaces.xxl * 6, // Responsive header height matching Hub
      fixedActions: [
        const Icon(AppIcons.reminder),
        SizedBox(width: spaces.sm),
        const Icon(AppIcons.add),
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First row: Time and Current Date
        Row(
          children: [
            // Current time
            Text(
              _formatTime(now),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: spaces.md),
            // Current date
            Expanded(
              child: Text(
                _formatDate(now),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Quick action buttons
            _buildQuickActionButton(
              context,
              Icons.add,
              'Add Event',
              colors.onPrimary,
              () => _showEventForm(context, ref),
            ),
            SizedBox(width: spaces.xs),
            _buildQuickActionButton(
              context,
              Icons.today,
              'Today',
              colors.onPrimary,
              () => ref.read(calendarNotifierProvider.notifier).goToToday(),
            ),
          ],
        ),
        SizedBox(height: spaces.xs / 2),
        // Second row: Month/Year, Family Info, and Event Count
        Row(
          children: [
            // Month and Year
            Text(
              _formatMonthYear(selectedDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onPrimary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: spaces.md),
            // Family name and event count
            Expanded(
              child: _buildFamilyEventInfo(context, ref, familyId, selectedDate),
            ),
            // View toggle (placeholder for future implementation)
            _buildViewToggleButton(context, colors),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        padding: EdgeInsets.all(context.spaces.xs),
        constraints: BoxConstraints(
          minWidth: context.spaces.lg,
          minHeight: context.spaces.lg,
        ),
      ),
    );
  }

    Widget _buildFamilyEventInfo(BuildContext context, WidgetRef ref, String? familyId, DateTime selectedDate) {
    if (familyId == null) return const SizedBox.shrink();
    
    return Consumer(
      builder: (context, ref, child) {
        final eventsAsync = ref.watch(monthEventsProvider(familyId));
        final now = DateTime.now();
        
        return eventsAsync.when(
          data: (events) {
            final todayEvents = events.where((event) {
              final eventDate = event.startTime;
              return eventDate.year == now.year &&
                     eventDate.month == now.month &&
                     eventDate.day == now.day;
            }).toList();
            
            return Text(
              '${_getFamilyName(context)} - ${todayEvents.isEmpty ? 'No Events Today' : '${todayEvents.length} Events Today'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            );
          },
          loading: () => Text(
            'Loading events...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          error: (_, __) => Text(
            'Unable to load events',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggleButton(BuildContext context, ColorScheme colors) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spaces.sm,
        vertical: context.spaces.xs,
      ),
      decoration: BoxDecoration(
        color: colors.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(context.spaces.sm),
        border: Border.all(
          color: colors.onPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Month',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: context.spaces.xs),
          Icon(
            Icons.keyboard_arrow_down,
            color: colors.onPrimary,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatMonthYear(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getFamilyName(BuildContext context) {
    // This would ideally come from a family provider
    // For now, return a placeholder
    return 'FamSync';
  }
}
