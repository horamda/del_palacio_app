// lib/core/storage/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja la sesión local (DNI + token) mediante `SharedPreferences`.
class LocalStorage {
  LocalStorage._internal();                    // constructor privado

  /// Instancia única para toda la app.
  static final LocalStorage instance = LocalStorage._internal();

  static const _keyDni   = 'dni';
  static const _keyToken = 'token';

  /// Guarda DNI y token de sesión.
  Future<void> saveSession(String dni, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDni, dni);
    await prefs.setString(_keyToken, token);
  }

  /// Devuelve `(dni, token)` o `null` si no hay sesión almacenada.
  Future<(String, String)?> readSession() async {
    final prefs  = await SharedPreferences.getInstance();
    final dni    = prefs.getString(_keyDni);
    final token  = prefs.getString(_keyToken);
    if (dni != null && token != null) return (dni, token);
    return null;
  }

  /// Borra la sesión almacenada.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDni);
    await prefs.remove(_keyToken);
  }
}
