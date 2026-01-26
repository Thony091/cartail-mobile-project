
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/service_tracking/presentation/widgets/service_tracking_widgets.dart';
import 'package:portafolio_project/features/ticket/presentation/providers/tickets_provider.dart';

import '../../domain/entities/service_status.dart';
import 'package:portafolio_project/features/ticket/domain/entities/ticket.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final ticketsState = ref.watch(ticketsProvider);
    final userId = authState.session?.user.id;

    final services = _buildUserServices(ticketsState.tickets, userId);
    final activeServices = services.where((s) => s.isActive).toList();
    final readyServices = services.where((s) => s.isReady).toList();
    final completedServices = services.where((s) => s.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _MyServicesHeader(
            activeCount: activeServices.length,
            readyCount: readyServices.length,
          ),
          SliverToBoxAdapter(
            child: _buildTabBar(activeServices, readyServices),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ServicesList(
              services: activeServices,
              emptyMessage: 'No tienes servicios activos',
              emptyIcon: Icons.build_circle_outlined,
              onServiceTap: _navigateToDetail,
            ),
            _ServicesList(
              services: readyServices,
              emptyMessage: 'No hay servicios listos para recoger',
              emptyIcon: Icons.check_circle_outline,
              onServiceTap: _navigateToDetail,
            ),
            _ServicesList(
              services: completedServices,
              emptyMessage: 'No tienes servicios completados',
              emptyIcon: Icons.history,
              onServiceTap: _navigateToDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(List<UserServiceRequest> active, List<UserServiceRequest> ready) {
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
                if (active.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _CountBadge(count: active.length),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Listos'),
                if (ready.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _CountBadge(
                    count: ready.length,
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

  List<UserServiceRequest> _buildUserServices(
    List<Ticket> tickets,
    String? userId,
  ) {
    if (userId == null) return [];
    return tickets
        .where((ticket) => ticket.userId == userId)
        .map(_ticketToServiceRequest)
        .toList();
  }

  UserServiceRequest _ticketToServiceRequest(Ticket ticket) {
    final status = _mapTicketState(ticket.stateId);
    final metadata = ticket.metadata;
    final vehicle = UserVehicleInfo(
      brand: metadata['vehicleBrand']?.toString() ?? 'Toyota',
      model: metadata['vehicleModel']?.toString() ?? 'Corolla',
      year: metadata['vehicleYear'] is int
          ? metadata['vehicleYear'] as int
          : 2022,
      licensePlate: metadata['licensePlate']?.toString() ?? '----',
      color: metadata['vehicleColor']?.toString() ?? 'Gris',
    );
    final List<String> included = [];
    if (metadata['includedItems'] is List) {
      included.addAll(List<String>.from(metadata['includedItems'] as List));
    }

    return UserServiceRequest(
      id: ticket.id,
      orderNumber: metadata['orderNumber']?.toString() ?? ticket.id,
      serviceName: ticket.title.isNotEmpty ? ticket.title : 'Servicio técnico',
      serviceDescription: ticket.description,
      includedItems: included,
      vehicle: vehicle,
      currentStatus: status,
      statusHistory: [
        StatusUpdate(
          status: status,
          timestamp: ticket.createdAt,
          message: ticket.metadata['statusNote']?.toString(),
        ),
      ],
      requestedAt: ticket.createdAt,
      estimatedCompletionDate: metadata['estimatedCompletion'] is String
          ? DateTime.tryParse(metadata['estimatedCompletion'] as String)
          : null,
      estimatedCost: metadata['estimatedCost'] is int
          ? metadata['estimatedCost'] as int
          : 0,
      finalCost: metadata['finalCost'] is int
          ? metadata['finalCost'] as int
          : null,
      workshopPhone: metadata['workshopPhone']?.toString() ?? '+56 2 0000 0000',
      assignedOperatorName: ticket.assignedToName ??
          (ticket.assignedToId != null && ticket.assignedToId!.isNotEmpty
              ? 'Operario ${ticket.assignedToId}'
              : null),
    );
  }

  ServiceStatus _mapTicketState(int? stateId) {
    switch (stateId) {
      case 1:
        return ServiceStatus.received;
      case 2:
        return ServiceStatus.inProgress;
      case 3:
        return ServiceStatus.ready;
      case 4:
      case 5:
        return ServiceStatus.delivered;
      default:
        return ServiceStatus.received;
    }
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
