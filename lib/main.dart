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
    return MaterialApp(
      title: 'Del Palacio App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1976D2), // Azul más específico
        brightness: Brightness.light,
      ),
      // Rutas más claras y semánticas
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardWrapper(),
      },
      home: const AuthWrapper(),
    );
  }
}

// Wrapper que maneja la autenticación con mejor UX
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildScreen(authState, ref),
    );
  }

  Widget _buildScreen(AuthStatus authState, WidgetRef ref) {
    switch (authState) {
      case AuthStatus.unknown:
        return const SplashScreen();
      
      case AuthStatus.authenticated:
        final usuario = ref.read(authControllerProvider.notifier).usuarioActual;
        return usuario != null 
            ? DashboardScreen(dni: usuario.dni)
            : const LoginScreen();
      
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}

// Pantalla de splash mejorada
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o branding
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.business,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Título
            Text(
              'Del Palacio',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Gestión de Empleados',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Indicador de carga más elegante
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Cargando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper para el dashboard con manejo de errores
class DashboardWrapper extends ConsumerWidget {
  const DashboardWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.read(authControllerProvider.notifier).usuarioActual;
    
    if (usuario == null) {
      // Si no hay usuario, redirigir al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SplashScreen();
    }
    
    return DashboardScreen(dni: usuario.dni);
  }
}

// Extensión para facilitar la navegación
extension NavigationExtension on BuildContext {
  void goToLogin() {
    Navigator.of(this).pushReplacementNamed('/login');
  }
  
  void goToDashboard() {
    Navigator.of(this).pushReplacementNamed('/dashboard');
  }
}
