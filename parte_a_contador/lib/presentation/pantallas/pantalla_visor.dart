import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/contador_provider.dart';
import 'pantalla_control.dart';

class PantallaVisor extends ConsumerStatefulWidget {
  const PantallaVisor({super.key});

  @override
  ConsumerState<PantallaVisor> createState() => _PantallaVisorState();
}

class _PantallaVisorState extends ConsumerState<PantallaVisor> {
  @override
  void initState() {
    super.initState();
    ref.read(contadorProvider.notifier).cargar();
  }

  @override
  Widget build(BuildContext context) {
    final contador = ref.watch(contadorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contador: $contador',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaControl()),
              ),
              child: const Text('Ir a Control'),
            ),
          ],
        ),
      ),
    );
  }
}
