import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _isDisposed = false; // Track disposed state manually
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Use a post-frame callback to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _startAnimations();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() async {
    if (!mounted || _isDisposed) return; // Early return if widget is disposed
    
    try {
      // Start fade animation
      if (mounted && !_isDisposed) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (mounted && !_isDisposed) {
          _fadeController.forward();
        }
      }
      
      // Start slide animation
      if (mounted && !_isDisposed) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (mounted && !_isDisposed) {
          _slideController.forward();
        }
      }
      
      // Start scale animation
      if (mounted && !_isDisposed) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (mounted && !_isDisposed) {
          _scaleController.forward();
        }
      }
    } catch (e) {
      // Ignore animation errors if widget is disposed
      if (mounted && !_isDisposed) {
        print('Animation error: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed
    
    // Cancel any pending animations
    _fadeController.stop();
    _slideController.stop();
    _scaleController.stop();
    
    // Dispose controllers
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    
    // Dispose text controllers
    _emailController.dispose();
    _passwordController.dispose();
    
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔍 [DEBUG] Starting Google sign-in...');
      await ref.read(authRepositoryProvider).signInWithGoogle();
      print('🔍 [DEBUG] Google sign-in completed');
      
      if (mounted) {
        // Check the current auth state
        final currentUser = ref.read(authStateProvider).value;
        print('🔍 [DEBUG] Current auth state user: ${currentUser?.uid}');
        
        // Check the current profile
        final profile = ref.read(userProfileStreamProvider).value;
        print('🔍 [DEBUG] Current profile: ${profile?.email}');
        
        // Try to navigate directly
        print('🔍 [DEBUG] Attempting navigation to hub...');
        context.go('/hub');
      }
    } catch (e) {
      print('❌ [DEBUG] Google sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.googleSignInFailed}$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement email/password authentication
      // For now, show a placeholder message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.emailPasswordComingSoon),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.signInFailed}$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _showPassword = !_showPassword);
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    final layout = context.layout;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primaryContainer,
              colors.secondary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spaces.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom - 
                           (spaces.lg * 2),
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: layout.isSmall ? spaces.xxl : spaces.xxl * 2),
                    
                    // App Logo and Title
                    if (!_isDisposed)
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                Container(
                                  width: layout.isSmall ? spaces.xxl * 4 : spaces.xxl * 6,
                                  height: layout.isSmall ? spaces.xxl * 4 : spaces.xxl * 6,
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
                                    size: layout.isSmall ? spaces.xxl * 2 : spaces.xxl * 3,
                                    color: colors.primary,
                                  ),
                                ),
                                SizedBox(height: spaces.lg),
                                Text(
                                  AppStrings.loginTitle,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: spaces.xs / 2,
                                    fontSize: layout.isSmall 
                                        ? Theme.of(context).textTheme.displayMedium?.fontSize
                                        : Theme.of(context).textTheme.displayLarge?.fontSize,
                                  ),
                                ),
                                SizedBox(height: spaces.sm),
                                Text(
                                  AppStrings.loginSubtitle,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colors.onPrimary.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                    fontSize: layout.isSmall 
                                        ? Theme.of(context).textTheme.titleSmall?.fontSize
                                        : Theme.of(context).textTheme.titleMedium?.fontSize,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    SizedBox(height: layout.isSmall ? spaces.xxl * 2 : spaces.xxl * 3),
                    
                    // Login Form
                    if (!_isDisposed)
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: layout.isSmall ? spaces.xxl * 20 : spaces.xxl * 25,
                              ),
                              padding: EdgeInsets.all(layout.isSmall ? spaces.lg : spaces.xl),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(spaces.lg),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow.withValues(alpha: 0.1),
                                    blurRadius: spaces.xl * 2,
                                    spreadRadius: spaces.xs,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email/Password Form
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Email Field
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: AppStrings.emailLabel,
                                            hintText: AppStrings.emailHint,
                                            prefixIcon: Icon(Icons.email_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(spaces.sm),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(spaces.sm),
                                              borderSide: BorderSide(color: colors.outline),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(spaces.sm),
                                              borderSide: BorderSide(color: colors.primary, width: 2),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return AppStrings.emailRequired;
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                              return AppStrings.emailInvalid;
                                            }
                                            return null;
                                          },
                                        ),
                                        
                                        SizedBox(height: spaces.md),
                                        
                                        // Password Field
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_showPassword,
                                          decoration: InputDecoration(
                                            labelText: AppStrings.passwordLabel,
                                            hintText: AppStrings.passwordHint,
                                            prefixIcon: Icon(Icons.lock_outlined),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _showPassword ? Icons.visibility : Icons.visibility_off,
                                              ),
                                              onPressed: _togglePasswordVisibility,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(spaces.sm),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(spaces.sm),
                                              borderSide: BorderSide(color: colors.outline),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(spaces.sm),
                                              borderSide: BorderSide(color: colors.primary, width: 2),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return AppStrings.passwordRequired;
                                            }
                                            if (value.length < 6) {
                                              return AppStrings.passwordTooShort;
                                            }
                                            return null;
                                          },
                                        ),
                                        
                                        SizedBox(height: spaces.md),
                                        
                                        // Sign In Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: spaces.xxl * 1.5,
                                          child: FilledButton(
                                            onPressed: _isLoading ? null : _signInWithEmail,
                                            style: FilledButton.styleFrom(
                                              backgroundColor: colors.primary,
                                              foregroundColor: colors.onPrimary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(spaces.sm),
                                              ),
                                            ),
                                            child: _isLoading
                                                ? SizedBox(
                                                    width: spaces.lg,
                                                    height: spaces.lg,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: spaces.xs / 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        colors.onPrimary,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    AppStrings.signInButton,
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          
                                  SizedBox(height: spaces.lg),
                          
                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: colors.outline.withValues(alpha: 0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: spaces.md),
                                        child: Text(
                                          'OR',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: colors.outline.withValues(alpha: 0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                          
                                  SizedBox(height: spaces.lg),
                          
                                  // Google Sign In Button
                                  if (!_isDisposed)
                                    AnimatedBuilder(
                                      animation: _scaleAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _scaleAnimation.value,
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: spaces.xxl * 1.5,
                                            child: OutlinedButton.icon(
                                              onPressed: _isLoading ? null : _signInWithGoogle,
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: colors.onSurface,
                                                side: BorderSide(color: colors.outline),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(spaces.sm),
                                                ),
                                              ),
                                              icon: Image.asset(
                                                'assets/images/google_logo.png',
                                                height: spaces.lg,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.g_mobiledata,
                                                    size: spaces.lg,
                                                    color: colors.primary,
                                                  );
                                                },
                                              ),
                                              label: Text(
                                                AppStrings.continueWithGoogle,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          
                                  SizedBox(height: spaces.lg),
                          
                                  // Additional Options
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Navigate to forgot password screen
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppStrings.forgotPasswordComingSoon),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          AppStrings.forgotPassword,
                                          style: TextStyle(color: colors.primary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Navigate to sign up screen
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppStrings.signUpComingSoon),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          AppStrings.createAccount,
                                          style: TextStyle(color: colors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Responsive spacing that ensures content fills the screen
                    Expanded(
                      child: SizedBox.shrink(),
                    ),
                    
                    SizedBox(height: layout.isSmall ? spaces.xxl : spaces.xxl * 2),
                    
                    // Footer
                    if (!_isDisposed)
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Text(
                              AppStrings.termsAgreement,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onPrimary.withValues(alpha: 0.7),
                                fontSize: layout.isSmall 
                                    ? Theme.of(context).textTheme.labelSmall?.fontSize
                                    : Theme.of(context).textTheme.bodySmall?.fontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    
                    // Additional bottom padding to ensure gradient covers everything
                    SizedBox(height: spaces.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
