// lib/core/storage/local_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:del_palacio_app/core/storage/session_data.dart';

class LocalStorage {
  static final LocalStorage instance = LocalStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LocalStorage._internal();

  static const _dniKey = 'dni';
  static const _tokenKey = 'token';
  static const _nombreKey = 'nombre';
  static const _sectorKey = 'sector';
  static const _sectorIdKey = 'sector_id';

  Future<void> saveSession(String dni, String token,
      {String nombre = '', String sector = '', int sectorId = 0}) async {
    await _storage.write(key: _dniKey, value: dni);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _nombreKey, value: nombre);
    await _storage.write(key: _sectorKey, value: sector);
    await _storage.write(key: _sectorIdKey, value: sectorId.toString());
  }

  Future<SessionData?> readSession() async {
    final dni = await _storage.read(key: _dniKey);
    final token = await _storage.read(key: _tokenKey);
    final nombre = await _storage.read(key: _nombreKey);
    final sector = await _storage.read(key: _sectorKey);
    final sectorId = await _storage.read(key: _sectorIdKey);

    if (dni == null || token == null) return null;

    return SessionData(
      dni: dni,
      token: token,
      nombre: nombre ?? '',
      sector: sector ?? '',
      sectorId: int.tryParse(sectorId ?? '') ?? 0,
    );
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
