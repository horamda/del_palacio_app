// lib/features/auth/data/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:del_palacio_app/core/network/dio_client.dart';
import 'package:del_palacio_app/core/storage/local_storage.dart';

/// Excepción específica de autenticación.
class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
}

/// Maneja login y persistencia de sesión.
class AuthRepository {
  /// Almacén local (SharedPreferences).
  final LocalStorage _storage = LocalStorage.instance;

  /// POST `/login` y guarda sesión (dni + token).
  Future<void> login({required String dni}) async {
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/login',
        data: {'dni': dni},
      );

      // Validar el flag success del backend
      final ok = res.data?['success'] as bool? ?? false;
      if (!ok) {
        final msg = res.data?['message'] as String? ?? 'Credenciales inválidas';
        throw AuthFailure(msg);
      }

      // Extraer token
      final token = res.data?['token'] as String?;
      if (token == null) {
        throw AuthFailure('Respuesta sin token');
      }

      await _storage.saveSession(dni, token);
    } on DioException catch (e) {
      // Captura error de red o backend
      final msg = e.response?.data?['message'] as String? ??
          e.message ??
          'Fallo de red o servidor';
      throw AuthFailure(msg);
    }
  }

  /// Devuelve `true` si existe una sesión guardada.
  Future<bool> restoreSession() async =>
      (await _storage.readSession()) != null;

  /// Elimina la sesión local.
  Future<void> logout() async => _storage.clear();
}
