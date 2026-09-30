import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/data/repositories/contador_prefs_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app() {
  final repository = ContadorPrefsRepository();
  return MiApp(
    obtenerContador: ObtenerContador(repository),
    incrementar: Incrementar(repository),
    decrementar: Decrementar(repository),
  );
}

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

  testWidgets(
    'boton atras del sistema: el disco tiene 4, el visor sigue en 3',
    (tester) async {
      SharedPreferences.setMockInitialValues({'contador': 3});
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ir a Control'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      // Simula el boton atras de Android: pop sin valor.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('contador'), 4);
      expect(find.text('Contador: 3'), findsOneWidget);
    },
  );
}
