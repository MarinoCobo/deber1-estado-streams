import 'package:flutter/material.dart';

import '../../domain/entities/estado_conexion.dart';

/// Muestra el estado en grande, con icono y color.
class IndicadorConexion extends StatelessWidget {
  final EstadoConexion estado;

  const IndicadorConexion({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final (texto, icono) = switch (estado) {
      EstadoConexion.wifi => ('Wi-Fi', Icons.wifi),
      EstadoConexion.datosMoviles => (
        'Datos móviles',
        Icons.signal_cellular_alt,
      ),
      EstadoConexion.otro => ('Otra conexión', Icons.lan),
      EstadoConexion.sinConexion => ('Sin conexión', Icons.wifi_off),
    };
    final color = estado == EstadoConexion.sinConexion
        ? Colors.red
        : Colors.green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 96, color: color),
        const SizedBox(height: 12),
        Text(
          texto,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
