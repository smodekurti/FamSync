import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            icon: const Icon(AppIcons.today),
            label: const Text('Today'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(AppIcons.month),
            label: const Text('Month'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(AppIcons.week),
            label: const Text('Week'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(context.spaces.md),
        child: Center(
          child: Text(
            'Shared Master Calendar (month/week/agenda views) — coming soon',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
