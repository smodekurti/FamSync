import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';

import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/month_view.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/week_view.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/agenda_view.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_form.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
    
    final spaces = context.spaces;
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.calendarTitle),
      fixedActions: [
        const Icon(AppIcons.reminder),
        SizedBox(width: spaces.xs),
        const Icon(AppIcons.add),
        SizedBox(width: spaces.xs),
        const Icon(AppIcons.profile),
      ],
      extraActions: const [],
      headerBuilder: (context, controller) {
        final spaces = context.spaces;
        return Wrap(
          spacing: spaces.sm,
          runSpacing: spaces.sm,
          alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => calendarNotifier.goToToday(),
            icon: Icon(AppIcons.today, size: spaces.md),
            label: Text('Today', style: TextStyle(fontSize: spaces.xs + 1)),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => calendarNotifier.setView(CalendarView.month),
            icon: Icon(AppIcons.month, size: spaces.md),
            label: Text('Month', style: TextStyle(fontSize: spaces.xs + 1)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => calendarNotifier.setView(CalendarView.week),
            icon: Icon(AppIcons.week, size: spaces.md),
            label: Text('Week', style: TextStyle(fontSize: spaces.xs + 1)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => calendarNotifier.setView(CalendarView.agenda),
            icon: Icon(Icons.list, size: spaces.md),
            label: Text('Agenda', style: TextStyle(fontSize: spaces.xs + 1)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
            ),
          ),
        ],
        );
      },
      body: _buildCalendarBody(context, ref, calendarState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarBody(BuildContext context, WidgetRef ref, CalendarState state) {
    switch (state.currentView) {
      case CalendarView.month:
        return const MonthView();
      case CalendarView.week:
        return const WeekView();
      case CalendarView.day:
        return const Center(child: Text('Day view coming soon'));
      case CalendarView.agenda:
        return const AgendaView();
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
