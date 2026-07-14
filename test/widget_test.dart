import 'package:daily_expression/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and renders the title', (tester) async {
    await tester.pumpWidget(const DailyExpressionApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
