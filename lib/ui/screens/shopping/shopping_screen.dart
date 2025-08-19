import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/widgets/gradient_page_scaffold.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      title: const FamilyAppBarTitle(fallback: 'Shopping & Meals'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Padding(
            padding: EdgeInsets.all(context.spaces.md),
            child: isWide
                ? Row(
                    children: [
                      const Expanded(
                        child: _ListPlaceholder(title: 'Grocery List'),
                      ),
                      SizedBox(width: context.spaces.md),
                      const Expanded(
                        child: _ListPlaceholder(title: 'Meal Planner'),
                      ),
                    ],
                  )
                : ListView(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const _ListPlaceholder(title: 'Grocery List'),
                      SizedBox(height: context.spaces.md),
                      const _ListPlaceholder(title: 'Meal Planner'),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}

class _ListPlaceholder extends StatelessWidget {
  const _ListPlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: context.sizes.cardMinHeight,
        child: Center(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}
