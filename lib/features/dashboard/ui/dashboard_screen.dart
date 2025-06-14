// lib/features/dashboard/ui/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:del_palacio_app/core/widgets/app_scaffold.dart';
import 'package:del_palacio_app/features/dashboard/logic/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Por ahora sector fijo = 1
    const sectorId = 1;

    final tarjetasAsync = ref.watch(tarjetasProvider(sectorId));

    return AppScaffold(
      title: 'Dashboard',
      body: tarjetasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tarjetas) {
          if (tarjetas.isEmpty) {
            return const Center(child: Text('Sin datos'));
          }

          // Primer indicador para el gráfico
          final primer = tarjetas.first;
          // Construir el gráfico con datos vacíos por ahora
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tarjetas
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var t in tarjetas)
                    Card(
                      color: Color(int.parse(t['color'].substring(1), radix: 16) +
                          0xFF000000),
                      child: SizedBox(
                        width: 150,
                        height: 80,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t['indicador'],
                                  style: const TextStyle(color: Colors.white)),
                              Text('${t['valor']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Serie: ${primer['indicador']}',
                  style: Theme.of(context).textTheme.titleMedium),
              AspectRatio(
                aspectRatio: 1.6,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [], // se llenará luego
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

