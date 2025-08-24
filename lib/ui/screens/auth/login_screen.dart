import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/theme/responsive.dart';
import 'package:fam_sync/theme/tokens.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    // Create slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations with delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!_isDisposed) {
            _slideController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    // Get the repository reference before any async operations
    final authRepo = ref.read(authRepositoryProvider);
    
    try {
      print('🔍 [DEBUG] Starting Google sign-in...');
      await authRepo.signInWithGoogle();
      print('🔍 [DEBUG] Google sign-in completed');
      
      if (mounted) {
        // Force refresh the user profile stream to ensure clean state
        print('🔍 [DEBUG] Force refreshing user profile stream...');
        await authRepo.forceRefreshUserProfile();
        
        // Check the current auth state
        final currentUser = ref.read(authStateProvider).value;
        print('🔍 [DEBUG] Current auth state user: ${currentUser?.uid}');
        
        // Check the current profile
        final profile = ref.read(userProfileStreamProvider).value;
        print('🔍 [DEBUG] Current profile: ${profile?.email}');
        
        // Try to navigate directly
        print('🔍 [DEBUG] Attempting navigation to hub...');
        if (mounted) {
          context.go('/hub');
        }
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

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement Apple Sign-In
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Apple Sign-In coming soon!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Sign-In failed: $e'),
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
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.emailPasswordComingSoon),
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

  void _toggleRememberMe() {
    setState(() => _rememberMe = !_rememberMe);
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
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.family_restroom,
                                    size: layout.isSmall ? spaces.xxl * 2 : spaces.xxl * 3,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: spaces.lg),
                                Text(
                                  'FamilyHub',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: layout.isSmall ? 28 : 36,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                SizedBox(height: spaces.sm),
                                Text(
                                  'Your family, connected',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w400,
                                    fontSize: layout.isSmall ? 16 : 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    SizedBox(height: spaces.xxl),
                    
                    // Login Card
                    if (!_isDisposed)
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxWidth: layout.isLarge ? 400 : double.infinity,
                                ),
                                padding: EdgeInsets.all(spaces.xl),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(spaces.lg),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: spaces.xl,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Welcome Header
                                    Column(
                                      children: [
                                        Text(
                                          'Welcome Back!',
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: const Color(0xFF2D3748), // Dark grey
                                            fontWeight: FontWeight.w800,
                                            fontSize: layout.isSmall ? 24 : 28,
                                          ),
                                        ),
                                        SizedBox(height: spaces.sm),
                                        Text(
                                          'Sign in to your FamilyHub account',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: const Color(0xFF718096), // Medium grey
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: spaces.xxl),
                                    
                                    // Social Login Options
                                    Column(
                                      children: [
                                        // Google Sign-In Button
                                        _buildSocialButton(
                                          context: context,
                                          icon: Icons.g_mobiledata,
                                          label: 'Continue with Google',
                                          onPressed: _isLoading ? null : _signInWithGoogle,
                                          backgroundColor: Colors.white,
                                          textColor: const Color(0xFF2D3748),
                                          borderColor: const Color(0xFFE2E8F0),
                                          isLoading: _isLoading,
                                          spaces: spaces,
                                        ),
                                        
                                        SizedBox(height: spaces.md),
                                        
                                        // Apple Sign-In Button
                                        _buildSocialButton(
                                          context: context,
                                          icon: Icons.apple,
                                          label: 'Continue with Apple',
                                          onPressed: _isLoading ? null : _signInWithApple,
                                          backgroundColor: const Color(0xFF2D3748),
                                          textColor: Colors.white,
                                          borderColor: const Color(0xFF2D3748),
                                          isLoading: _isLoading,
                                          spaces: spaces,
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: spaces.xl),
                                    
                                    // Separator
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: spaces.md),
                                          child: Text(
                                            'or continue with email',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color(0xFF718096),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: spaces.xl),
                                    
                                    // Email/Password Form
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          // Email Field
                                          _buildInputField(
                                            context: context,
                                            controller: _emailController,
                                            hintText: 'Enter your email',
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                            spaces: spaces,
                                          ),
                                          
                                          SizedBox(height: spaces.md),
                                          
                                          // Password Field
                                          _buildInputField(
                                            context: context,
                                            controller: _passwordController,
                                            hintText: 'Enter your password',
                                            prefixIcon: Icons.lock_outlined,
                                            isPassword: true,
                                            showPassword: _showPassword,
                                            onTogglePassword: _togglePasswordVisibility,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                            spaces: spaces,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(height: spaces.lg),
                                    
                                    // Remember Me & Forgot Password
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Remember Me Checkbox
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: _toggleRememberMe,
                                              child: Container(
                                                width: spaces.lg,
                                                height: spaces.lg,
                                                decoration: BoxDecoration(
                                                  color: _rememberMe ? const Color(0xFF6A0DAD) : Colors.white,
                                                  border: Border.all(
                                                    color: _rememberMe ? const Color(0xFF6A0DAD) : const Color(0xFFE2E8F0),
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(spaces.xs),
                                                ),
                                                child: _rememberMe
                                                    ? Icon(
                                                        Icons.check,
                                                        size: spaces.md,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(width: spaces.sm),
                                            Text(
                                              'Remember me',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: const Color(0xFF2D3748),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        // Forgot Password Link
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: Navigate to forgot password
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Forgot password coming soon!'),
                                                backgroundColor: const Color(0xFF6A0DAD),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Forgot password?',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color(0xFF6A0DAD),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: spaces.xl),
                                    
                                    // Sign In Button
                                    _buildSignInButton(
                                      context: context,
                                      onPressed: _isLoading ? null : _signInWithEmail,
                                      isLoading: _isLoading,
                                      spaces: spaces,
                                    ),
                                    
                                    SizedBox(height: spaces.xl),
                                    
                                    // Sign Up Link
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: const Color(0xFF2D3748),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: Navigate to sign up
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Sign up coming soon!'),
                                                backgroundColor: const Color(0xFF6A0DAD),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Sign up for free',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color(0xFF6A0DAD),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required bool isLoading,
    required AppSpacing spaces,
  }) {
    return Container(
      height: 48, // Use fixed height for social buttons
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(spaces.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(spaces.md),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: spaces.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: spaces.md,
                    height: spaces.md,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: textColor,
                    size: spaces.lg,
                  ),
                SizedBox(width: spaces.md),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required AppSpacing spaces,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF718096).withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF718096),
          size: spaces.lg,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF718096),
                  size: spaces.lg,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spaces.md),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spaces.md),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spaces.md),
          borderSide: const BorderSide(color: Color(0xFF6A0DAD), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spaces.md),
          borderSide: const BorderSide(color: Color(0xFFE53E3E)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spaces.md,
          vertical: spaces.md,
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required bool isLoading,
    required AppSpacing spaces,
  }) {
    return Container(
      height: 52, // Use fixed height for sign in button
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFFFF4D9D)], // Purple to pink gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(spaces.md),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A0DAD).withValues(alpha: 0.3),
            blurRadius: spaces.md,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(spaces.md),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: spaces.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: spaces.md,
                    height: spaces.md,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
