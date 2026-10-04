import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../state/budget_state.dart';
import '../../state/transaction_state.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? insight;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.insight,
  });
}

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'How much did I spend on dining last week?',
      isUser: true,
      time: '10:03 AM',
    ),
    ChatMessage(
      text: 'You spent ₹3,420 on Food & Dining last week.',
      isUser: false,
      time: '10:03 AM',
      insight: 'This is 15% lower than your weekly average. Great job staying on track!',
    ),
  ];

  final List<String> _quickChips = [
    'Summarize my month',
    'Am I over budget?',
    'Top spending categories',
    'How can I save ₹5,000?',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final budget = ref.read(budgetProvider);
    final monthlySpending = ref.read(monthlySpendingProvider);

    setState(() {
      _messages.add(
        ChatMessage(
          text: text.trim(),
          isUser: true,
          time: 'Just now',
        ),
      );
    });

    _inputController.clear();
    _scrollToBottom();

    // Contextual FinTech Assistant Response using real state
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final totalSpent = monthlySpending > 0 ? monthlySpending : budget.totalSpent;
      final remaining = (budget.totalBudget - totalSpent).clamp(0.0, double.infinity);
      final percentUsed = budget.totalBudget > 0 ? ((totalSpent / budget.totalBudget) * 100).round() : 0;

      final sorted = List.of(budget.categories)..sort((a, b) => b.spent.compareTo(a.spent));
      final topCat = sorted.isNotEmpty ? sorted.first : null;

      String response = "Based on your ${budget.month} spending patterns, you have used $percentUsed% of your ${Formatters.currency(budget.totalBudget, showDecimals: false)} budget.";
      String? insight = "You have ${Formatters.currency(remaining, showDecimals: false)} remaining with safe daily limits.";

      final lower = text.toLowerCase();
      if (lower.contains('summarize') || lower.contains('month')) {
        response = "For ${budget.month}, your total outflow is ${Formatters.currency(totalSpent, showDecimals: false)} across ${budget.categories.length} categories. You have ${Formatters.currency(remaining, showDecimals: false)} left.";
        if (topCat != null) {
          insight = "${topCat.name} is your highest expense at ${Formatters.currency(topCat.spent, showDecimals: false)} (${(topCat.spent / (totalSpent > 0 ? totalSpent : 1) * 100).round()}% of total).";
        }
      } else if (lower.contains('budget') || lower.contains('over')) {
        if (percentUsed >= 100) {
          response = "Warning: You have reached 100% of your allocated monthly budget!";
          insight = "Consider allocating an additional buffer or reviewing non-essential spending.";
        } else {
          response = "Good news! You are currently within your target limits at $percentUsed% utilized.";
          insight = "You have ${Formatters.currency(remaining, showDecimals: false)} buffer remaining for the rest of ${budget.month}.";
        }
      } else if (lower.contains('top') || lower.contains('categories')) {
        if (sorted.length >= 2) {
          response = "Your top categories are ${sorted[0].name} (${Formatters.currency(sorted[0].spent, showDecimals: false)}) and ${sorted[1].name} (${Formatters.currency(sorted[1].spent, showDecimals: false)}).";
          insight = "${sorted[0].name} takes up ${(sorted[0].spent / (totalSpent > 0 ? totalSpent : 1) * 100).round()}% of your monthly expenses.";
        }
      } else if (lower.contains('save')) {
        response = "To save an additional ₹5,000 this month, try capping discretionary dining and shopping by 15%.";
        insight = "Setting a daily limit of ${Formatters.currency((budget.totalBudget - 5000) / 30, showDecimals: false)} will automatically achieve your savings target!";
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            time: 'Just now',
            insight: insight,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 140,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF047857),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Ledgerly AI',
              style: AppTypography.headingMedium.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Quick Prompt Chips
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _quickChips.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  return BouncingButton(
                    onPressed: () => _sendMessage(_quickChips[i]),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                    child: Text(
                      _quickChips[i],
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Ask Ledgerly AI about your money...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BouncingButton(
                      onPressed: () => _sendMessage(_inputController.text),
                      width: 44,
                      height: 44,
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.time,
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (msg.insight != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.trending_down_rounded,
                            color: Color(0xFF047857),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              msg.insight!,
                              style: const TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.time,
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      );
    }
  }
}
