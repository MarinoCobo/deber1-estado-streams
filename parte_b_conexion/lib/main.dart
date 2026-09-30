import 'package:flutter/material.dart';

import 'data/repositories/conexion_plus_repository.dart';
import 'domain/usecases/consultar_conexion.dart';
import 'domain/usecases/observar_conexion.dart';
import 'presentation/pantallas/pantalla_foto.dart';
import 'presentation/pantallas/pantalla_stream.dart';

void main() {
  final repository = ConexionPlusRepository();

  runApp(
    MiApp(
      consultarConexion: ConsultarConexion(repository),
      observarConexion: ObservarConexion(repository),
    ),
  );
}

class MiApp extends StatelessWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const MiApp({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detector de conexion',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Detector de conexión'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.photo_camera), text: 'Con Future'),
                Tab(icon: Icon(Icons.movie), text: 'Con Stream'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              PantallaFoto(consultarConexion: consultarConexion),
              PantallaStream(
                consultarConexion: consultarConexion,
                observarConexion: observarConexion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
