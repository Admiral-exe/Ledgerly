import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../state/auth_state.dart';
import '../welcome/welcome_screen.dart';
import '../notifications/notification_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title: Profile
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: AppTypography.headingLarge.copyWith(fontSize: 24),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // User Avatar with Ring
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCBD5E1),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFF64748B),
                    alignment: Alignment.center,
                    child: Text(
                      (user?.firstName.isNotEmpty ?? false)
                          ? user!.firstName[0]
                          : 'R',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms).scale(curve: Curves.easeOutBack),

              const SizedBox(height: 14),

              // User Full Name
              Text(
                user?.fullName.isNotEmpty == true ? user!.fullName : 'Rahul Sharma',
                style: AppTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 4),

              // Email
              Text(
                user?.email ?? 'sharahul@ledgerly.in',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 28),

              // Settings Card with rows and chevrons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Account',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account Settings')),
                        );
                      },
                    ),
                    const Divider(color: AppColors.borderLight, height: 1, indent: 56),
                    _buildSettingsTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: const NotificationScreen(),
                            transitionType: SmoothTransitionType.slideRight,
                          ),
                        );
                      },
                    ),
                    const Divider(color: AppColors.borderLight, height: 1, indent: 56),
                    _buildSettingsTile(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Security',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Security & Biometrics: Enabled')),
                        );
                      },
                    ),
                    const Divider(color: AppColors.borderLight, height: 1, indent: 56),
                    _buildSettingsTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help & 24/7 FinTech Support: Active')),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Outlined Logout Button
              BouncingButton(
                onPressed: () {
                  _showLogoutConfirmation(context, ref);
                },
                color: Colors.white,
                border: Border.all(color: AppColors.errorRed, width: 1.5),
                height: 54,
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 24),

              // Version Footer
              Text(
                'LEDGERLY V2.4.1',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out of Ledgerly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                SmoothPageRoute(
                  page: const WelcomeScreen(),
                  transitionType: SmoothTransitionType.fadeThrough,
                ),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
