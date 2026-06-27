// DLA+ temel smoke testi: uygulama kök widget'ı çökmeden kurulabiliyor mu?

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('DlaPlusApp hatasız build edilir', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const DlaPlusApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
