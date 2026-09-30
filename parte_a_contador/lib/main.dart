import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/estado/contador_cubit.dart';
import 'presentation/estado/contador_observer.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  Bloc.observer = const ContadorObserver();

  final repository = ContadorPrefsRepository();

  runApp(
    MiApp(
      obtenerContador: ObtenerContador(repository),
      incrementar: Incrementar(repository),
      decrementar: Decrementar(repository),
    ),
  );
}

class MiApp extends StatelessWidget {
  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const MiApp({
    super.key,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  Widget build(BuildContext context) {
    // El BlocProvider va por encima del MaterialApp para que el Cubit
    // sea visible desde todas las rutas del Navigator.
    return BlocProvider(
      create: (_) =>
          ContadorCubit(obtenerContador, incrementar, decrementar)..cargar(),
      child: MaterialApp(
        title: 'Contador con Cubit',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const PantallaVisor(),
      ),
    );
  }
}
