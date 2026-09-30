import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/contador_prefs_repository.dart';
import 'presentation/estado/contador_provider.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        contadorRepositoryProvider.overrideWithValue(ContadorPrefsRepository()),
      ],
      child: const MiApp(),
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador con Riverpod',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const PantallaVisor(),
    );
  }
}
