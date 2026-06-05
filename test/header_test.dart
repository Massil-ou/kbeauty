import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kbeauty/App/Manager.dart';
import 'package:kbeauty/Shared/KBeautyTheme.dart';
import 'package:kbeauty/Shared/KBeautyWidgets.dart';

void main() {
  testWidgets('public header shows authentication actions without menu',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KBeautyTheme.theme(),
        home: Scaffold(appBar: KBeautyHeader(manager: Manager())),
      ),
    );

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
  });
}
