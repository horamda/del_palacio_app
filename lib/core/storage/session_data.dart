// lib/core/storage/session_data.dart

class SessionData {
  final String dni;
  final String token;
  final String nombre;
  final String sector;
  final int sectorId;

  const SessionData({
    required this.dni,
    required this.token,
    this.nombre = '',
    this.sector = '',
    this.sectorId = 0,
  });
}
