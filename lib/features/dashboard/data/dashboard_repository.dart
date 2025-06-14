// lib/features/dashboard/data/dashboard_repository.dart
import 'package:del_palacio_app/core/network/dio_client.dart';

class DashboardRepository {
  /// Tarjetas KPI (endpoint /api/resumen_dashboard)
  Future<List<Map<String, dynamic>>> resumen({
    required int sectorId,
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/resumen_dashboard',
      queryParameters: {
        'sector_id': sectorId,
        'from': from.toIso8601String().substring(0, 10),
        'to':   to .toIso8601String().substring(0, 10),
      },
    );

    final list = res.data?['tarjetas'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Serie histórica (endpoint /api/serie_indicador)
  Future<Map<String, dynamic>> serie({
    required int indicadorId,
    required int sectorId,
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/serie_indicador',
      queryParameters: {
        'indicador_id': indicadorId,
        'sector_id': sectorId,
        'from': from.toIso8601String().substring(0, 10),
        'to':   to .toIso8601String().substring(0, 10),
      },
    );

    return res.data ?? <String, dynamic>{};
  }
}
