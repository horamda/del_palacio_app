// lib/features/auth/logic/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:del_palacio_app/features/auth/data/auth_repository.dart';

/// Repositorio de autenticación (HTTP + storage).
final authRepoProvider = Provider<AuthRepository>((_) => AuthRepository());

/// Estados globales posibles de autenticación.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Controlador que orquesta login, restauración y logout.
class AuthController extends StateNotifier<AuthStatus> {
  AuthController(this._repo) : super(AuthStatus.unknown) {
    _init();
  }

  final AuthRepository _repo;

  Future<void> _init() async {
    state = (await _repo.restoreSession())
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<void> login(String dni) async {
    await _repo.login(dni: dni);
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthStatus.unauthenticated;
  }

  /// Devuelve `true` si existe una sesión guardada.
  Future<bool> restoreSession() => _repo.restoreSession();
}

/// Proveedor global del controlador.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStatus>(
  (ref) => AuthController(ref.read(authRepoProvider)),
);
