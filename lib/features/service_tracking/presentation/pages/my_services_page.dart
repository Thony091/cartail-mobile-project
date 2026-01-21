import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/service_status.dart';
import '../widgets/service_tracking_widgets.dart';

/// Página que muestra los servicios solicitados por el usuario
class MyServicesPage extends ConsumerStatefulWidget {
  static const name = 'MyServicesPage';

  const MyServicesPage({super.key});

  @override
  ConsumerState<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends ConsumerState<MyServicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: Reemplazar con datos del provider
  late List<UserServiceRequest> _services;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadServices();
  }

  void _loadServices() {
    _services = _getMockServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserServiceRequest> get _activeServices =>
      _services.where((s) => s.isActive).toList();

  List<UserServiceRequest> get _readyServices =>
      _services.where((s) => s.isReady).toList();

  List<UserServiceRequest> get _completedServices =>
      _services.where((s) => s.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _MyServicesHeader(
            activeCount: _activeServices.length,
            readyCount: _readyServices.length,
          ),
          SliverToBoxAdapter(
            child: _buildTabBar(),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ServicesList(
              services: _activeServices,
              emptyMessage: 'No tienes servicios activos',
              emptyIcon: Icons.build_circle_outlined,
              onServiceTap: _navigateToDetail,
            ),
            _ServicesList(
              services: _readyServices,
              emptyMessage: 'No hay servicios listos para recoger',
              emptyIcon: Icons.check_circle_outline,
              onServiceTap: _navigateToDetail,
            ),
            _ServicesList(
              services: _completedServices,
              emptyMessage: 'No tienes servicios completados',
              emptyIcon: Icons.history,
              onServiceTap: _navigateToDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3498db),
        unselectedLabelColor: const Color(0xFF95a5a6),
        indicatorColor: const Color(0xFF3498db),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Activos'),
                if (_activeServices.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _CountBadge(count: _activeServices.length),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Listos'),
                if (_readyServices.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _CountBadge(
                    count: _readyServices.length,
                    color: const Color(0xFF27ae60),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Historial'),
        ],
      ),
    );
  }

  void _navigateToDetail(UserServiceRequest service) {
    context.push('/my-services/${service.id}');
  }

  List<UserServiceRequest> _getMockServices() {
    return [
      UserServiceRequest(
        id: 'srv-001',
        orderNumber: '2024-0042',
        serviceName: 'Instalación de Cámara de Retroceso',
        serviceDescription:
            'Instalación completa de cámara con pantalla en espejo',
        includedItems: [
          'Cámara HD',
          'Pantalla 4.3"',
          'Cableado',
          'Instalación',
        ],
        vehicle: const UserVehicleInfo(
          brand: 'Toyota',
          model: 'Corolla',
          year: 2022,
          licensePlate: 'ABCD-12',
          color: 'Gris',
        ),
        currentStatus: ServiceStatus.inProgress,
        statusHistory: [
          StatusUpdate(
            status: ServiceStatus.received,
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            message: 'Vehículo recibido en el taller',
          ),
          StatusUpdate(
            status: ServiceStatus.inProgress,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            message: 'Comenzamos la instalación de tu cámara',
          ),
        ],
        requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
        estimatedCompletionDate: DateTime.now().add(const Duration(hours: 2)),
        estimatedCost: 150000,
        workshopPhone: '+56 2 1234 5678',
        assignedOperatorName: 'Carlos',
      ),
      UserServiceRequest(
        id: 'srv-002',
        orderNumber: '2024-0041',
        serviceName: 'Detailing Premium Completo',
        serviceDescription: 'Limpieza interior y exterior con protección',
        includedItems: [
          'Lavado exterior',
          'Aspirado interior',
          'Protección cerámica',
        ],
        vehicle: const UserVehicleInfo(
          brand: 'Honda',
          model: 'Civic',
          year: 2023,
          licensePlate: 'WXYZ-99',
          color: 'Negro',
        ),
        currentStatus: ServiceStatus.ready,
        statusHistory: [
          StatusUpdate(
            status: ServiceStatus.received,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          StatusUpdate(
            status: ServiceStatus.inProgress,
            timestamp:
                DateTime.now().subtract(const Duration(hours: 20)),
          ),
          StatusUpdate(
            status: ServiceStatus.ready,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            message:
                '¡Tu vehículo quedó impecable! Puedes venir a recogerlo cuando quieras.',
          ),
        ],
        requestedAt: DateTime.now().subtract(const Duration(days: 1)),
        estimatedCost: 180000,
        finalCost: 180000,
        workshopPhone: '+56 2 1234 5678',
        assignedOperatorName: 'Miguel',
      ),
      UserServiceRequest(
        id: 'srv-003',
        orderNumber: '2024-0038',
        serviceName: 'Cambio de Aceite + Filtros',
        serviceDescription: 'Mantenimiento preventivo completo',
        includedItems: [
          'Aceite sintético 5W-30',
          'Filtro de aceite',
          'Filtro de aire',
          'Revisión de 25 puntos',
        ],
        vehicle: const UserVehicleInfo(
          brand: 'Mazda',
          model: 'CX-5',
          year: 2021,
          licensePlate: 'MNOP-45',
          color: 'Rojo',
        ),
        currentStatus: ServiceStatus.delivered,
        statusHistory: [
          StatusUpdate(
            status: ServiceStatus.received,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
          StatusUpdate(
            status: ServiceStatus.inProgress,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
          StatusUpdate(
            status: ServiceStatus.ready,
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
          ),
          StatusUpdate(
            status: ServiceStatus.delivered,
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
            message: '¡Gracias por tu visita!',
          ),
        ],
        requestedAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 4)),
        estimatedCost: 75000,
        finalCost: 72000,
        workshopPhone: '+56 2 1234 5678',
      ),
      UserServiceRequest(
        id: 'srv-004',
        orderNumber: '2024-0035',
        serviceName: 'Instalación de Sensores de Estacionamiento',
        serviceDescription: '4 sensores traseros con display LED',
        includedItems: [
          'Sensores x4',
          'Display LED',
          'Instalación profesional',
        ],
        vehicle: const UserVehicleInfo(
          brand: 'Nissan',
          model: 'Sentra',
          year: 2020,
          licensePlate: 'QRST-67',
          color: 'Blanco',
        ),
        currentStatus: ServiceStatus.delivered,
        statusHistory: [
          StatusUpdate(
            status: ServiceStatus.received,
            timestamp: DateTime.now().subtract(const Duration(days: 10)),
          ),
          StatusUpdate(
            status: ServiceStatus.inProgress,
            timestamp: DateTime.now().subtract(const Duration(days: 10)),
          ),
          StatusUpdate(
            status: ServiceStatus.ready,
            timestamp: DateTime.now().subtract(const Duration(days: 9)),
          ),
          StatusUpdate(
            status: ServiceStatus.delivered,
            timestamp: DateTime.now().subtract(const Duration(days: 9)),
          ),
        ],
        requestedAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 9)),
        estimatedCost: 95000,
        finalCost: 95000,
        workshopPhone: '+56 2 1234 5678',
      ),
    ];
  }
}

class _MyServicesHeader extends StatelessWidget {
  final int activeCount;
  final int readyCount;

  const _MyServicesHeader({
    required this.activeCount,
    required this.readyCount,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                FadeInDown(
                  child: const Row(
                    children: [
                      Icon(
                        Icons.local_car_wash,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Mis Servicios',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                FadeInUp(
                  child: Text(
                    'Revisa el estado de tus vehículos en servicio',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Stats rápidos
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      if (activeCount > 0)
                        _QuickStatChip(
                          icon: Icons.build,
                          label: '$activeCount en proceso',
                          color: const Color(0xFF3498db),
                        ),
                      if (activeCount > 0 && readyCount > 0)
                        const SizedBox(width: 12),
                      if (readyCount > 0)
                        _QuickStatChip(
                          icon: Icons.check_circle,
                          label: '$readyCount listos',
                          color: const Color(0xFF27ae60),
                        ),
                      if (activeCount == 0 && readyCount == 0)
                        _QuickStatChip(
                          icon: Icons.check,
                          label: 'Sin servicios pendientes',
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const _CountBadge({
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF3498db),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  final List<UserServiceRequest> services;
  final String emptyMessage;
  final IconData emptyIcon;
  final Function(UserServiceRequest) onServiceTap;

  const _ServicesList({
    required this.services,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: const Color(0xFFbdc3c7),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF95a5a6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ServiceRequestCard(
              request: services[index],
              onTap: () => onServiceTap(services[index]),
            ),
          ),
        );
      },
    );
  }
}
