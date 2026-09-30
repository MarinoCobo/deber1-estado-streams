import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/repositories/conexion_repository.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/observar_conexion.dart';
import 'package:parte_b_conexion/main.dart';
import 'package:parte_b_conexion/presentation/estado/conexion_cubit.dart';

/// Simula el sistema operativo: cambiar() es "apagar o encender el Wi-Fi".
class ConexionFalsa implements ConexionRepository {
  final _cambios = StreamController<EstadoConexion>.broadcast();
  EstadoConexion actual = EstadoConexion.wifi;

  bool get hayOyentes => _cambios.hasListener;

  void cambiar(EstadoConexion nuevo) {
    actual = nuevo;
    _cambios.add(nuevo);
  }

  @override
  Future<EstadoConexion> consultarAhora() async => actual;

  @override
  Stream<EstadoConexion> observarCambios() => _cambios.stream;
}

Widget _app(ConexionFalsa repo) => MiApp(
  consultarConexion: ConsultarConexion(repo),
  observarConexion: ObservarConexion(repo),
);

void main() {
  testWidgets('Future: la foto no cambia hasta volver a consultar', (
    tester,
  ) async {
    final repo = ConexionFalsa();
    await tester.pumpWidget(_app(repo));

    await tester.tap(find.text('Consultar ahora'));
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);

    repo.cambiar(EstadoConexion.sinConexion);
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget); // sigue "mintiendo"

    await tester.tap(find.text('Consultar ahora'));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  testWidgets('Stream: la pantalla cambia sola', (tester) async {
    final repo = ConexionFalsa();
    await tester.pumpWidget(_app(repo));
    await tester.tap(find.text('Con Stream'));
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);

    repo.cambiar(EstadoConexion.sinConexion);
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);

    repo.cambiar(EstadoConexion.datosMoviles);
    await tester.pumpAndSettle();
    expect(find.text('Datos móviles'), findsOneWidget);
    expect(find.text('Cambios recibidos: 3'), findsOneWidget);

    // Al salir de la pestana el Cubit se cierra y cancela la suscripcion.
    await tester.tap(find.text('Con Future'));
    await tester.pumpAndSettle();
    expect(repo.hayOyentes, isFalse);
  });

  test('close() cancela la suscripcion', () async {
    final repo = ConexionFalsa();
    final cubit = ConexionCubit(
      ConsultarConexion(repo),
      ObservarConexion(repo),
    );
    await cubit.iniciar();
    expect(repo.hayOyentes, isTrue);

    await cubit.close();
    expect(repo.hayOyentes, isFalse);
  });
}
