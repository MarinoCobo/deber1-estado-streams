import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/data/repositories/contador_prefs_repository.dart';
import 'package:parte_a_contador/main.dart';
import 'package:parte_a_contador/presentation/estado/contador_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app() => ProviderScope(
  overrides: [
    contadorRepositoryProvider.overrideWithValue(ContadorPrefsRepository()),
  ],
  child: const MiApp(),
);

void main() {
  testWidgets('+1 tres veces y Volver: el visor muestra 3 y persiste', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Contador: 0'), findsOneWidget);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 3'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('contador'), 3);
  });

  testWidgets('boton atras del sistema: el visor tambien muestra 4', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'contador': 3});
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('contador'), 4);
    expect(find.text('Contador: 4'), findsOneWidget);
  });
}
