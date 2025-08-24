import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/theme/app_theme.dart';

/// A reusable AppBar scaffold that provides seamless content integration
/// with the header, creating a card-like effect where content overlaps
/// with the gradient background.
/// 
/// This component can be used as an alternative to FamAppBarScaffold
/// when you want the seamless content integration design.
class SeamlessAppBarScaffold extends ConsumerWidget {
  const SeamlessAppBarScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.headerContent,
    this.expandedHeight,
    this.leading,
    this.actions = const <Widget>[],
    this.floatingActionButton,
    this.padding,
    this.gradientColors,
    this.contentOverlap = 80.0, // How much content overlaps with header
    this.headerPadding = const EdgeInsets.all(16.0),
    this.contentBorderRadius = 24.0,
  });

  /// The title displayed in the AppBar
  final Widget title;
  
  /// The main content body of the screen
  final Widget body;
  
  /// Custom content to display in the header area
  final Widget headerContent;
  
  /// Height of the expanded header (defaults to responsive calculation)
  final double? expandedHeight;
  
  /// Leading widget (typically back button)
  final Widget? leading;
  
  /// Action buttons in the AppBar
  final List<Widget> actions;
  
  /// Floating action button
  final Widget? floatingActionButton;
  
  /// Padding around the body content
  final EdgeInsets? padding;
  
  /// Custom gradient colors for the header
  final List<Color>? gradientColors;
  
  /// How much the content overlaps with the header (in pixels)
  final double contentOverlap;
  
  /// Padding around the header content
  final EdgeInsets headerPadding;
  
  /// Border radius for the content cards
  final double contentBorderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use responsive design tokens
    final spaces = context.spaces;
    
    // Calculate responsive header height if not provided
    // Default to 30% of screen height to match the design in the image
    final headerHeight = expandedHeight ?? (MediaQuery.of(context).size.height * 0.3);
    
    // Determine gradient colors based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = isDark 
        ? AppGradients.hubHeaderDark 
        : AppGradients.hubHeaderLight;
    final colors = gradientColors ?? defaultGradient;
    
    // Calculate contrast for text colors
    final bgCollapsed = colors.first;
    final contrast = ThemeData.estimateBrightnessForColor(bgCollapsed);
    final onGradient = contrast == Brightness.dark ? Colors.white : Colors.black;
    
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
          // Header AppBar with gradient background
          SliverAppBar(
            pinned: true,
            expandedHeight: headerHeight,
            elevation: 0,
            backgroundColor: bgCollapsed,
            foregroundColor: onGradient,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(contentBorderRadius),
                bottomRight: Radius.circular(contentBorderRadius),
              ),
            ),
            leading: leading,
            actions: actions,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsetsDirectional.only(
                start: spaces.md,
                bottom: spaces.sm,
              ),
              title: Opacity(
                opacity: _calculateTitleOpacity(headerHeight),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: onGradient),
                  child: title,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(contentBorderRadius),
                    bottomRight: Radius.circular(contentBorderRadius),
                  ),
                ),
                child: Padding(
                  padding: headerPadding,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: headerContent,
                  ),
                ),
              ),
            ),
          ),
          
          // Content area with seamless integration
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -contentOverlap),
              child: Container(
                margin: EdgeInsets.only(
                  left: spaces.md,
                  right: spaces.md,
                  bottom: spaces.lg,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(contentBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(contentBorderRadius),
                  child: Padding(
                    padding: padding ?? EdgeInsets.all(spaces.md),
                    child: body,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates the opacity of the title based on scroll position
  /// This creates a smooth fade effect as the user scrolls
  double _calculateTitleOpacity(double headerHeight) {
    // For now, return a fixed opacity that looks good
    // In a more advanced implementation, this could be dynamic based on scroll
    return 0.9;
  }
}

/// Extension methods for easier usage of SeamlessAppBarScaffold
extension SeamlessAppBarScaffoldExtensions on BuildContext {
  /// Creates a seamless AppBar scaffold with default responsive values
  Widget seamlessAppBarScaffold({
    required Widget title,
    required Widget body,
    required Widget headerContent,
    double? expandedHeight,
    Widget? leading,
    List<Widget> actions = const <Widget>[],
    Widget? floatingActionButton,
    EdgeInsets? padding,
    List<Color>? gradientColors,
    double? contentOverlap,
    EdgeInsets? headerPadding,
    double? contentBorderRadius,
  }) {
    final spaces = this.spaces;
    
    return SeamlessAppBarScaffold(
      title: title,
      body: body,
      headerContent: headerContent,
      expandedHeight: expandedHeight ?? (spaces.xxl * 8), // Use responsive spacing instead
      leading: leading,
      actions: actions,
      floatingActionButton: floatingActionButton,
      padding: padding ?? EdgeInsets.all(spaces.md),
      gradientColors: gradientColors,
      contentOverlap: contentOverlap ?? 80.0,
      headerPadding: headerPadding ?? EdgeInsets.all(spaces.md),
      contentBorderRadius: contentBorderRadius ?? 24.0,
    );
  }
}
