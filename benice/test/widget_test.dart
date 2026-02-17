import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:benice/presentation/providers/repository_providers.dart';
import 'package:benice/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Inicializar SharedPreferences para tests
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app con el override de SharedPreferences
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const BeniceAstroApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
