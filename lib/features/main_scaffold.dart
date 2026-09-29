import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/bouncing_button.dart';
import '../core/widgets/smooth_page_route.dart';
import 'home/home_dashboard_screen.dart';
import 'budget/budget_screen.dart';
import 'analytics/analytics_screen.dart';
import 'profile/profile_screen.dart';
import 'ai_chat/ai_chat_screen.dart';
import 'transactions/add_transaction_modal.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  void _openAIChat() {
    Navigator.of(context).push(
      SmoothPageRoute(
        page: const AIChatScreen(),
        transitionType: SmoothTransitionType.slideUp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboardScreen(
        onOpenTransactions: _openAddTransactionModal,
        onOpenAI: _openAIChat,
      ),
      const BudgetScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // IndexedScreen view with smooth fade transitions
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: screens[_currentIndex],
            ),
          ),

          // Floating AI Sparkle Badge (Signature Figma Floating Action)
          Positioned(
            right: 20,
            bottom: 104,
            child: _buildFloatingAISparkle(),
          ),

          // Floating Docked Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAISparkle() {
    return BouncingButton(
      onPressed: _openAIChat,
      padding: EdgeInsets.zero,
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFBAE6FD),
            Color(0xFFDDD6FE),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Central gradient 4-point sparkle star
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFFF59E0B)],
            ).createShader(bounds),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1.05, 1.05),
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Tab bar items row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, 'Home', Icons.home_rounded),
                _buildNavItem(1, 'Budget', Icons.account_balance_wallet_outlined),
                const SizedBox(width: 56), // Gap for center floating FAB
                _buildNavItem(2, 'Analytics', Icons.insights_rounded),
                _buildNavItem(3, 'Profile', Icons.person_outline_rounded),
              ],
            ),
          ),

          // Central Floating Green "+" Action Button
          Positioned(
            top: -14,
            child: BouncingButton(
              onPressed: _openAddTransactionModal,
              width: 60,
              height: 60,
              padding: EdgeInsets.zero,
              color: AppColors.accentGreenBright,
              borderRadius: BorderRadius.circular(30),
              decoration: BoxDecoration(
                color: AppColors.accentGreenBright,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreenBright.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
