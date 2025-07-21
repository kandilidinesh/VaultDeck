import 'package:flutter_test/flutter_test.dart';

import 'package:vaultdeck/main.dart';

void main() {
  testWidgets('VaultDeck app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app title appears.
    expect(find.text('VaultDeck'), findsOneWidget);

    // Verify that the empty state message appears when no cards are present.
    expect(find.text('Your vault is empty'), findsOneWidget);

    // Verify that the add card button is present.
    expect(find.text('Add Card'), findsOneWidget);
  });
}
