import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/widgets/gradient_page_scaffold.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      title: const FamilyAppBarTitle(fallback: 'Calendar'),
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


