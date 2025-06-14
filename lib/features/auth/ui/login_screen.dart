// lib/features/auth/ui/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'package:del_palacio_app/features/auth/data/auth_repository.dart';
import 'package:del_palacio_app/features/auth/logic/auth_providers.dart';

/// Pantalla de login que permite autenticación por DNI
/// y, si está disponible, huella digital.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _auth = LocalAuthentication();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  /// Si el dispositivo soporta biometría, permite iniciar sesión con huella.
  Future<void> _checkBiometrics() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isAuth = canCheck &&
        await _auth.authenticate(
          localizedReason: 'Confirma tu identidad',
          options: const AuthenticationOptions(biometricOnly: true),
        );

    if (!isAuth || !mounted) return;

    // Si ya hay sesión guardada, navegar directo
    final ok =
        await ref.read(authControllerProvider.notifier).restoreSession();
    if (ok && mounted) {
      // ignore: use_build_context_synchronously
      await Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_dniCtrl.text.trim());
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(authControllerProvider);

    if (status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await Navigator.pushReplacementNamed(context, '/dashboard');
      });
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Iniciar sesión', style: TextStyle(fontSize: 24)),
                TextFormField(
                  controller: _dniCtrl,
                  decoration: const InputDecoration(labelText: 'DNI'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'DNI inválido' : null,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _onSubmit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
