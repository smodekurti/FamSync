import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/theme/responsive.dart';
import 'package:fam_sync/theme/tokens.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize fade animation for smooth entrance
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Initialize progress animation for loading bar
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Create progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _progressController.forward();
    
    // Navigate to login after animation completes
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isDisposed) {
        _navigateToLogin();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    if (!_isDisposed && mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context, const AppBreakpoints());
    final spaces = AppSpacing(layout);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A0DAD), // Deep purple
              Color(0xFF8A2BE2), // Medium purple
              Color(0xFF4169E1), // Royal blue
              Color(0xFF1E90FF), // Dodger blue
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating decorative circles background
            _buildFloatingCircles(),
            
            // Main content
            SafeArea(
              child: layout.isLarge 
                ? _buildDesktopLayout(context, spaces, layout)
                : _buildMobileLayout(context, spaces, layout),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCircles() {
    return Stack(
      children: [
        // Large circle top left
        Positioned(
          top: 100,
          left: 50,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Medium circle top right
        Positioned(
          top: 80,
          right: 80,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Small circle center left
        Positioned(
          top: 300,
          left: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Medium circle bottom right
        Positioned(
          bottom: 150,
          right: 60,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Small circle bottom left
        Positioned(
          bottom: 100,
          left: 100,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppSpacing spaces, AppLayout layout) {
    return Row(
      children: [
        // Left side - Splash/Info Section
        Expanded(
          flex: 1,
          child: _buildSplashSection(context, spaces, layout),
        ),
        
        // Right side - Login Section
        Expanded(
          flex: 1,
          child: _buildLoginPreviewSection(context, spaces, layout),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppSpacing spaces, AppLayout layout) {
    return Column(
      children: [
        // Top section - Splash/Info
        Expanded(
          flex: 2,
          child: _buildSplashSection(context, spaces, layout),
        ),
        
        // Bottom section - Login Preview
        Expanded(
          flex: 1,
          child: _buildLoginPreviewSection(context, spaces, layout),
        ),
      ],
    );
  }

  Widget _buildSplashSection(BuildContext context, AppSpacing spaces, AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(spaces.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo and Title
          if (!_isDisposed)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Main Logo with circular background
                      Container(
                        width: layout.isSmall ? spaces.xxl * 5 : spaces.xxl * 7,
                        height: layout.isSmall ? spaces.xxl * 5 : spaces.xxl * 7,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.family_restroom,
                          size: layout.isSmall ? spaces.xxl * 2.5 : spaces.xxl * 3.5,
                          color: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: spaces.xl),
                      
                      // App Title
                      Text(
                        'FamilyHub',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: layout.isSmall ? 32 : 48,
                          letterSpacing: -1.0,
                        ),
                      ),
                      
                      SizedBox(height: spaces.md),
                      
                      // Tagline
                      Text(
                        'Your family, connected',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                          fontSize: layout.isSmall ? 18 : 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          
          SizedBox(height: spaces.xxl),
          
          // Feature Showcase
          if (!_isDisposed)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Feature Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(context, Icons.event, 'Events', spaces),
                          _buildFeatureItem(context, Icons.check_circle_outline, 'Tasks', spaces),
                          _buildFeatureItem(context, Icons.location_on_outlined, 'Location', spaces),
                          _buildFeatureItem(context, Icons.shopping_cart_outlined, 'Shopping', spaces),
                        ],
                      ),
                      
                      SizedBox(height: spaces.xxl),
                      
                      // Loading Section
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: spaces.lg,
                              ),
                              SizedBox(width: spaces.sm),
                              Text(
                                'Almost ready...',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: spaces.md),
                          
                          // Progress Bar
                          Container(
                            width: double.infinity,
                            height: spaces.sm,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(spaces.sm),
                            ),
                            child: Stack(
                              children: [
                                // Progress Fill
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _progressAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(spaces.sm),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: spaces.sm),
                          
                          // Progress Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Loading...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${(_progressAnimation.value * 100).round()}%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          
          const Spacer(),
          
          // Bottom Info
          if (!_isDisposed)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Version
                      Text(
                        'Version 2.1.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      
                      SizedBox(height: spaces.md),
                      
                      // App Attributes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAttributeItem(context, Icons.security, 'Secure', spaces),
                          _buildAttributeItem(context, Icons.favorite, 'Family-first', spaces),
                          _buildAttributeItem(context, Icons.flash_on, 'Fast', spaces),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPreviewSection(BuildContext context, AppSpacing spaces, AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(spaces.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          if (!_isDisposed)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // App Icon
                      Container(
                        width: spaces.xxl * 2,
                        height: spaces.xxl * 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(spaces.md),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.family_restroom,
                          size: spaces.xxl,
                          color: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: spaces.lg),
                      
                      // Welcome Message
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: layout.isSmall ? 24 : 32,
                        ),
                      ),
                      
                      SizedBox(height: spaces.sm),
                      
                      Text(
                        'Sign in to your FamilyHub account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          
          SizedBox(height: spaces.xxl),
          
          // User Avatars with overlapping effect
          if (!_isDisposed)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: SizedBox(
                    height: (layout.isSmall ? spaces.lg : spaces.xl) * 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // First avatar (leftmost)
                        Positioned(
                          left: 0,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: layout.isSmall ? spaces.lg : spaces.xl,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: layout.isSmall ? spaces.md : spaces.lg,
                                ),
                              ),
                              // Green online indicator
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Second avatar (center)
                        Positioned(
                          left: (layout.isSmall ? spaces.lg : spaces.xl) * 1.5,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: layout.isSmall ? spaces.lg : spaces.xl,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: layout.isSmall ? spaces.md : spaces.lg,
                                ),
                              ),
                              // Green online indicator
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          const Spacer(),
          
          // Bottom App Attributes
          if (!_isDisposed)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAttributeItem(context, Icons.security, 'Secure', spaces),
                      _buildAttributeItem(context, Icons.phone_android, 'Mobile-first', spaces),
                      _buildAttributeItem(context, Icons.family_restroom, 'Family-safe', spaces),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String label, AppSpacing spaces) {
    return Column(
      children: [
        Container(
          width: spaces.xxl * 2,
          height: spaces.xxl * 2,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: spaces.xl,
          ),
        ),
        SizedBox(height: spaces.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeItem(BuildContext context, IconData icon, String label, AppSpacing spaces) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: spaces.sm,
        ),
        SizedBox(width: spaces.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
