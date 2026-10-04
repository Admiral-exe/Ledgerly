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

              // Settings Card with interactive rows
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
                      onTap: () => _showAccountModal(context, user),
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
                      onTap: () => _showSecurityModal(context),
                    ),
                    const Divider(color: AppColors.borderLight, height: 1, indent: 56),
                    _buildSettingsTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () => _showHelpModal(context),
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
                'LEDGERLY V2.4.1 • BUILD 2026',
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

  void _showAccountModal(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Account Information', style: AppTypography.headingSmall),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', user?.fullName ?? 'Rahul Sharma'),
            const SizedBox(height: 12),
            _buildInfoRow('Email Address', user?.email ?? 'sharahul@ledgerly.in'),
            const SizedBox(height: 12),
            _buildInfoRow('Phone', user?.phone ?? '+91 98765 43210'),
            const SizedBox(height: 12),
            _buildInfoRow('Account Tier', 'Ledgerly Member'),
            const SizedBox(height: 24),
            BouncingButton(
              onPressed: () => Navigator.of(ctx).pop(),
              color: Colors.black,
              height: 48,
              borderRadius: BorderRadius.circular(14),
              child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Security & Privacy', style: AppTypography.headingSmall),
            const SizedBox(height: 16),
            _buildInfoRow('Biometrics (Face ID / Touch ID)', 'Enabled'),
            const SizedBox(height: 12),
            _buildInfoRow('Two-Factor Authentication', 'Active (SMS)'),
            const SizedBox(height: 12),
            _buildInfoRow('Data Encryption', 'AES-256 Bit'),
            const SizedBox(height: 24),
            BouncingButton(
              onPressed: () => Navigator.of(ctx).pop(),
              color: Colors.black,
              height: 48,
              borderRadius: BorderRadius.circular(14),
              child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Help & Support', style: AppTypography.headingSmall),
            const SizedBox(height: 14),
            const Text(
              'Need assistance with your budget, transactions, or bank connection?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Support Email', 'support@ledgerly.in'),
            const SizedBox(height: 12),
            _buildInfoRow('Response Time', '< 2 hours'),
            const SizedBox(height: 24),
            BouncingButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support request sent! Our team will respond shortly.'),
                    backgroundColor: Color(0xFF047857),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              color: AppColors.primaryNavy,
              height: 48,
              borderRadius: BorderRadius.circular(14),
              child: const Text('Contact Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out of Ledgerly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
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
