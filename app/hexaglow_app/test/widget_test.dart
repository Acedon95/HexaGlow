import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hexaglow_app/screens/home_screen.dart';
import 'package:hexaglow_app/services/hex_state_provider.dart';
import 'package:hexaglow_app/widgets/hexagon_widget.dart';

void main() {
  testWidgets('HomeScreen shows all 7 hexagons once loaded', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final provider = HexStateProvider();
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexagonWidget), findsNWidgets(7));
    expect(find.text('Color All'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });
}
