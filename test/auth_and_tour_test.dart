import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgerly/state/auth_state.dart';
import 'package:ledgerly/state/transaction_state.dart';
import 'package:ledgerly/state/budget_state.dart';
import 'package:ledgerly/core/services/local_vector_store.dart';
import 'package:ledgerly/features/onboarding/feature_tour_screen.dart';
import 'package:ledgerly/features/auth/signup_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth & User Data Isolation Tests', () {
    test('Test Account (Rahul Sharma, 9876543210) loads pre-populated demo data', () async {
      final container = ProviderScope(
        child: Container(),
      );

      final element = createElement(container);

      // Verify Test Account criteria
      expect(
        AuthNotifier.isTestAccount(email: 'sharahul@ledgerly.in', phone: '9876543210'),
        isTrue,
      );
      expect(
        AuthNotifier.isTestAccount(phone: '+91 98765 43210'),
        isTrue,
      );
      expect(
        AuthNotifier.isTestAccount(phone: '98765 43210'),
        isTrue,
      );

      final containerRef = ProviderContainer();

      // Log in with Test Account credentials
      await containerRef.read(authProvider.notifier).verifyOtp('123456', input: '9876543210');

      final auth = containerRef.read(authProvider);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.isTestAccount, isTrue);
      expect(auth.user?.fullName, 'Rahul Sharma');
      expect(auth.user?.email, 'sharahul@ledgerly.in');

      // Verify demo data IS shown for test account
      final transactions = containerRef.read(transactionProvider);
      expect(transactions.isNotEmpty, isTrue);
      expect(transactions.length, greaterThanOrEqualTo(5));

      final budget = containerRef.read(budgetProvider);
      expect(budget.totalBudget, 50000.0);
      expect(budget.totalSpent, greaterThan(0.0));
    });

    test('New Account Sign-Up ensures PRE DATA IS NOT SHOWN (clean state)', () async {
      final containerRef = ProviderContainer();

      // Sign up a brand new user
      await containerRef.read(authProvider.notifier).signUp(
            firstName: 'Aarav',
            lastName: 'Patel',
            email: 'aarav.patel@gmail.com',
            phone: '9123456780',
          );

      final auth = containerRef.read(authProvider);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.isTestAccount, isFalse);
      expect(auth.isNewUser, isTrue);
      expect(auth.user?.fullName, 'Aarav Patel');
      expect(auth.user?.email, 'aarav.patel@gmail.com');
      expect(auth.user?.phone, '9123456780');

      // CRITICAL: Ensure pre data is NOT shown to new user
      final transactions = containerRef.read(transactionProvider);
      expect(transactions.isEmpty, isTrue, reason: 'New account must have 0 transactions');

      final monthlySpending = containerRef.read(monthlySpendingProvider);
      expect(monthlySpending, 0.0, reason: 'New account must have ₹0 spending');

      final monthlyIncome = containerRef.read(monthlyIncomeProvider);
      expect(monthlyIncome, 0.0, reason: 'New account must have ₹0 income');

      final budget = containerRef.read(budgetProvider);
      expect(budget.totalBudget, 0.0);
      for (final cat in budget.categories) {
        expect(cat.spent, 0.0, reason: 'Category ${cat.name} must have ₹0 spent for new user');
      }

      // Check that LocalVectorStore has no vectors for new account
      expect(LocalVectorStore().count, 0);
    });

    test('Switching from New Account back to Test Account restores demo data', () async {
      final containerRef = ProviderContainer();

      // 1. Sign up new account
      await containerRef.read(authProvider.notifier).signUp(
            firstName: 'Priya',
            lastName: 'Verma',
            email: 'priya@example.com',
            phone: '9811122233',
          );

      expect(containerRef.read(transactionProvider).isEmpty, isTrue);

      // 2. Logout
      containerRef.read(authProvider.notifier).logout();
      expect(containerRef.read(authProvider).isAuthenticated, isFalse);

      // 3. Log back in with Test Account (9876543210)
      await containerRef.read(authProvider.notifier).verifyOtp('123456', input: '9876543210');
      final auth = containerRef.read(authProvider);
      expect(auth.isTestAccount, isTrue);
      expect(auth.user?.fullName, 'Rahul Sharma');

      // Demo data restored
      expect(containerRef.read(transactionProvider).isNotEmpty, isTrue);
    });
  });

  group('Feature Tour Screen Widget Tests', () {
    testWidgets('FeatureTourScreen renders with Skip button and feature steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FeatureTourScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Skip button exists
      expect(find.text('Skip Tour'), findsWidgets);

      // Verify first slide title
      expect(find.text('SMART DASHBOARD'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);

      // Tap Next Feature
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();

      // Verify second slide title
      expect(find.text('BUDGET HUB'), findsOneWidget);
      expect(find.text('Step 2 of 5'), findsOneWidget);

      // Tap Skip Tour button
      await tester.tap(find.text('Skip Tour').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('SignUpScreen displays Create Account button and has no test hints', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check button text is exactly 'Create Account'
      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Create Account & Start Tour'), findsNothing);

      // Check no test account chips or hints exist
      expect(find.textContaining('Test Demo Account'), findsNothing);
      expect(find.textContaining('Tap to fill Test Account'), findsNothing);
    });
  });
}

Element createElement(Widget widget) {
  final element = widget.createElement();
  return element;
}
