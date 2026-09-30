import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';
import '../estado/conexion_cubit.dart';
import '../widgets/indicador_conexion.dart';

/// Version Stream: la pantalla se actualiza sola cuando el sistema avisa.
class PantallaStream extends StatelessWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const PantallaStream({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ConexionCubit(consultarConexion, observarConexion)..iniciar(),
      child: const _VistaStream(),
    );
  }
}

class _VistaStream extends StatefulWidget {
  const _VistaStream();

  @override
  State<_VistaStream> createState() => _VistaStreamState();
}

class _VistaStreamState extends State<_VistaStream> {
  int _cambios = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConexionCubit, EstadoConexion>(
      listener: (_, _) => setState(() => _cambios++),
      builder: (context, estado) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IndicadorConexion(estado: estado),
            const SizedBox(height: 24),
            Text(
              'Cambios recibidos: $_cambios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
