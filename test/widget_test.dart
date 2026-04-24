import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakats_new/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const YakatsApp());

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data?.startsWith('Running on:') ?? false,
      ),
      findsOneWidget,
    );
  });
}
