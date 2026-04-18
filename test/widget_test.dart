import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_app/screens/splash/splash_screen.dart';

void main() {
  testWidgets('Splash shows app branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.text('Poultry Farm'), findsOneWidget);
    expect(find.text('Management System'), findsOneWidget);

    // Dispose splash before its delayed auth check executes.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
