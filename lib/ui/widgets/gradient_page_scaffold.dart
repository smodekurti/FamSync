import 'package:flutter/material.dart';

import 'package:fam_sync/theme/tokens.dart';

class GradientPageScaffold extends StatelessWidget {
  const GradientPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.expandedHeight = 180,
    this.floatingActionButton,
    this.padding,
  });

  final Widget title;
  final Widget body;
  final List<Widget> actions;
  final double expandedHeight;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onPrimary = theme.colorScheme.onPrimary;
    final gradientColors = isDark
        ? AppGradients.hubHeaderDark
        : AppGradients.hubHeaderLight;

    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            elevation: 0,
            backgroundColor: gradientColors.first,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            foregroundColor: onPrimary,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            actions: [
              ...actions.map(
                (w) => IconTheme.merge(
                  data: IconThemeData(color: onPrimary),
                  child: w,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              title: DefaultTextStyle.merge(
                style: TextStyle(color: onPrimary),
                child: title,
              ),
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 12,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: padding ?? const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: body),
          ),
        ],
      ),
    );
  }
}
