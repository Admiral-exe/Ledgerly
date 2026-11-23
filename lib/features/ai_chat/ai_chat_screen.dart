import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/rag_ai_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../data/models/transaction_model.dart';
import '../../state/budget_state.dart';
import '../../state/transaction_state.dart';
import '../../state/auth_state.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? insight;
  final Map<String, dynamic>? transactionData;
  final List<String>? clarificationChips;
  final double? pendingAmount;
  final TransactionType? pendingType;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.insight,
    this.transactionData,
    this.clarificationChips,
    this.pendingAmount,
    this.pendingType,
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
  final RAGAIService _ragService = RAGAIService();
  bool _isThinking = false;
  late List<ChatMessage> _messages;

  List<ChatMessage> _getInitialMessages() {
    final auth = ref.read(authProvider);
    final user = auth.user;

    if (auth.isTestAccount) {
      return [
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
    } else {
      return [
        ChatMessage(
          text: 'Hello ${user?.firstName ?? "there"}! 👋 I am your private, on-device Ledgerly AI assistant.',
          isUser: false,
          time: 'Just now',
          insight: 'Your account is ready! You can ask me to log your first expense (e.g. "Add ₹250 for lunch at Cafe") or ask any budgeting questions.',
        ),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _messages = _getInitialMessages();
  }

  void _confirmNewChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded, color: AppColors.errorRed, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Start New Chat?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Your current chat will be removed and a fresh conversation will start.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _messages = _getInitialMessages();
                _inputController.clear();
                _isThinking = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New chat session started'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  final List<String> _quickChips = [
    'Add expense of 2000, dinner at kismat kathyawadi',
    'Add 200rs in expence',
    'Summarize my month',
    'Am I over budget?',
    'Top spending categories',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: cleanText,
          isUser: true,
          time: 'Just now',
        ),
      );
      _isThinking = true;
    });

    _inputController.clear();
    _scrollToBottom();

    final budget = ref.read(budgetProvider);
    final monthlySpending = ref.read(monthlySpendingProvider);
    final lower = cleanText.toLowerCase();

    // Detect friendly greetings / check-ins (e.g. "hey", "hey?", "hello", "hi")
    final isGreeting = RegExp(
      r'^(?:hey|hello|hi|heya|hiya|howdy|good\s+(?:morning|afternoon|evening)|yo|sup|greetings)\b[!?.]*$',
      caseSensitive: false,
    ).hasMatch(lower);

    if (isGreeting) {
      final user = ref.read(authProvider).user;
      final userName = user != null && user.firstName.isNotEmpty ? user.firstName : 'there';
      final totalBudget = budget.totalBudget;
      final totalSpent = monthlySpending > 0 ? monthlySpending : budget.totalSpent;
      final remaining = (totalBudget - totalSpent).clamp(0.0, double.infinity);
      final percentUsed = totalBudget > 0 ? ((totalSpent / totalBudget) * 100).round() : 0;

      String answer;
      String insight;

      if (totalBudget <= 0) {
        answer = 'Hey $userName! 👋 Welcome to Ledgerly AI. You don\'t have a budget configured for ${budget.month} yet.';
        insight = 'Set up your monthly budget or ask me to log your first transaction to get started!';
      } else if (percentUsed >= 100) {
        answer = 'Hey $userName! 👋 Heads up: You have reached 100% of your allocated ${Formatters.currency(totalBudget, showDecimals: false)} budget for ${budget.month}.';
        insight = 'I can help you review your categories and find areas to trim spending for the rest of the month.';
      } else if (percentUsed >= 80) {
        answer = 'Hey $userName! 👋 You\'ve utilized $percentUsed% of your monthly budget with ${Formatters.currency(remaining, showDecimals: false)} remaining for ${budget.month}.';
        insight = 'Consider pacing your non-essential spending over the next few days to stay within your goal.';
      } else {
        answer = 'Hey $userName! 👋 Your budgets are well maintained — keep it up! You\'ve used only $percentUsed% of your budget with ${Formatters.currency(remaining, showDecimals: false)} remaining for ${budget.month}.';
        insight = 'You\'re on track for a healthy monthly surplus. What would you like to check or log today?';
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _isThinking = false;
          _messages.add(
            ChatMessage(
              text: answer,
              isUser: false,
              time: 'Just now',
              insight: insight,
            ),
          );
        });
        _scrollToBottom();
      });
      return;
    }

    // Distinguish inquiries/questions from transaction creation commands
    final isQuestion = cleanText.contains('?') ||
        RegExp(r'^(?:how|what|where|why|when|who|which|did|does|do|can|could|will|would|is|are|was|were|am|summarize|show|tell|list|explain|check|analyze)\b', caseSensitive: false).hasMatch(cleanText);

    final isTransactionCommand = !isQuestion && (
        lower.startsWith('add ') ||
        (lower.startsWith('add') && (lower.contains('expense') || lower.contains('income'))) ||
        lower.startsWith('log ') ||
        lower.startsWith('record ') ||
        lower.startsWith('create ') ||
        lower.startsWith('spent ') ||
        lower.startsWith('paid ') ||
        lower.startsWith('bought ') ||
        RegExp(r'^(?:₹|rs\.?|inr)?\s*\d+').hasMatch(lower)
    );

    final userCategories = budget.categories.map((c) => c.name).toList();

    if (isTransactionCommand) {
      // 1. Parse via RAG microservice with live user categories
      final parseResult = await _ragService.parseNaturalTransaction(
        cleanText,
        categories: userCategories.isNotEmpty
            ? userCategories
            : const ['Dining', 'Travel', 'Rent', 'Shopping', 'Bills', 'Fun', 'Health', 'Other'],
      );

      if (!mounted) return;

      if (parseResult.isComplete && parseResult.amount != null && parseResult.amount! > 0) {
        // Complete transaction: Auto-create entry!
        final amount = parseResult.amount!;
        final cat = parseResult.category ?? 'Other';
        final title = parseResult.title ?? cat;
        final txType = parseResult.type;

        ref.read(transactionProvider.notifier).addTransaction(
              title: title,
              amount: amount,
              type: txType,
              category: cat,
              date: DateTime.now(),
              paymentMode: 'UPI',
              note: parseResult.note,
            );

        if (txType == TransactionType.expense) {
          ref.read(budgetProvider.notifier).addExpenseToCategory(cat, amount);
        }

        // Get newly added transaction ID
        final allTxs = ref.read(transactionProvider);
        final newTx = allTxs.isNotEmpty ? allTxs.first : null;

        setState(() {
          _isThinking = false;
          _messages.add(
            ChatMessage(
              text: 'Successfully added ${Formatters.currency(amount)} for "$title" under $cat!',
              isUser: false,
              time: 'Just now',
              insight: 'Your monthly spending and category progress have been automatically updated.',
              transactionData: newTx != null
                  ? {
                      'id': newTx.id,
                      'amount': amount,
                      'category': cat,
                      'title': title,
                    }
                  : null,
            ),
          );
        });
        _scrollToBottom();
        return;
      } else if (!parseResult.isComplete && parseResult.amount != null) {
        // Incomplete transaction (Slot-Filling): Ask clarification and present chips
        setState(() {
          _isThinking = false;
          _messages.add(
            ChatMessage(
              text: parseResult.clarificationQuestion ??
                  'Recorded ${Formatters.currency(parseResult.amount!)}. What was this expense for?',
              isUser: false,
              time: 'Just now',
              clarificationChips: parseResult.suggestedChips.isNotEmpty
                  ? parseResult.suggestedChips
                  : (userCategories.isNotEmpty
                      ? userCategories.take(6).toList()
                      : const ['Dining', 'Travel', 'Shopping', 'Bills']),
              pendingAmount: parseResult.amount,
              pendingType: parseResult.type,
            ),
          );
        });
        _scrollToBottom();
        return;
      }
    }

    final totalSpent = monthlySpending > 0 ? monthlySpending : budget.totalSpent;
    final remaining = (budget.totalBudget - totalSpent).clamp(0.0, double.infinity);
    final percentUsed = budget.totalBudget > 0 ? ((totalSpent / budget.totalBudget) * 100).round() : 0;
    final sorted = List.of(budget.categories)..sort((a, b) => b.spent.compareTo(a.spent));
    final topCat = sorted.isNotEmpty ? sorted.first : null;

    final categoryBreakdown = budget.categories
        .map((c) => {
              'name': c.name,
              'allocated': c.allocated,
              'spent': c.spent,
            })
        .toList();

    // 2. Otherwise: Contextual RAG query
    final ragResponse = await _ragService.queryRAG(
      query: cleanText,
      currentBudget: budget.totalBudget,
      totalSpent: totalSpent,
      currentMonth: budget.month,
      categoryBreakdown: categoryBreakdown,
    );

    if (!mounted) return;

    String answer = ragResponse['answer'] ?? '';
    String? insight = ragResponse['insight'];

    // If generic fallback, customize with exact live state figures
    if (answer.isEmpty || answer.contains('Based on your records') || answer.contains('Found matching record')) {
      if (lower.contains('summarize') || lower.contains('month')) {
        answer = 'For ${budget.month}, your total spending is ${Formatters.currency(totalSpent, showDecimals: false)} across ${budget.categories.length} categories. You have ${Formatters.currency(remaining, showDecimals: false)} remaining.';
        if (topCat != null) {
          insight = '${topCat.name} is your highest expense at ${Formatters.currency(topCat.spent, showDecimals: false)} (${(topCat.spent / (totalSpent > 0 ? totalSpent : 1) * 100).round()}% of total).';
        }
      } else if (lower.contains('budget') || lower.contains('over')) {
        answer = percentUsed >= 100
            ? 'Warning: You have reached 100% of your allocated monthly budget!'
            : 'Good news! You are currently within safe limits at $percentUsed% utilized with ${Formatters.currency(remaining, showDecimals: false)} buffer remaining.';
        insight = 'Maintaining a daily limit of ${Formatters.currency(budget.dailyLimit, showDecimals: false)} will keep your surplus intact.';
      } else if (lower.contains('top') || lower.contains('categories')) {
        if (sorted.length >= 2) {
          answer = 'Your top categories are ${sorted[0].name} (${Formatters.currency(sorted[0].spent, showDecimals: false)}) and ${sorted[1].name} (${Formatters.currency(sorted[1].spent, showDecimals: false)}).';
        }
      }
    }

    setState(() {
      _isThinking = false;
      _messages.add(
        ChatMessage(
          text: answer.isNotEmpty ? answer : 'Here is your current financial analysis based on active records.',
          isUser: false,
          time: 'Just now',
          insight: insight,
        ),
      );
    });
    _scrollToBottom();
  }

  void _completePendingTransaction(String category, double amount, TransactionType type) {
    final title = 'Expense on $category';
    ref.read(transactionProvider.notifier).addTransaction(
          title: title,
          amount: amount,
          type: type,
          category: category,
          date: DateTime.now(),
          paymentMode: 'UPI',
        );

    if (type == TransactionType.expense) {
      ref.read(budgetProvider.notifier).addExpenseToCategory(category, amount);
    }

    final allTxs = ref.read(transactionProvider);
    final newTx = allTxs.isNotEmpty ? allTxs.first : null;

    setState(() {
      _messages.add(
        ChatMessage(
          text: 'Saved ${Formatters.currency(amount)} to $category!',
          isUser: false,
          time: 'Just now',
          insight: 'Category budget allocated accordingly.',
          transactionData: newTx != null
              ? {
                  'id': newTx.id,
                  'amount': amount,
                  'category': category,
                  'title': title,
                }
              : null,
        ),
      );
    });
    _scrollToBottom();
  }

  void _undoTransaction(Map<String, dynamic> txData) {
    final id = txData['id'] as String;
    final amount = txData['amount'] as double;
    final category = txData['category'] as String;

    ref.read(budgetProvider.notifier).removeExpenseFromCategory(category, amount);
    ref.read(transactionProvider.notifier).deleteTransaction(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reverted transaction of ${Formatters.currency(amount)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _messages.add(
        ChatMessage(
          text: 'Undone! Removed ${Formatters.currency(amount)} from $category.',
          isUser: false,
          time: 'Just now',
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 180,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Make New Chat',
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 20),
                ),
                onPressed: _confirmNewChat,
              ),
            ),
          ),
        ],
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

            // Thinking Indicator
            if (_isThinking)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGreenBright),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ledgerly AI is thinking...',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    ),
                  ],
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
                          hintText: 'e.g. "Add 2000 dinner at Kismat Kathiyawadi"',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
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
                maxWidth: MediaQuery.of(context).size.width * 0.88,
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

                  // Interactive Clarification Chips (for incomplete queries)
                  if (msg.clarificationChips != null && msg.clarificationChips!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Select Category:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: msg.clarificationChips!.map((chip) {
                        return BouncingButton(
                          onPressed: () {
                            if (msg.pendingAmount != null) {
                              _completePendingTransaction(
                                chip,
                                msg.pendingAmount!,
                                msg.pendingType ?? TransactionType.expense,
                              );
                            }
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          child: Text(
                            chip,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Transaction Action Confirmation Card with "Undo"
                  if (msg.transactionData != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${msg.transactionData!['category']} • ${Formatters.currency(msg.transactionData!['amount'])}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF15803D)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _undoTransaction(msg.transactionData!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF86EFAC)),
                              ),
                              child: const Text(
                                'Undo',
                                style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Insight Container
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
