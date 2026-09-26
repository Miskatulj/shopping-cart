import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('adds a product and opens the cart', (tester) async {
    await tester.pumpWidget(const ShoppingCartApp());
    expect(find.text('Daily essentials'), findsOneWidget);
    await tester.tap(find.text('Add to Cart').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(find.text('Total Items'), findsOneWidget);
  });
}
