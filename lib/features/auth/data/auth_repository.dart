// lib/features/auth/data/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:del_palacio_app/core/network/dio_client.dart';
import 'package:del_palacio_app/core/storage/local_storage.dart';
import 'package:del_palacio_app/features/auth/data/usuario_actual.dart';

/// Excepción específica para errores de autenticación.
class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Repositorio de autenticación: login, sesión y logout.
class AuthRepository {
  final LocalStorage _storage = LocalStorage.instance;
  UsuarioActual? _usuarioActual;
  UsuarioActual? get usuarioActual => _usuarioActual;

  /// POST `/login` y guarda sesión (dni + token).
  Future<void> login({required String dni}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/login',
        data: {'dni': dni},
      );

      final data = response.data;
      if (data == null) throw AuthFailure('Respuesta vacía del servidor');

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Credenciales inválidas';
        throw AuthFailure(message);
      }

      final token = data['token'] as String? ?? '';
      if (token.isEmpty) throw AuthFailure('Token no encontrado en la respuesta');

      _usuarioActual = UsuarioActual.fromJson(data);
      await _storage.saveSession(dni, token);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String?
          : null;
      throw AuthFailure(message ?? e.message ?? 'Error de red o del servidor');
    } catch (e) {
      throw AuthFailure('Error inesperado: ${e.toString()}');
    }
  }

  /// Devuelve `true` si hay una sesión guardada.
  Future<bool> restoreSession() async {
  final session = await _storage.readSession();
  if (session == null) return false;

  _usuarioActual = UsuarioActual(
    dni: session.dni,
    nombre: session.nombre,
    sector: session.sector,
    sectorId: session.sectorId,
  );

  print('[AuthRepository] Sesión restaurada para DNI ${session.dni}');
  return true;
}


  /// Borra la sesión local (logout).
  Future<void> logout() async {
    await _storage.clear();
    _usuarioActual = null;
    print('[AuthRepository] Logout completo');
  }
}
