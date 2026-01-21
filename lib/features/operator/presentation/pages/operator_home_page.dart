import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/work_order.dart';
import '../widgets/work_order_card.dart';

/// Página principal del operador con acceso directo a sus funcionalidades
class OperatorHomePage extends ConsumerStatefulWidget {
  static const name = 'OperatorHomePage';

  const OperatorHomePage({super.key});

  @override
  ConsumerState<OperatorHomePage> createState() => _OperatorHomePageState();
}

class _OperatorHomePageState extends ConsumerState<OperatorHomePage> {
  // TODO: Reemplazar con datos del provider
  late List<WorkOrder> _recentOrders;
  late _OperatorStats _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _recentOrders = _getMockRecentOrders();
    _stats = _getMockStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: CustomScrollView(
        slivers: [
          // Header con saludo y stats
          _OperatorHomeHeader(
            operatorName: 'Carlos',
            stats: _stats,
          ),

          // Acciones rápidas
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _QuickActionsSection(
                onOrdersTap: () => context.push('/operator/work-orders'),
                onTicketsTap: () => context.push('/my-assigned-tickets'),
                onScanTap: _handleScan,
                onProfileTap: () => context.push('/profile'),
              ),
            ),
          ),

          // Órdenes pendientes de recepción
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _PendingReceptionSection(
                orders: _recentOrders
                    .where((o) => o.currentPhase == WorkPhase.pendingReception)
                    .toList(),
                onViewAll: () => context.push('/operator/work-orders'),
                onOrderTap: (order) =>
                    context.push('/operator/reception/${order.id}'),
              ),
            ),
          ),

          // Órdenes en progreso
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _InProgressSection(
                orders: _recentOrders
                    .where((o) =>
                        o.currentPhase == WorkPhase.inProgress ||
                        o.currentPhase == WorkPhase.diagnosis)
                    .toList(),
                onViewAll: () => context.push('/operator/work-orders'),
                onOrderTap: (order) =>
                    context.push('/operator/order/${order.id}'),
              ),
            ),
          ),

          // Resumen del día
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _DailySummarySection(stats: _stats),
            ),
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _handleScan() {
    // TODO: Implementar escaneo QR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escáner QR próximamente'),
        backgroundColor: Color(0xFF3498db),
      ),
    );
  }

  List<WorkOrder> _getMockRecentOrders() {
    return [
      WorkOrder(
        id: 'order-001',
        ticketId: 'TKT-001',
        orderNumber: '2024-0042',
        clientId: 'client-001',
        clientName: 'Juan Pérez',
        clientPhone: '+56 9 1234 5678',
        workType: WorkType.cameraInstallation,
        title: 'Instalación de Cámara de Retroceso',
        description: 'Instalación completa con pantalla',
        services: ['Cámara HD', 'Pantalla 4.3"'],
        vehicle: const VehicleInfo(
          brand: 'Toyota',
          model: 'Corolla',
          year: 2022,
          licensePlate: 'ABCD-12',
          color: 'Gris',
        ),
        currentPhase: WorkPhase.inProgress,
        priority: WorkPriority.normal,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: true,
        receptionPhotos: [],
        requiredParts: [],
        receivedParts: [],
        allPartsReceived: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        estimatedMinutes: 180,
        estimatedCost: 150000,
      ),
      WorkOrder(
        id: 'order-002',
        ticketId: 'TKT-002',
        orderNumber: '2024-0043',
        clientId: 'client-002',
        clientName: 'María García',
        clientPhone: '+56 9 8765 4321',
        workType: WorkType.detailing,
        title: 'Detailing Premium',
        description: 'Limpieza completa interior y exterior',
        services: ['Lavado', 'Pulido', 'Cerámica'],
        vehicle: const VehicleInfo(
          brand: 'Honda',
          model: 'CR-V',
          year: 2021,
          licensePlate: 'EFGH-34',
          color: 'Blanco',
        ),
        currentPhase: WorkPhase.pendingReception,
        priority: WorkPriority.high,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: false,
        receptionPhotos: [],
        requiredParts: [],
        receivedParts: [],
        allPartsReceived: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        estimatedMinutes: 240,
        estimatedCost: 180000,
      ),
      WorkOrder(
        id: 'order-003',
        ticketId: 'TKT-003',
        orderNumber: '2024-0044',
        clientId: 'client-003',
        clientName: 'Pedro Soto',
        clientPhone: '+56 9 5555 1234',
        workType: WorkType.sensorInstallation,
        title: 'Sensores de Estacionamiento',
        description: 'Instalación de 4 sensores traseros',
        services: ['Sensores x4', 'Display LED'],
        vehicle: const VehicleInfo(
          brand: 'Mazda',
          model: 'CX-5',
          year: 2023,
          licensePlate: 'IJKL-56',
          color: 'Rojo',
        ),
        currentPhase: WorkPhase.diagnosis,
        priority: WorkPriority.normal,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: true,
        receptionPhotos: [],
        requiredParts: ['Kit sensores'],
        receivedParts: ['Kit sensores'],
        allPartsReceived: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        startedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        estimatedMinutes: 120,
        estimatedCost: 95000,
      ),
      WorkOrder(
        id: 'order-004',
        ticketId: 'TKT-004',
        orderNumber: '2024-0045',
        clientId: 'client-004',
        clientName: 'Ana López',
        clientPhone: '+56 9 4444 5678',
        workType: WorkType.oilChange,
        title: 'Cambio de Aceite + Filtros',
        description: 'Cambio de aceite sintético y filtros',
        services: ['Aceite 5W-30', 'Filtro aceite', 'Filtro aire'],
        vehicle: const VehicleInfo(
          brand: 'Nissan',
          model: 'Sentra',
          year: 2020,
          licensePlate: 'MNOP-78',
          color: 'Negro',
          mileage: 45000,
        ),
        currentPhase: WorkPhase.pendingReception,
        priority: WorkPriority.low,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: false,
        receptionPhotos: [],
        requiredParts: ['Aceite 5W-30', 'Filtro aceite'],
        receivedParts: ['Aceite 5W-30', 'Filtro aceite'],
        allPartsReceived: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        estimatedMinutes: 45,
        estimatedCost: 55000,
      ),
    ];
  }

  _OperatorStats _getMockStats() {
    return _OperatorStats(
      pendingReception: 2,
      inProgress: 2,
      completedToday: 3,
      totalToday: 7,
      avgTimeMinutes: 95,
    );
  }
}

class _OperatorStats {
  final int pendingReception;
  final int inProgress;
  final int completedToday;
  final int totalToday;
  final int avgTimeMinutes;

  const _OperatorStats({
    required this.pendingReception,
    required this.inProgress,
    required this.completedToday,
    required this.totalToday,
    required this.avgTimeMinutes,
  });
}

class _OperatorHomeHeader extends StatelessWidget {
  final String operatorName;
  final _OperatorStats stats;

  const _OperatorHomeHeader({
    required this.operatorName,
    required this.stats,
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
                // Saludo
                FadeInDown(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.engineering,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              operatorName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Notificaciones
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats rápidos
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.pending_actions,
                          value: '${stats.pendingReception}',
                          label: 'Por recibir',
                          color: const Color(0xFFe67e22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.build,
                          value: '${stats.inProgress}',
                          label: 'En trabajo',
                          color: const Color(0xFF3498db),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.check_circle,
                          value: '${stats.completedToday}',
                          label: 'Completados',
                          color: const Color(0xFF27ae60),
                        ),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días,';
    if (hour < 18) return 'Buenas tardes,';
    return 'Buenas noches,';
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onOrdersTap;
  final VoidCallback onTicketsTap;
  final VoidCallback onScanTap;
  final VoidCallback onProfileTap;

  const _QuickActionsSection({
    required this.onOrdersTap,
    required this.onTicketsTap,
    required this.onScanTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.build_circle,
                  title: 'Mis Órdenes',
                  subtitle: 'Ver todas',
                  color: const Color(0xFF3498db),
                  onTap: onOrdersTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.assignment,
                  title: 'Tickets',
                  subtitle: 'Asignados',
                  color: const Color(0xFF9b59b6),
                  onTap: onTicketsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Escanear',
                  subtitle: 'Código QR',
                  color: const Color(0xFF27ae60),
                  onTap: onScanTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.person,
                  title: 'Mi Perfil',
                  subtitle: 'Configuración',
                  color: const Color(0xFF7f8c8d),
                  onTap: onProfileTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingReceptionSection extends StatelessWidget {
  final List<WorkOrder> orders;
  final VoidCallback onViewAll;
  final Function(WorkOrder) onOrderTap;

  const _PendingReceptionSection({
    required this.orders,
    required this.onViewAll,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFe67e22),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pendientes de Recepción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('Ver todo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.take(2).map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PendingReceptionCard(
                    order: order,
                    onTap: () => onOrderTap(order),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _PendingReceptionCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;

  const _PendingReceptionCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFe67e22).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFe67e22).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pending_actions,
                  color: Color(0xFFe67e22),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2c3e50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        if (order.priority == WorkPriority.high ||
                            order.priority == WorkPriority.urgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFe74c3c).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.priority.displayName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFe74c3c),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.vehicle.fullName} • ${order.clientName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFe67e22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Recibir',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InProgressSection extends StatelessWidget {
  final List<WorkOrder> orders;
  final VoidCallback onViewAll;
  final Function(WorkOrder) onOrderTap;

  const _InProgressSection({
    required this.orders,
    required this.onViewAll,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3498db),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'En Progreso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('Ver todo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.engineering,
                      size: 48,
                      color: Color(0xFFbdc3c7),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay trabajos en progreso',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...orders.take(3).map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WorkOrderCompactCard(
                      order: order,
                      onTap: () => onOrderTap(order),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _DailySummarySection extends StatelessWidget {
  final _OperatorStats stats;

  const _DailySummarySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF27ae60).withValues(alpha: 0.1),
              const Color(0xFF2ecc71).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF27ae60).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.insights,
                  color: Color(0xFF27ae60),
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Resumen del Día',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27ae60),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stats.completedToday}/${stats.totalToday}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.timer,
                    label: 'Tiempo Promedio',
                    value: _formatDuration(stats.avgTimeMinutes),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFF27ae60).withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.trending_up,
                    label: 'Eficiencia',
                    value: '${_calculateEfficiency(stats)}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  int _calculateEfficiency(_OperatorStats stats) {
    if (stats.totalToday == 0) return 100;
    return ((stats.completedToday / stats.totalToday) * 100).round();
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF27ae60),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2c3e50),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7f8c8d),
          ),
        ),
      ],
    );
  }
}
