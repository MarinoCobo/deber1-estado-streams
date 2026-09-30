import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/contador_repository.dart';

class ContadorPrefsRepository implements ContadorRepository {
  static const _clave = 'contador';

  @override
  Future<int> leer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_clave) ?? 0;
  }

  @override
  Future<void> guardar(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_clave, valor);
  }
}
