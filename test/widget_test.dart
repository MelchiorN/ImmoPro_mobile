import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:immopro_mobile/main.dart';

void main() {
  testWidgets('ImmoPro app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ImmoproApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
