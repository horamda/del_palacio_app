import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:del_palacio_app/core/storage/local_storage.dart';

final empleadoProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, dni) async {
  final dio = Dio();

  final session = await LocalStorage.instance.readSession();
  final token = session?.token;

  if (token == null) {
    throw Exception('Token no encontrado. Es necesario iniciar sesión.');
  }

  print('Consultando KPI con DNI real: $dni');

  final response = await dio.get<Map<String, dynamic>>(
    'https://appdelpalacio.onrender.com/api/kpis_por_dni/$dni',
    options: Options(
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ),
  );

  if (response.statusCode == 200) {
    return response.data ?? {};
  } else {
    throw Exception('Error al cargar KPIs del empleado');
  }
});
