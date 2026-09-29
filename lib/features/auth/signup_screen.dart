import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/ledgerly_logo.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../state/auth_state.dart';
import '../main_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _firstNameController = TextEditingController(text: 'Rahul');
  final _lastNameController = TextEditingController(text: 'Sharma');
  final _emailController = TextEditingController(text: 'sharahul@ledgerly.in');
  final _phoneController = TextEditingController(text: '98765 43210');
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (first.isEmpty || last.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all registration fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).signUp(
          firstName: first,
          lastName: last,
          email: email,
          phone: phone,
        );
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        SmoothPageRoute(
          page: const MainScaffold(),
          transitionType: SmoothTransitionType.fadeThrough,
        ),
        (route) => false,
      );
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight, width: 1.2),
          ),
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const LedgerlyLogo(size: 60, showBadge: true)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(curve: Curves.easeOutBack),
            ),

            // Bottom White Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
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
                      // Title
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        'Create Account with Ledgerly and take control of your finances through smart & efficient management',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 24),

                      // Form Fields
                      _buildField(
                        controller: _firstNameController,
                        hintText: 'First Name',
                        icon: Icons.person_outline_rounded,
                      ).animate().fadeIn(delay: 150.ms),

                      _buildField(
                        controller: _lastNameController,
                        hintText: 'Last Name',
                        icon: Icons.person_outline_rounded,
                      ).animate().fadeIn(delay: 200.ms),

                      _buildField(
                        controller: _emailController,
                        hintText: 'E-Mail',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ).animate().fadeIn(delay: 250.ms),

                      _buildField(
                        controller: _phoneController,
                        hintText: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 14),

                      // "Create Account" CTA Button
                      BouncingButton(
                        onPressed: _handleCreateAccount,
                        isLoading: _isLoading,
                        color: AppColors.primaryNavy,
                        height: 56,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                      const SizedBox(height: 20),

                      const Divider(color: AppColors.borderLight),

                      const SizedBox(height: 8),

                      // "Already have an account? login"
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'login',
                                    style: TextStyle(
                                      color: AppColors.primaryNavy,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),
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
