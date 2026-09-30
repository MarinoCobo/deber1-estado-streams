import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/data/repositories/contador_prefs_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';
import 'package:parte_a_contador/presentation/estado/contador_observer.dart';
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
  setUp(() => Bloc.observer = const ContadorObserver());

  testWidgets('+1 +1 +1 -1 y Volver: visor en 2, observer registra todo', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    for (final boton in ['+1', '+1', '+1', '-1']) {
      await tester.tap(find.text(boton));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 2'), findsOneWidget);
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

    expect(find.text('Contador: 4'), findsOneWidget);
  });
}
