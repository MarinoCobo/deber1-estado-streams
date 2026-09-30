import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Imprime cada cambio de estado, por ejemplo "ContadorCubit: 3 -> 4".
class ContadorObserver extends BlocObserver {
  const ContadorObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debugPrint(
      '${bloc.runtimeType}: ${change.currentState} -> ${change.nextState}',
    );
  }
}
