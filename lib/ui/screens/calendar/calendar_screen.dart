import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.calendarTitle),
      fixedActions: const [
        Icon(AppIcons.reminder),
        SizedBox(width: 8),
        Icon(AppIcons.add),
        SizedBox(width: 8),
        Icon(AppIcons.profile),
      ],
      extraActions: const [],
      headerBuilder: (context, controller) => Row(
        children: [
          FilledButton.icon(
            onPressed: () => calendarNotifier.goToToday(),
            icon: const Icon(AppIcons.today),
            label: const Text('Today'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => calendarNotifier.setView(CalendarView.month),
            icon: const Icon(AppIcons.month),
            label: const Text('Month'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => calendarNotifier.setView(CalendarView.week),
            icon: const Icon(AppIcons.week),
            label: const Text('Week'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => calendarNotifier.setView(CalendarView.agenda),
            icon: const Icon(Icons.list),
            label: const Text('Agenda'),
          ),
        ],
      ),
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
