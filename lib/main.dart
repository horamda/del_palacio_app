import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:del_palacio_app/features/auth/logic/auth_providers.dart';
import 'package:del_palacio_app/features/auth/ui/login_screen.dart';
import 'package:del_palacio_app/features/dashboard/ui/dashboard_screen.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    Widget home;
    if (authState == AuthStatus.unknown) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (authState == AuthStatus.authenticated) {
      final usuario = ref.read(authControllerProvider.notifier).usuarioActual;
      home = usuario != null
          ? DashboardScreen(dni: usuario.dni)
          : const LoginScreen();
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: 'Empleados App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      routes: {
        '/api/login': (_) => const LoginScreen(),
        '/dashboard': (_) => Consumer(
          builder: (context, ref, _) {
            final usuario = ref.read(authControllerProvider.notifier).usuarioActual;
            return usuario != null
                ? DashboardScreen(dni: usuario.dni)
                : const LoginScreen();
          },
        ),
      },
      home: home,
    );
  }
}
