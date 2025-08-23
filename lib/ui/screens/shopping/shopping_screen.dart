import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.shoppingTitle),
      fixedActions: [
        const Icon(AppIcons.reminder),
        SizedBox(width: spaces.sm),
        const Icon(AppIcons.add),
        SizedBox(width: spaces.sm),
        const Icon(AppIcons.profile),
      ],
      extraActions: const [],
      headerBuilder: (context, controller) {
        return Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: controller.showSearch
                    ? const TextField(
                        key: ValueKey('shopping-search'),
                        decoration: InputDecoration(
                          hintText: AppStrings.searchShoppingHint,
                          prefixIcon: Icon(AppIcons.search),
                          filled: true,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('shopping-filters'),
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(AppIcons.filter),
                            label: const Text('Filters'),
                          ),
                          SizedBox(width: spaces.sm),
                          FilledButton.icon(
                            onPressed: () => controller.toggleSearch(true),
                            icon: const Icon(AppIcons.search),
                            label: const Text('Search'),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > context.spaces.xxl * 20;
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
