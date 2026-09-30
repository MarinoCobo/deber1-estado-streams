import '../repositories/contador_repository.dart';

class Decrementar {
  final ContadorRepository repository;

  const Decrementar(this.repository);

  /// Lee el valor actual, le resta 1, lo guarda y devuelve el nuevo valor.
  Future<int> call() async {
    final nuevo = await repository.leer() - 1;
    await repository.guardar(nuevo);
    return nuevo;
  }
}
