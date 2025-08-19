import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: Padding(
        padding: EdgeInsets.all(context.spaces.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 380;
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
                Expanded(
                  child: Card(
                    child: Center(
                      child: Text(
                        isCompact ? 'Summary view' : 'Charts and breakdown (tablet/landscape)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                )
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
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}


