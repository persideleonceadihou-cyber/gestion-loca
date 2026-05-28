import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_locative/main.dart';

void main() {
  testWidgets('shows the local login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Mode local'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });
}
