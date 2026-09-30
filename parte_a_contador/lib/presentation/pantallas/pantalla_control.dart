import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../estado/contador_cubit.dart';

class PantallaControl extends StatelessWidget {
  const PantallaControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<ContadorCubit, int>(
              builder: (context, valor) => Text(
                'Valor: $valor',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.read<ContadorCubit>().incrementar(),
              child: const Text('+1'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<ContadorCubit>().decrementar(),
              child: const Text('-1'),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
