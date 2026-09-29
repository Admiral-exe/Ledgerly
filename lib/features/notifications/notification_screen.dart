import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isMarkedAllRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.headingMedium.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings opened'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODAY Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TODAY',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _isMarkedAllRead = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: const Color(0xFF047857),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 14),

            // Card 1: Savings Milestone Achieved
            _buildNotificationCard(
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFF047857),
              iconBg: const Color(0xFFD1FAE5),
              title: 'Savings Milestone Achieved',
              time: '2h ago',
              description: 'Congratulations! You have spent ₹300 less than your set budget for travel.',
              isUnread: !_isMarkedAllRead,
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 12),

            // Card 2: Budget Alert: Food
            _buildNotificationCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.errorRed,
              iconBg: const Color(0xFFFEE2E2),
              title: 'Budget Alert: Food',
              time: '5h ago',
              description: 'You have spent more today than usual in food. Consider reviewing your daily limit.',
              isUnread: !_isMarkedAllRead,
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // Promotional Card: Ledgerly Premium Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW FEATURE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ledgerly Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get real-time insights and advanced budget forecasting for your goals.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Rocket Icon Container
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Color(0xFF38BDF8),
                      size: 38,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // YESTERDAY Header
            Text(
              'YESTERDAY',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 14),

            // Card 3: Monthly Report Ready
            _buildNotificationCard(
              icon: Icons.insert_chart_outlined_rounded,
              iconColor: Colors.white,
              iconBg: AppColors.primaryNavy,
              title: 'Monthly Report Ready',
              time: 'Yesterday',
              description: 'Monthly Analytics for May are now ready to view. Tap to see your spending breakdown.',
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 12),

            // Card 4: Bank Account Synced
            _buildNotificationCard(
              icon: Icons.account_balance_rounded,
              iconColor: AppColors.textPrimary,
              iconBg: const Color(0xFFF1F5F9),
              title: 'Bank Account Synced',
              time: 'Yesterday',
              description: 'Your HDFC Bank account has been successfully re-synced for automated tracking.',
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
    required String description,
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? const Color(0xFFA7F3D0) : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
