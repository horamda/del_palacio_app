// lib/features/auth/data/usuario_actual.dart

class UsuarioActual {
  UsuarioActual({
    required this.dni,
    required this.nombre,
    required this.sector,
    required this.sectorId,
  });

  factory UsuarioActual.fromJson(Map<String, dynamic> json) {
    return UsuarioActual(
      dni: json['dni']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
      sectorId: int.tryParse(json['sector_id']?.toString() ?? '') ?? 0,
    );
  }
  final String dni;
  final String nombre;
  final String sector;
  final int sectorId;

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'sector': sector,
      'sector_id': sectorId,
    };
  }

  @override
  String toString() {
    return r'UsuarioActual(dni: $dni, nombre: $nombre, sector: $sector, sectorId: $sectorId)';
  }
}
