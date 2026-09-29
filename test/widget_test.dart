import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgerly/main.dart';

void main() {
  testWidgets('Ledgerly app launches and smoke test passes', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LedgerlyApp()));
    expect(find.byType(LedgerlyApp), findsOneWidget);
    // Advance timers so splash delay completes cleanly
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
