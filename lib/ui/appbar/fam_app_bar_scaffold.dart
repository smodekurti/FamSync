import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_controller.dart';

final _famAppBarControllerProvider =
    ChangeNotifierProvider.autoDispose<FamAppBarController>(
      (ref) => FamAppBarController(),
    );

class FamAppBarScaffold extends ConsumerWidget {
  const FamAppBarScaffold({
    super.key,
    required this.title,
    required this.body,
    this.expandedHeight = 240,
    this.leading,
    this.fixedActions = const <Widget>[],
    this.extraActions = const <Widget>[],
    this.backgroundBuilder,
    this.headerBuilder,
    this.bottomBuilder,
    this.floatingActionButton,
    this.padding,
  });

  final Widget title;
  final Widget body;
  final double expandedHeight;
  final Widget? leading;
  final List<Widget> fixedActions;
  final List<Widget> extraActions;
  final Widget Function(BuildContext, double, double)? backgroundBuilder;
  final Widget Function(BuildContext, FamAppBarController)? headerBuilder;
  final PreferredSizeWidget Function(BuildContext, FamAppBarController)?
  bottomBuilder;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_famAppBarControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors =
        isDark ? AppGradients.hubHeaderDark : AppGradients.hubHeaderLight;
    final Color bgCollapsed = gradientColors.first;
    final Brightness contrast = ThemeData.estimateBrightnessForColor(bgCollapsed);
    final Color onGradient = contrast == Brightness.dark ? Colors.white : Colors.black;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            elevation: 0,
            backgroundColor: bgCollapsed,
            foregroundColor: onGradient,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            leading: leading,
            actions: [...fixedActions, ...extraActions],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final max = constraints.biggest.height;
                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 16,
                    bottom: 12,
                  ),
                  title: Opacity(
                    opacity: _titleOpacity(max, kToolbarHeight),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: onGradient),
                      child: title,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backgroundBuilder != null)
                        backgroundBuilder!(context, max, expandedHeight)
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppGradients.hubHeaderDark
                                  : AppGradients.hubHeaderLight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                        ),
                      if (headerBuilder != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 64,
                          child: SizedBox(
                            height: AppSizes(context.layout).touchTarget + 24,
                            child: headerBuilder!(context, controller),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            bottom: bottomBuilder == null
                ? null
                : bottomBuilder!(context, controller),
          ),
          SliverPadding(
            padding: padding ?? const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: body),
          ),
        ],
      ),
    );
  }

  double _titleOpacity(double current, double min) {
    final delta = expandedHeight - min;
    final t = (current - min) / (delta == 0 ? 1 : delta);
    return (1.0 - t).clamp(0.0, 1.0);
  }
}
