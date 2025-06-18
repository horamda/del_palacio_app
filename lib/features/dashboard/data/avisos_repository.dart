import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:del_palacio_app/core/config/app_config.dart';
import 'aviso.dart';

/// Repositorio que obtiene avisos reales desde el backend.
class AvisosRepository {
  Future<List<Aviso>> getAvisos(String dni) async {
    if (dni.trim().isEmpty) {
      throw Exception('DNI no válido');
    }

    final url = Uri.parse('$baseUrl/avisos/$dni');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener avisos: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => Aviso.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}



