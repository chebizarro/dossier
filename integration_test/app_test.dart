import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dossier/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initializes correctly', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Dossier'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
