import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:del_palacio_app/core/widgets/app_scaffold.dart';
import 'package:del_palacio_app/features/dashboard/logic/dashboard_providers.dart';
import 'package:del_palacio_app/features/dashboard/widgets/empleado_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    Key? key,
    required this.dni,
    this.sectorId = 1,
  }) : super(key: key);

  final String dni;
  final int sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleadoAsync = ref.watch(empleadoProvider(dni));

    return AppScaffold(
      title: 'Dashboard',
      body: empleadoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error cargando empleado:\n$e')),
        data: (empleadoData) {
          final datosRaw = empleadoData['chofer'];
          final tarjetasRaw = empleadoData['tarjetas'];

          if (datosRaw == null || datosRaw is! Map) {
            return const Center(child: Text('No se encontraron datos del empleado.'));
          }

          final datos = Map<String, dynamic>.from(datosRaw);
          final tarjetas = (tarjetasRaw is List)
              ? List<Map<String, dynamic>>.from(tarjetasRaw)
              : <Map<String, dynamic>>[];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(empleadoProvider(dni));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PerfilEmpleadoHeader(
                  nombre: datos['nombre']?.toString() ?? '',
                  sector: datos['sector']?.toString() ?? '',
                  dni: dni,
                  imagenBase64: datos['foto']?.toString(),
                  ultimaFecha: datos['fecha']?.toString() ?? '',
                ),
                const SizedBox(height: 16),
                if (tarjetas.isEmpty)
                  const Center(
                    child: Text(
                      'No hay KPIs disponibles.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                else
                  ...tarjetas.map((kpi) {
                    final titulo = kpi['indicador']?.toString() ?? 'Sin título';
                    final valor = kpi['valor']?.toString() ?? '';
                    return Card(
                      child: ListTile(
                        title: Text(titulo),
                        subtitle: Text(valor),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
