import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:del_palacio_app/features/auth/logic/auth_providers.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton, // ✅ Nuevo parámetro opcional
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton; // ✅ Se agrega como propiedad

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(title)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Estás seguro que quieres salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sí, salir'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authControllerProvider.notifier).logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton, // ✅ Aquí se usa
    );
  }
}
