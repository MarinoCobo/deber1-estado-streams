import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/repositories/conexion_repository.dart';

class ConexionPlusRepository implements ConexionRepository {
  final Connectivity _connectivity;

  ConexionPlusRepository([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<EstadoConexion> consultarAhora() async =>
      _traducir(await _connectivity.checkConnectivity());

  @override
  Stream<EstadoConexion> observarCambios() =>
      _connectivity.onConnectivityChanged.map(_traducir);

  /// connectivity_plus devuelve una lista porque puede haber varias
  /// interfaces activas a la vez. Prioriza wifi, luego datos moviles.
  EstadoConexion _traducir(List<ConnectivityResult> resultados) {
    if (resultados.contains(ConnectivityResult.wifi)) {
      return EstadoConexion.wifi;
    }
    if (resultados.contains(ConnectivityResult.mobile)) {
      return EstadoConexion.datosMoviles;
    }
    if (resultados.isEmpty ||
        resultados.every((r) => r == ConnectivityResult.none)) {
      return EstadoConexion.sinConexion;
    }
    return EstadoConexion.otro;
  }
}
