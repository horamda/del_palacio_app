import 'dart:convert';
import 'package:flutter/material.dart';

class PerfilEmpleadoHeader extends StatelessWidget {
  const PerfilEmpleadoHeader({
    super.key,
    required this.nombre,
    required this.sector,
    required this.dni,
    required this.ultimaFecha,
    this.imagenBase64,
  });

  final String nombre;
  final String sector;
  final String dni;
  final String ultimaFecha;
  final String? imagenBase64;

  ImageProvider? _getImagen() {
    try {
      if (imagenBase64 == null || imagenBase64!.isEmpty) return null;
      final bytes = base64Decode(imagenBase64!.split(',').last);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: _getImagen(),
            backgroundColor: Colors.grey.shade800,
            child: imagenBase64 == null
                ? const Icon(Icons.person, size: 36, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          // Datos del empleado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $nombre!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sector: $sector  ·  DNI: $dni',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  'Último KPI: $ultimaFecha',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
