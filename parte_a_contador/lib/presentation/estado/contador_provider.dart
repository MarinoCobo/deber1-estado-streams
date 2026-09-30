import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/contador_repository.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

/// El repositorio concreto se inyecta desde main.dart con overrideWithValue,
/// asi presentation solo conoce el contrato del domain.
final contadorRepositoryProvider = Provider<ContadorRepository>(
  (ref) => throw UnimplementedError('Sobrescribe contadorRepositoryProvider'),
);

final obtenerContadorProvider = Provider(
  (ref) => ObtenerContador(ref.watch(contadorRepositoryProvider)),
);

final incrementarProvider = Provider(
  (ref) => Incrementar(ref.watch(contadorRepositoryProvider)),
);

final decrementarProvider = Provider(
  (ref) => Decrementar(ref.watch(contadorRepositoryProvider)),
);

class ContadorNotifier extends Notifier<int> {
  @override
  int build() => 0;

  Future<void> cargar() async {
    state = await ref.read(obtenerContadorProvider)();
  }

  Future<void> incrementar() async {
    state = await ref.read(incrementarProvider)();
  }

  Future<void> decrementar() async {
    state = await ref.read(decrementarProvider)();
  }
}

final contadorProvider = NotifierProvider<ContadorNotifier, int>(
  ContadorNotifier.new,
);
