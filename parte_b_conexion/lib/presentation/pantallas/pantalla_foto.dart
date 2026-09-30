import 'package:flutter/material.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../widgets/indicador_conexion.dart';

/// Version Future: solo sabe lo que habia en el momento de pulsar el boton.
class PantallaFoto extends StatefulWidget {
  final ConsultarConexion consultarConexion;

  const PantallaFoto({super.key, required this.consultarConexion});

  @override
  State<PantallaFoto> createState() => _PantallaFotoState();
}

class _PantallaFotoState extends State<PantallaFoto> {
  EstadoConexion? _estado;
  DateTime? _hora;

  Future<void> _consultar() async {
    final estado = await widget.consultarConexion();
    if (!mounted) return;
    setState(() {
      _estado = estado;
      _hora = DateTime.now();
    });
  }

  String _formatear(DateTime h) =>
      [h.hour, h.minute, h.second].map((n) => '$n'.padLeft(2, '0')).join(':');

  @override
  Widget build(BuildContext context) {
    final estado = _estado;
    final hora = _hora;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (estado == null)
            const Text('Todavía no has consultado')
          else ...[
            IndicadorConexion(estado: estado),
            const SizedBox(height: 8),
            Text(
              'Consultado a las ${_formatear(hora!)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _consultar,
            icon: const Icon(Icons.refresh),
            label: const Text('Consultar ahora'),
          ),
        ],
      ),
    );
  }
}
