import '../entities/estado_conexion.dart';

abstract class ConexionRepository {
  /// Una foto: el estado de la conexion en este instante.
  Future<EstadoConexion> consultarAhora();

  /// Una pelicula: emite un valor cada vez que la conexion cambia.
  Stream<EstadoConexion> observarCambios();
}
