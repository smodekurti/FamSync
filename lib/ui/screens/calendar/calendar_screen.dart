import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';


import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/month_view_new.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/week_view.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/agenda_view.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_form.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    
    final spaces = context.spaces;
    
    return Scaffold(
      appBar: AppBar(
        title: const FamilyAppBarTitle(fallback: AppStrings.calendarTitle),
        actions: [
          const Icon(AppIcons.reminder),
          SizedBox(width: spaces.xs),
          const Icon(AppIcons.add),
          SizedBox(width: spaces.xs),
          const Icon(AppIcons.profile),
        ],
        // Adjust height to prevent overflow issues
        toolbarHeight: spaces.xl * 2.5, // Responsive height
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(spaces.md),
          child: Container(
            height: spaces.md,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildCalendarBody(context, ref, calendarState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarBody(BuildContext context, WidgetRef ref, CalendarState state) {
    try {
      switch (state.currentView) {
        case CalendarView.month:
          return const MonthViewNew();
        case CalendarView.week:
          return const WeekView();
        case CalendarView.day:
          return const Center(child: Text('Day view coming soon'));
        case CalendarView.agenda:
          return const AgendaView();
      }
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Error loading calendar view'),
            SizedBox(height: 8),
            Text('Please try again', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
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


}
