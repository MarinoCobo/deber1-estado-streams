import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';

class ConexionCubit extends Cubit<EstadoConexion> {
  final ConsultarConexion _consultarConexion;
  final ObservarConexion _observarConexion;
  StreamSubscription<EstadoConexion>? _suscripcion;

  ConexionCubit(this._consultarConexion, this._observarConexion)
    : super(EstadoConexion.otro);

  /// Primero la foto inicial, despues la pelicula.
  Future<void> iniciar() async {
    final actual = await _consultarConexion();
    if (isClosed) return;
    emit(actual);
    _suscripcion = _observarConexion().listen(emit);
  }

  @override
  Future<void> close() async {
    await _suscripcion?.cancel();
    return super.close();
  }
}
