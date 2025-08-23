import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.financeTitle),
      fixedActions: [
        const Icon(AppIcons.reminder),
        SizedBox(width: spaces.sm),
        const Icon(AppIcons.add),
        SizedBox(width: spaces.sm),
        const Icon(AppIcons.profile),
      ],
      extraActions: const [],
      headerBuilder: (context, controller) => Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(AppIcons.calendar),
            label: const Text(AppStrings.filterThisMonth),
          ),
          SizedBox(width: spaces.sm),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(AppIcons.summary),
            label: const Text(AppStrings.filterSummary),
          ),
          SizedBox(width: spaces.sm),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: controller.showSearch
                  ? const TextField(
                      key: ValueKey('finance-search'),
                      decoration: InputDecoration(
                        hintText: AppStrings.searchFinanceHint,
                        prefixIcon: Icon(AppIcons.search),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => controller.toggleSearch(true),
                        icon: const Icon(AppIcons.search),
                        label: const Text('Search'),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(context.spaces.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < context.spaces.xxl * 12;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: context.spaces.sm,
                  spacing: context.spaces.sm,
                  children: const [
                    _StatCard(title: 'This Month', value: '\$1,245'),
                    _StatCard(title: 'Upcoming Bills', value: '4'),
                    _StatCard(title: 'Allowances', value: '\$75'),
                  ],
                ),
                SizedBox(height: context.spaces.lg),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(context.spaces.lg),
                    child: Center(
                      child: Text(
                        isCompact
                            ? 'Summary view'
                            : 'Charts and breakdown (tablet/landscape)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.sizes.statCardWidth,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(context.spaces.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: context.spaces.sm),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
