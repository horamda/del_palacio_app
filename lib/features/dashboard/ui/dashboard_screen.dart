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
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Dashboard',
      body: empleadoAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => _buildErrorState(e.toString()),
        data: (empleadoData) {
          final datosRaw = empleadoData['chofer'];
          final tarjetasRaw = empleadoData['tarjetas'];

          if (datosRaw == null || datosRaw is! Map) {
            return _buildEmptyState();
          }

          final datos = Map<String, dynamic>.from(datosRaw);
          final tarjetas = (tarjetasRaw is List)
              ? List<Map<String, dynamic>>.from(tarjetasRaw)
              : <Map<String, dynamic>>[];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(empleadoProvider(dni));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del empleado con diseño mejorado
                  _buildHeaderSection(datos, theme),
                  
                  // Sección de acciones rápidas
                  _buildQuickActionsSection(context, theme),
                  
                  // Sección de KPIs
                  _buildKPIsSection(tarjetas, theme),
                  
                  // Sección de avisos
                  _buildAvisosSection(theme),
                  
                  const SizedBox(height: 80), // Espacio para el FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error cargando datos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron datos del empleado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> datos, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PerfilEmpleadoHeader(
          nombre: datos['nombre']?.toString() ?? '',
          sector: datos['sector']?.toString() ?? '',
          dni: dni,
          imagenBase64: datos['foto']?.toString(),
          ultimaFecha: datos['fecha']?.toString() ?? '',
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: Icons.receipt_long,
                title: 'Solicitar Vales',
                subtitle: 'Combustible y otros',
                color: Colors.blue,
                onTap: () => _onSolicitarVales(context),
              ),
              _buildActionCard(
                icon: Icons.inventory_2,
                title: 'Solicitar Mercadería',
                subtitle: 'Productos y materiales',
                color: Colors.green,
                onTap: () => _onSolicitarMercaderia(context),
              ),
              _buildActionCard(
                icon: Icons.notifications_active,
                title: 'Ver Avisos',
                subtitle: 'Notificaciones importantes',
                color: Colors.orange,
                onTap: () => _onVerAvisos(context),
              ),
              _buildActionCard(
                icon: Icons.analytics,
                title: 'Reportes',
                subtitle: 'Estadísticas y métricas',
                color: Colors.purple,
                onTap: () => _onVerReportes(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIsSection(List<Map<String, dynamic>> tarjetas, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicadores de Rendimiento',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (tarjetas.isEmpty)
            _buildEmptyKPIsState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tarjetas.length,
              itemBuilder: (context, index) {
                final kpi = tarjetas[index];
                return _buildKPICard(kpi, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyKPIsState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay KPIs disponibles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los indicadores aparecerán aquí cuando estén disponibles',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(Map<String, dynamic> kpi, int index) {
    final titulo = kpi['indicador']?.toString() ?? 'Sin título';
    final valor = kpi['valor']?.toString() ?? '';
    
    // Colores alternativos para los KPIs
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getKPIIcon(titulo),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valor,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvisosSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avisos Recientes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // Aquí podrías agregar un Consumer para avisos
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
              ),
              title: const Text('Bienvenido al dashboard'),
              subtitle: const Text('Tu panel de control está listo para usar'),
              trailing: Text(
                'Hoy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActionsMenu(context),
      icon: const Icon(Icons.add),
      label: const Text('Acciones'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  IconData _getKPIIcon(String titulo) {
    final tituloLower = titulo.toLowerCase();
    if (tituloLower.contains('viaje') || tituloLower.contains('ruta')) {
      return Icons.route;
    } else if (tituloLower.contains('combustible') || tituloLower.contains('gasolina')) {
      return Icons.local_gas_station;
    } else if (tituloLower.contains('tiempo') || tituloLower.contains('hora')) {
      return Icons.access_time;
    } else if (tituloLower.contains('dinero') || tituloLower.contains('peso')) {
      return Icons.attach_money;
    } else if (tituloLower.contains('distancia') || tituloLower.contains('km')) {
      return Icons.straighten;
    } else {
      return Icons.trending_up;
    }
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: const Text('Solicitar Vales'),
              onTap: () {
                Navigator.pop(context);
                _onSolicitarVales(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.green),
              title: const Text('Solicitar Mercadería'),
              onTap: () {
                Navigator.pop(context);
                _onSolicitarMercaderia(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text('Ver Avisos'),
              onTap: () {
                Navigator.pop(context);
                _onVerAvisos(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Métodos para manejar las acciones
  void _onSolicitarVales(BuildContext context) {
    // Navegar a la pantalla de solicitud de vales
    // Navigator.pushNamed(context, '/solicitar-vales');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de solicitar vales próximamente')),
    );
  }

  void _onSolicitarMercaderia(BuildContext context) {
    // Navegar a la pantalla de solicitud de mercadería
    // Navigator.pushNamed(context, '/solicitar-mercaderia');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de solicitar mercadería próximamente')),
    );
  }

  void _onVerAvisos(BuildContext context) {
    // Navegar a la pantalla de avisos
    // Navigator.pushNamed(context, '/avisos');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de ver avisos próximamente')),
    );
  }

  void _onVerReportes(BuildContext context) {
    // Navegar a la pantalla de reportes
    // Navigator.pushNamed(context, '/reportes');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de ver reportes próximamente')),
    );
  }
}
