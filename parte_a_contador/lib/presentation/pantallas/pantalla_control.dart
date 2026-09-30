import 'package:flutter/material.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';

class PantallaControl extends StatefulWidget {
  final int valorInicial;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const PantallaControl({
    super.key,
    required this.valorInicial,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  State<PantallaControl> createState() => _PantallaControlState();
}

class _PantallaControlState extends State<PantallaControl> {
  late int _valor = widget.valorInicial;

  Future<void> _sumar() async {
    final nuevo = await widget.incrementar();
    if (!mounted) return;
    setState(() => _valor = nuevo);
  }

  Future<void> _restar() async {
    final nuevo = await widget.decrementar();
    if (!mounted) return;
    setState(() => _valor = nuevo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Valor: $_valor',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _sumar, child: const Text('+1')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _restar, child: const Text('-1')),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, _valor),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
