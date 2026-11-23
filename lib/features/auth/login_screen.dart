import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/ledgerly_logo.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../state/auth_state.dart';
import 'signup_screen.dart';
import '../main_scaffold.dart';
import '../onboarding/feature_tour_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    final input = _phoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile number or email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).sendOtp(input);
    setState(() => _isLoading = false);

    if (mounted) {
      _showOtpBottomSheet(input);
    }
  }

  void _showOtpBottomSheet(String input) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter 6-Digit OTP',
              style: AppTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a verification code to $input',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              autofocus: true,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '• • • • • •',
                counterText: '',
                fillColor: AppColors.surfaceVariant,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            BouncingButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                setState(() => _isLoading = true);

                final otp = _otpController.text.trim().isEmpty ? '123456' : _otpController.text.trim();
                final success = await ref
                    .read(authProvider.notifier)
                    .verifyOtp(otp, input: input);
                setState(() => _isLoading = false);

                if (!mounted) return;

                if (success) {
                  final auth = ref.read(authProvider);
                  if (auth.isNewUser) {
                    // New user gets feature tour with skip button!
                    Navigator.of(context).pushAndRemoveUntil(
                      SmoothPageRoute(
                        page: const FeatureTourScreen(),
                        transitionType: SmoothTransitionType.fadeThrough,
                      ),
                      (route) => false,
                    );
                  } else {
                    // Test account or existing user directly enters dashboard
                    Navigator.of(context).pushAndRemoveUntil(
                      SmoothPageRoute(
                        page: const MainScaffold(),
                        transitionType: SmoothTransitionType.fadeThrough,
                      ),
                      (route) => false,
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid verification code. Try again.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              color: AppColors.accentGreenBright,
              height: 54,
              child: const Text(
                'Verify & Enter Ledgerly',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Change Phone Number'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section: Navy Header with Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: const LedgerlyLogo(size: 64, showBadge: true)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
            ),

            // Bottom White Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Headline: Login to manage, monitor & grow
                      RichText(
                        text: TextSpan(
                          text: 'Login to ',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 27,
                          ),
                          children: const [
                            TextSpan(
                              text: 'manage, monitor\n& grow',
                              style: TextStyle(
                                color: AppColors.accentGreenBright,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),

                      const SizedBox(height: 36),

                      // Phone Input Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Mobile Number or Email...',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 22),

                      // "Send OTP" Button
                      BouncingButton(
                        onPressed: _handleSendOtp,
                        isLoading: _isLoading,
                        color: AppColors.primaryNavy,
                        height: 56,
                        child: const Text(
                          'Send OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 18),

                      // Terms & Privacy agreement
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By proceeding, I agree to our ',
                            style: AppTypography.bodySmall,
                          ),
                          Text(
                            'Terms',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(' & ', style: AppTypography.bodySmall),
                          Text(
                            'Privacy',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 20),

                      // "Or continue with" divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.borderLight)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'New to Ledgerly?',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.borderLight)),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 20),

                      // "Sign-Up" Outlined Button
                      BouncingButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(
                              page: const SignUpScreen(),
                              transitionType: SmoothTransitionType.slideRight,
                            ),
                          );
                        },
                        color: Colors.white,
                        border: Border.all(color: AppColors.primaryNavy, width: 1.5),
                        height: 56,
                        child: const Text(
                          'Create New Account',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
