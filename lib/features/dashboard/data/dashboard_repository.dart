
import 'package:del_palacio_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardRepository {
  /// Tarjetas KPI desde /api/resumen_dashboard
  Future<List<Map<String, dynamic>>> resumen({
    required int sectorId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/resumen_dashboard',
        queryParameters: {
          'sector_id': sectorId,
          'from': _formatDate(from),
          'to': _formatDate(to),
        },
      );

      final list = res.data?['tarjetas'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Error al cargar resumen: ${e.message}');
    }
  }

  /// Serie histórica desde /api/serie_indicador
  Future<Map<String, dynamic>> serie({
    required int indicadorId,
    required int sectorId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/serie_indicador',
        queryParameters: {
          'indicador_id': indicadorId,
          'sector_id': sectorId,
          'from': _formatDate(from),
          'to': _formatDate(to),
        },
      );
      return res.data ?? {};
    } on DioException catch (e) {
      throw Exception('Error al cargar serie: ${e.message}');
    }
  }

  /// Datos individuales del empleado (kpis por dni)
  Future<Map<String, dynamic>> datosEmpleado(String dni) async {
    try {
      if (dni.isEmpty) throw Exception('DNI no puede estar vacío');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token no disponible');

      print(r'Consultando KPI con DNI: $dni');

      final res = await dio.get<Map<String, dynamic>>(
        r'/kpis_por_dni/$dni',
        options: Options(
          headers: {
            'Authorization': r'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return res.data ?? {};
    } on DioException catch (e) {
      throw Exception('Error al obtener datos del empleado: ${e.message}');
    }
  }

  /// Utilitario para formatear fecha como 'yyyy-MM-dd'
  String _formatDate(DateTime date) => date.toIso8601String().substring(0, 10);
}
