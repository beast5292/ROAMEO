// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homepage/main.dart';

void main() {
  testWidgets('Verify if "Start here." text is displayed',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Replace `MyApp` with your main widget.

    // Verify if the text "Start here." is found.
    expect(find.text('Start here.'), findsOneWidget);

    // Verify if a non-existent text is not found.
    expect(find.text('Non-existent text'), findsNothing);

    // Verify if a specific button (e.g., "Happy") exists.
    expect(find.text('Happy'), findsOneWidget);
  });

  testWidgets('Test navigation bar icons', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify if the home icon is present.
    expect(find.byIcon(Icons.home), findsOneWidget);

    // Verify if the globe icon is present.
    expect(find.byIcon(Icons.language), findsOneWidget);
  });
}
