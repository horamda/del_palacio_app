
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:del_palacio_app/features/auth/data/auth_repository.dart';
import 'package:del_palacio_app/features/auth/data/usuario_actual.dart';

/// Estado de autenticación de la app.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Controlador de autenticación, usando Riverpod + StateNotifier.
class AuthController extends StateNotifier<AuthStatus> {

  AuthController(this._repo) : super(AuthStatus.unknown) {
    _init();
  }
  final AuthRepository _repo;

  /// Usuario actual obtenido desde el repositorio.
  UsuarioActual? get usuarioActual => _repo.usuarioActual;

  /// Intenta restaurar sesión al iniciar.
  Future<void> _init() async {
    final haySesion = await _repo.restoreSession();
    state = haySesion ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  /// Inicia sesión con el DNI dado.
  Future<void> login(String dni) async {
    try {
      await _repo.login(dni: dni);
      state = AuthStatus.authenticated;
    } catch (e) {
      // Puedes propagar el error o manejarlo aquí si prefieres.
      rethrow;
    }
  }

  /// Cierra la sesión.
  Future<void> logout() async {
    await _repo.logout();
    state = AuthStatus.unauthenticated;
  }
}

/// Provider del repositorio de autenticación.
final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider del controlador de autenticación.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStatus>((ref) {
  return AuthController(ref.read(authRepoProvider));
});
