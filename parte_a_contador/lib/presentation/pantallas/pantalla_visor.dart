import 'package:flutter/material.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';
import 'pantalla_control.dart';

class PantallaVisor extends StatefulWidget {
  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const PantallaVisor({
    super.key,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  State<PantallaVisor> createState() => _PantallaVisorState();
}

class _PantallaVisorState extends State<PantallaVisor> {
  int _contador = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final valor = await widget.obtenerContador();
    if (!mounted) return;
    setState(() => _contador = valor);
  }

  Future<void> _irAControl() async {
    // El valor viaja de ida por constructor y de vuelta como resultado del pop.
    final resultado = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaControl(
          valorInicial: _contador,
          incrementar: widget.incrementar,
          decrementar: widget.decrementar,
        ),
      ),
    );

    // Si se sale con el boton atras del sistema, resultado llega null.
    if (resultado != null) {
      setState(() => _contador = resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contador: $_contador',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _irAControl,
              child: const Text('Ir a Control'),
            ),
          ],
        ),
      ),
    );
  }
}
