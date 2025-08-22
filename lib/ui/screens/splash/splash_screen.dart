import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textSlide;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale and rotation animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text slide animation
    _textSlide = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _startSplashSequence() async {
    // Start logo animation
    await _logoController.forward();
    
    // Start text animation
    await _textController.forward();
    
    // Start fade animation
    await _fadeController.forward();
    
    // Wait a bit more for user to see the complete animation
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    // Check authentication state and navigate accordingly
    _navigateBasedOnAuthState();
  }

  void _navigateBasedOnAuthState() {
    // Use the authStateProvider to check current authentication state
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          // User is already signed in, go to main app
          context.go('/hub');
        } else {
          // User needs to sign in, go to auth screen
          context.go('/auth');
        }
      },
      loading: () {
        // Still loading, wait a bit more
        Future<void>.delayed(const Duration(milliseconds: 500), _navigateBasedOnAuthState);
      },
      error: (_, __) {
        // Error occurred, go to auth screen
        context.go('/auth');
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    final layout = context.layout;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primaryContainer,
              colors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value * 0.1,
                        child: Container(
                          width: layout.isSmall ? spaces.xxl * 6 : spaces.xxl * 8,
                          height: layout.isSmall ? spaces.xxl * 6 : spaces.xxl * 8,
                          decoration: BoxDecoration(
                            color: colors.onPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.onPrimary.withValues(alpha: 0.3),
                                blurRadius: layout.isSmall ? spaces.xl : spaces.xl * 2,
                                spreadRadius: spaces.sm,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.family_restroom,
                            size: layout.isSmall ? spaces.xxl * 3 : spaces.xxl * 4,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: layout.isSmall ? spaces.xxl : spaces.xxl * 2),
                
                // App Name
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Text(
                        AppStrings.splashTitle,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: spaces.xs / 2,
                          fontSize: layout.isSmall 
                              ? Theme.of(context).textTheme.displayMedium?.fontSize
                              : Theme.of(context).textTheme.displayLarge?.fontSize,
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: spaces.lg),
                
                // Tagline
                AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        AppStrings.splashTagline,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: layout.isSmall 
                              ? Theme.of(context).textTheme.titleSmall?.fontSize
                              : Theme.of(context).textTheme.titleMedium?.fontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                
                SizedBox(height: layout.isSmall ? spaces.xxl * 2 : spaces.xxl * 3),
                
                // Loading indicator
                AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: SizedBox(
                        width: spaces.xl,
                        height: spaces.xl,
                        child: CircularProgressIndicator(
                          strokeWidth: spaces.xs / 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
