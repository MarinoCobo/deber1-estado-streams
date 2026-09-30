import '../repositories/contador_repository.dart';

class ObtenerContador {
  final ContadorRepository repository;

  const ObtenerContador(this.repository);

  /// Devuelve el valor guardado del contador.
  Future<int> call() => repository.leer();
}
