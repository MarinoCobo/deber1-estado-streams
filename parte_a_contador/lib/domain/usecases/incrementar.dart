import '../repositories/contador_repository.dart';

class Incrementar {
  final ContadorRepository repository;

  const Incrementar(this.repository);

  /// Lee el valor actual, le suma 1, lo guarda y devuelve el nuevo valor.
  Future<int> call() async {
    final nuevo = await repository.leer() + 1;
    await repository.guardar(nuevo);
    return nuevo;
  }
}
