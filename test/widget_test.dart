import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app1/main.dart';

void main() {
  testWidgets('Kantin Bu Sari app smoke test', (WidgetTester tester) async {
    // Set screen size for test
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));

    // Verify Kantin Bu Sari title is rendered
    expect(find.text('Kantin Bu Sari'), findsWidgets);
  });
}
