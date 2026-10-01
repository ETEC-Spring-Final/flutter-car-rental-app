import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_rental_system/app/router/app_routes.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/constants/app_constants.dart';
import 'package:vehicle_rental_system/core/widgets/app_button.dart';
import 'package:vehicle_rental_system/core/widgets/app_circle_btn.dart';
import 'package:vehicle_rental_system/core/widgets/app_text_field.dart';
import 'package:vehicle_rental_system/feature/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }

    if (value.length < 6) {
      return 'Use at least 6 characters.';
    }

    return null;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void _login() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginSubmitted(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  // ============================================================
  // OAUTH
  // ============================================================

  void _oauthLogin(String provider) {
    context.read<AuthBloc>().add(OAuthLoginRequested(provider: provider));
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    BuildContext context, {
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      prefixIcon: Icon(icon, size: 21.r, color: colorScheme.onSurfaceVariant),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),

      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colorScheme.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: EdgeInsets.all(AppDimensions.chipHorizontalPadding),
          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // TOP BAR
                // ==================================================
                Row(
                  children: [
                    // AppCircleBtn(
                    //   icon: Icons.arrow_back_rounded,
                    //   onTap: () => context.pop(),
                    //   backgroundColor: colorScheme.surfaceContainerHighest,
                    //   iconColor: colorScheme.onSurface,
                    // ),
                    const Spacer(),

                    Container(
                      // padding: EdgeInsets.symmetric(
                      //   horizontal: 12.w,
                      //   vertical: 7.h,
                      // ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30.r),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 15.r,
                            color: colorScheme.primary,
                          ),

                          SizedBox(width: 6.w),

                          Text(
                            'AUTO RENT Premium',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 34.h),

                // ==================================================
                // HEADER
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.r,
                      height: 64.r,

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.72),
                          ],
                        ),

                        borderRadius: BorderRadius.circular(20.r),

                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.20),
                            blurRadius: 20.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        color: Colors.white,
                        size: 31.r,
                      ),
                    ),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),

                          SizedBox(height: 5.h),

                          Text(
                            'Sign in to continue your journey.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // ==================================================
                // LOGIN CARD
                // ==================================================
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.22,
                    ),

                    borderRadius: BorderRadius.circular(22.r),

                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.08),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ============================================
                      // EMAIL
                      // ============================================
                      Text(
                        'Email address',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      AppTextField(
                        controller: _emailController,
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // ============================================
                      // PASSWORD
                      // ============================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.forgotPassword);
                            },
                            child: Text(
                              'Forgot password?',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      AppTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        filled: true,

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 21.r,
                          ),
                        ),

                        onSubmitted: (_) => _login(),

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // ============================================
                      // LOGIN BUTTON
                      // ============================================
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess ||
                              state is AuthAuthenticated) {
                            context.go(AppRoutes.mainHome);
                          }

                          if (state is AuthFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },

                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return AppButton(
                            text: 'Login',
                            height: 56.h,
                            borderRadius: 16.r,
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _login,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),

                // ==================================================
                // DIVIDER
                // ==================================================
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  ],
                ),

                SizedBox(height: 20.h),

                // ==================================================
                // GOOGLE
                // ==================================================
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return _SocialButton(
                      image: AppConstants.googleIcon,
                      label: 'Continue with Google',
                      loading: isLoading,
                      onPressed: isLoading ? null : () => _oauthLogin('google'),
                    );
                  },
                ),

                SizedBox(height: 28.h),

                // ==================================================
                // REGISTER
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(width: 6.w),

                    GestureDetector(
                      onTap: () {
                        context.push(AppRoutes.register);
                      },
                      child: Text(
                        'Create account',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // ==================================================
                // FOOTER
                // ==================================================
                Text(
                  'Secure login · Your information is protected',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SOCIAL BUTTON
// ================================================================

class _SocialButton extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _SocialButton({
    required this.image,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 54.h,
      child: OutlinedButton(
        onPressed: onPressed,

        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          elevation: 0,

          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.18)),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 21.r,
                height: 21.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: colorScheme.primary,
                ),
              )
            else
              SizedBox(
                width: 21.r,
                height: 21.r,
                child: Image.asset(image, fit: BoxFit.contain),
              ),

            SizedBox(width: 10.w),

            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
