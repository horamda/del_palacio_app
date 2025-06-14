// lib/features/dashboard/logic/dashboard_providers.dart
import 'package:flutter/material.dart';                     // ← agrega
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:del_palacio_app/features/dashboard/data/dashboard_repository.dart';

final dashboardRepoProvider =
    Provider<DashboardRepository>((_) => DashboardRepository());

// Últimos 7 días como rango inicial
final rangoProvider = StateProvider<DateTimeRange>((ref) {
  final hoy = DateTime.now();
  return DateTimeRange(
    start: hoy.subtract(const Duration(days: 6)),
    end: hoy,
  );
});

/// Tarjetas KPI para un sector
final tarjetasProvider = FutureProvider.family<
    List<Map<String, dynamic>>, int>((ref, sectorId) async {
  final rango = ref.watch(rangoProvider);
  final repo  = ref.read(dashboardRepoProvider);
  return repo.resumen(
    sectorId: sectorId,                       // ← usa nombre
    from: rango.start,
    to  : rango.end,
  );
});

/// Serie histórica para un indicador
final serieProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>,
    ({int indicadorId, int sectorId})>((ref, params) async {
  final rango = ref.watch(rangoProvider);
  final repo  = ref.read(dashboardRepoProvider);
  return repo.serie(
    indicadorId: params.indicadorId,
    sectorId   : params.sectorId,
    from: rango.start,
    to  : rango.end,
  );
});
