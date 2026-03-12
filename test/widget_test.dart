import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:breathwork/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BreathworkApp()),
    );
    await tester.pumpAndSettle();

    // Verify home screen title is displayed
    expect(find.text('Breathwork'), findsOneWidget);
    expect(find.text('Box Breathing'), findsOneWidget);
  });
}
