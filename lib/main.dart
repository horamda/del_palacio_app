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
    final status = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Empleados App',
      routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
      },
      home: switch (status) {
        AuthStatus.unknown        => const Scaffold(body: Center(child: CircularProgressIndicator())),
        AuthStatus.authenticated   => const DashboardScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}
