import 'package:flutter/material.dart';

import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/icons.dart';

class GradientPageScaffold extends StatelessWidget {
  const GradientPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.expandedHeight = 240,
    this.floatingActionButton,
    this.padding,
    this.onReminder,
    this.onAdd,
    this.onProfile,
    this.includeDefaultActions = true,
    this.headerContent,
    this.headerScrollable = true,
    this.headerPinned = false,
  });

  final Widget title;
  final Widget body;
  final List<Widget> actions;
  final double expandedHeight;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;
  final VoidCallback? onReminder;
  final VoidCallback? onAdd;
  final VoidCallback? onProfile;
  final bool includeDefaultActions;
  final Widget? headerContent;
  final bool headerScrollable;
  final bool headerPinned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isDark
        ? AppGradients.hubHeaderDark
        : AppGradients.hubHeaderLight;
    final Color gradientStart = gradientColors.first;
    final Brightness contrast = ThemeData.estimateBrightnessForColor(
      gradientStart,
    );
    final Color onGradient = contrast == Brightness.dark
        ? Colors.white
        : Colors.black;

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
            foregroundColor: onGradient,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            actions: [
              if (includeDefaultActions) ...[
                IconButton(
                  onPressed: onReminder,
                  icon: const Icon(AppIcons.reminder),
                ),
                IconButton(onPressed: onAdd, icon: const Icon(AppIcons.add)),
                IconButton(
                  onPressed: onProfile,
                  icon: const Icon(AppIcons.profile),
                ),
              ],
              ...actions.map(
                (w) => IconTheme.merge(
                  data: IconThemeData(color: onGradient),
                  child: w,
                ),
              ),
            ],
            title: null,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              title: _CollapsingTitle(
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: onGradient),
                  child: title,
                ),
              ),
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 12,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
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
                  if (headerContent != null && !headerPinned)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 64,
                      height: context.sizes.touchTarget,
                      child: headerScrollable
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: headerContent!,
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: headerContent,
                            ),
                    ),
                ],
              ),
            ),
            bottom: headerContent == null || !headerPinned
                ? null
                : PreferredSize(
                    preferredSize: Size.fromHeight(context.sizes.touchTarget),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: headerScrollable
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: headerContent!,
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: headerContent,
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

class _CollapsingTitle extends StatelessWidget {
  const _CollapsingTitle({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    if (settings == null) return child;
    final delta = settings.maxExtent - settings.minExtent;
    final t =
        (settings.currentExtent - settings.minExtent) /
        (delta == 0 ? 1 : delta);
    // Show title only when sufficiently collapsed
    final opacity = 1.0 - t.clamp(0.0, 1.0);
    return Opacity(opacity: opacity, child: child);
  }
}
