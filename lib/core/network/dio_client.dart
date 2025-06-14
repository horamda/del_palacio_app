// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:del_palacio_app/core/config/app_config.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: '$baseUrl/api',      // ← aquí
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ),
)..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
