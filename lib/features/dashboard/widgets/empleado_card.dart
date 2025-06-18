import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class EmpleadoCard extends StatelessWidget {
  const EmpleadoCard({
    super.key,
    required this.nombre,
    required this.sector,
    required this.dni,
    this.imagenBase64,
  });

  final String nombre;
  final String sector;
  final String dni;
  final String? imagenBase64;

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (imagenBase64 != null && imagenBase64!.isNotEmpty) {
      try {
        final cleaned = imagenBase64!.split(',').last;
        imageBytes = base64Decode(cleaned);
      } catch (_) {}
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: Theme.of(context).textTheme.titleMedium),
                  Text(sector, style: Theme.of(context).textTheme.bodyMedium),
                  Text('DNI: $dni', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
