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
    final selectedDate = ref.watch(selectedDateProvider);
    final familyId = ref.watch(userProfileStreamProvider).when(
      data: (profile) => profile?.familyId,
      loading: () => null,
      error: (_, __) => null,
    );
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spaces.sm),
      child: Row(
        children: [
          // Calendar-specific context
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary: Family event summary
                _buildFamilyEventInfo(context, ref, familyId, selectedDate),
                if (familyId != null) SizedBox(height: spaces.xs / 2),
                // Secondary: Selected date context (if different from today)
                if (!_isToday(selectedDate))
                  Text(
                    'Viewing ${_formatSelectedDate(selectedDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          // Calendar actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickActionButton(
                context,
                Icons.today,
                'Go to Today',
                colors.onPrimary,
                () => ref.read(calendarNotifierProvider.notifier).goToToday(),
              ),
              SizedBox(width: spaces.sm),
              _buildViewToggleButton(context, colors),
            ],
          ),
        ],
      ),
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
      child: SizedBox(
        width: context.spaces.xl,
        height: context.spaces.xl,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color, size: 20),
          padding: EdgeInsets.all(context.spaces.xs / 2),
          constraints: BoxConstraints(
            maxWidth: context.spaces.xl,
            maxHeight: context.spaces.xl,
          ),
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
      constraints: BoxConstraints(
        minWidth: context.spaces.xl * 2.5,
        maxWidth: context.spaces.xl * 3.5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spaces.sm,
        vertical: context.spaces.xs / 2,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Month',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(width: context.spaces.xs / 2),
          Icon(
            Icons.keyboard_arrow_down,
            color: colors.onPrimary,
            size: 14,
          ),
        ],
      ),
    );
  }



  String _getFamilyName(BuildContext context) {
    // This would ideally come from a family provider
    // For now, return a placeholder
    return 'FamSync';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _formatSelectedDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
