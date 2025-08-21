import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';

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
        final layout = context.layout;
        final colors = context.colors;
        
        return Column(
          children: [
            // Today button - separate and prominent
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: spaces.md),
              child: FilledButton.icon(
                onPressed: () => calendarNotifier.goToToday(),
                icon: Icon(AppIcons.today, size: spaces.lg),
                label: Text(
                  'Go to Today', 
                  style: TextStyle(
                    fontSize: layout.isSmall ? spaces.sm : spaces.md,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: spaces.lg,
                    vertical: layout.isSmall ? spaces.sm : spaces.md,
                  ),
                  minimumSize: Size(double.infinity, layout.isSmall ? spaces.xl * 1.5 : spaces.xl * 2),
                ),
              ),
            ),
            
            // View filter buttons - segmented control style
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(spaces.md),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: layout.isSmall 
                ? _buildCompactViewSelector(context, spaces, colors, calendarState, calendarNotifier)
                : _buildExpandedViewSelector(context, spaces, colors, calendarState, calendarNotifier),
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

  // Compact view selector for small screens (horizontal scrollable)
  Widget _buildCompactViewSelector(
    BuildContext context, 
    AppSpacing spaces, 
    ColorScheme colors, 
    CalendarState calendarState, 
    CalendarNotifier calendarNotifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(spaces.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(
            context, spaces, colors, calendarState, calendarNotifier,
            view: CalendarView.month,
            icon: AppIcons.month,
            label: 'Month',
          ),
          SizedBox(width: spaces.xs),
          _buildViewButton(
            context, spaces, colors, calendarState, calendarNotifier,
            view: CalendarView.week,
            icon: AppIcons.week,
            label: 'Week',
          ),
          SizedBox(width: spaces.xs),
          _buildViewButton(
            context, spaces, colors, calendarState, calendarNotifier,
            view: CalendarView.agenda,
            icon: Icons.list,
            label: 'Agenda',
          ),
        ],
      ),
    );
  }

  // Expanded view selector for larger screens (full width segmented)
  Widget _buildExpandedViewSelector(
    BuildContext context, 
    AppSpacing spaces, 
    ColorScheme colors, 
    CalendarState calendarState, 
    CalendarNotifier calendarNotifier,
  ) {
    return Padding(
      padding: EdgeInsets.all(spaces.xs),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton(
              context, spaces, colors, calendarState, calendarNotifier,
              view: CalendarView.month,
              icon: AppIcons.month,
              label: 'Month',
            ),
          ),
          SizedBox(width: spaces.xs),
          Expanded(
            child: _buildViewButton(
              context, spaces, colors, calendarState, calendarNotifier,
              view: CalendarView.week,
              icon: AppIcons.week,
              label: 'Week',
            ),
          ),
          SizedBox(width: spaces.xs),
          Expanded(
            child: _buildViewButton(
              context, spaces, colors, calendarState, calendarNotifier,
              view: CalendarView.agenda,
              icon: Icons.list,
              label: 'Agenda',
            ),
          ),
        ],
      ),
    );
  }

  // Individual view button with proper selected state
  Widget _buildViewButton(
    BuildContext context, 
    AppSpacing spaces, 
    ColorScheme colors, 
    CalendarState calendarState, 
    CalendarNotifier calendarNotifier, {
    required CalendarView view,
    required IconData icon,
    required String label,
  }) {
    final isSelected = calendarState.currentView == view;
    final layout = context.layout;
    
    return Material(
      color: isSelected ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(spaces.sm),
      child: InkWell(
        onTap: () => calendarNotifier.setView(view),
        borderRadius: BorderRadius.circular(spaces.sm),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: layout.isSmall ? spaces.sm : spaces.md,
            vertical: layout.isSmall ? spaces.sm : spaces.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: layout.isSmall ? spaces.lg : spaces.xl,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              SizedBox(height: spaces.xs / 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: layout.isSmall ? spaces.xs + 1 : spaces.sm,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
