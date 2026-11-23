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

class FeatureTourItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color gradientStart;
  final Color gradientEnd;
  final List<String> highlights;
  final Widget previewWidget;

  const FeatureTourItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.highlights,
    required this.previewWidget,
  });
}

class FeatureTourScreen extends ConsumerStatefulWidget {
  const FeatureTourScreen({super.key});

  @override
  ConsumerState<FeatureTourScreen> createState() => _FeatureTourScreenState();
}

class _FeatureTourScreenState extends ConsumerState<FeatureTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishTour() {
    ref.read(authProvider.notifier).markTourCompleted();
    Navigator.of(context).pushAndRemoveUntil(
      SmoothPageRoute(
        page: const MainScaffold(),
        transitionType: SmoothTransitionType.fadeThrough,
        duration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishTour();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<FeatureTourItem> _buildTourItems() {
    return [
      // 1. Dashboard & Balances
      FeatureTourItem(
        title: 'Smart Dashboard',
        subtitle: 'Real-Time Balance & Spending',
        description:
            'Monitor your cash flow with animated rolling counters, instant income vs expense breakdown, and live remaining budget pacing.',
        icon: Icons.dashboard_customize_rounded,
        accentColor: AppColors.accentGreenBright,
        gradientStart: const Color(0xFF047857),
        gradientEnd: const Color(0xFF10B981),
        highlights: [
          'Rolling Currency Counters',
          'Instant Income vs Expense',
          'Live Remaining Budget Pacing',
        ],
        previewWidget: _buildDashboardPreview(),
      ),

      // 2. Budget Hub
      FeatureTourItem(
        title: 'Budget Hub',
        subtitle: 'Category Allocations & Velocity',
        description:
            'Establish custom budgets for Food, Travel, Rent, and Bills. Receive predictive alerts before you exceed your target limit.',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: const Color(0xFF38BDF8),
        gradientStart: const Color(0xFF0369A1),
        gradientEnd: const Color(0xFF38BDF8),
        highlights: [
          '1-Tap AI Recommendations',
          'Overspend Risk Alerts',
          'Multi-Month History Tracking',
        ],
        previewWidget: _buildBudgetPreview(),
      ),

      // 3. Smart Logging & Magic AI Fill
      FeatureTourItem(
        title: 'Instant Logging',
        subtitle: '3 Fast Ways to Record & ✨ Magic AI Fill',
        description:
            'Speed-log with tactile buttons, import Excel/CSV statements in 1 tap, or write naturally (e.g. "Dinner with friends ₹1,200") for auto-fill.',
        icon: Icons.auto_awesome_rounded,
        accentColor: const Color(0xFFA855F7),
        gradientStart: const Color(0xFF7E22CE),
        gradientEnd: const Color(0xFFA855F7),
        highlights: [
          '✨ Magic AI Natural Auto-Fill',
          '1-Tap Bank Statement Import',
          'Multi-Payment Modes (UPI/Card)',
        ],
        previewWidget: _buildLoggingPreview(),
      ),

      // 4. Ledgerly AI Assistant
      FeatureTourItem(
        title: 'Ledgerly AI',
        subtitle: 'On-Device Personal Financial Advisor',
        description:
            'Ask queries about your spending habits, get custom savings tips, or ask Ledgerly AI to record expenses directly inside the chat conversation.',
        icon: Icons.smart_toy_rounded,
        accentColor: const Color(0xFFF59E0B),
        gradientStart: const Color(0xFFB45309),
        gradientEnd: const Color(0xFFF59E0B),
        highlights: [
          'Conversational Financial Q&A',
          'Add Expenses Through Chat',
          'Tailored Monthly Saving Plans',
        ],
        previewWidget: _buildAIChatPreview(),
      ),

      // 5. 100% On-Device Privacy
      FeatureTourItem(
        title: 'Total Privacy',
        subtitle: '100% On-Device Local RAG Security',
        description:
            'Your financial transactions and vector embeddings stay strictly on your phone in high-speed RAM & disk. Zero cloud leaks, zero tracking.',
        icon: Icons.shield_rounded,
        accentColor: const Color(0xFF10B981),
        gradientStart: const Color(0xFF064E3B),
        gradientEnd: const Color(0xFF047857),
        highlights: [
          'RAM Cached SIMD Vector Search',
          'No Third-Party Cloud Leaks',
          'Offline Fallback Engine',
        ],
        previewWidget: _buildPrivacyPreview(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tourItems = _buildTourItems();
    final currentItem = tourItems[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar: Ledgerly Logo + Prominent Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App branding
                  Row(
                    children: [
                      const LedgerlyLogo(size: 32),
                      const SizedBox(width: 8),
                      const Text(
                        'LEDGERLY TOUR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // Prominent Skip Button
                  GestureDetector(
                    onTap: _finishTour,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Skip Tour',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Interactive Tour PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: tourItems.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = tourItems[index];
                  return _buildTourCard(item);
                },
              ),
            ),

            // Bottom Navigation Card & Indicators
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 20,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicators + Step Counter Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Smooth Page Indicators
                      Row(
                        children: List.generate(tourItems.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? currentItem.accentColor
                                  : AppColors.borderLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Step counter text
                      Text(
                        'Step ${_currentPage + 1} of ${tourItems.length}',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons: Previous (if >0) & Next / Get Started
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        BouncingButton(
                          onPressed: _previousPage,
                          width: 52,
                          height: 54,
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Primary Next / Get Started Button
                      Expanded(
                        child: BouncingButton(
                          onPressed: _nextPage,
                          height: 54,
                          color: _currentPage == tourItems.length - 1
                              ? AppColors.accentGreenBright
                              : AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == tourItems.length - 1
                                    ? 'Get Started'
                                    : 'Next Feature',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == tourItems.length - 1
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCard(FeatureTourItem item) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Visual Feature Card Graphic
          Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.gradientStart, item.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient Radial Glow
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                ),

                // Inner Custom Preview Illustration
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: item.previewWidget,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).scale(curve: Curves.easeOutCubic),

          const SizedBox(height: 22),

          // Feature Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: item.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: item.accentColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 15, color: item.accentColor),
                const SizedBox(width: 6),
                Text(
                  item.title.toUpperCase(),
                  style: TextStyle(
                    color: item.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          // Subtitle / Heading
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 10),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
              height: 1.45,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 18),

          // 3 Feature Highlights (Pills)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: item.highlights.map((highlight) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: item.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      highlight,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }

  // --- Visual Preview Illustrations ---

  Widget _buildDashboardPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LIVE BALANCE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '₹42,000.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniBudgetItem(
                icon: Icons.restaurant_rounded,
                category: 'Food',
                spent: '₹8,000',
                total: '₹10,000',
                color: const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniBudgetItem(
                icon: Icons.directions_car_rounded,
                category: 'Travel',
                spent: '₹3,200',
                total: '₹5,000',
                color: const Color(0xFF06B6D4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniBudgetItem({
    required IconData icon,
    required String category,
    required String spent,
    required String total,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$spent / $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggingPreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                '✨ Magic AI Fill Activated',
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '"Dinner at Pizza Hut ₹1,290 via Credit Card"',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTag('Dining', Icons.restaurant),
              const SizedBox(width: 6),
              _buildTag('₹1,290.00', Icons.currency_rupee),
              const SizedBox(width: 6),
              _buildTag('Credit Card', Icons.credit_card),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text(
                'How much did I spend on Food this week?',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You spent ₹3,420 across 4 dining transactions. 15% lower than last week!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zero Cloud Leaks',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'All vector math computed on your device in < 2ms',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
