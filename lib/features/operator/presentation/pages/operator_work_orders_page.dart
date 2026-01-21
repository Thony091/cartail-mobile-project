import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/work_order.dart';
import '../widgets/work_order_card.dart';

class OperatorWorkOrdersPage extends ConsumerStatefulWidget {
  static const name = 'OperatorWorkOrdersPage';

  const OperatorWorkOrdersPage({super.key});

  @override
  ConsumerState<OperatorWorkOrdersPage> createState() =>
      _OperatorWorkOrdersPageState();
}

class _OperatorWorkOrdersPageState
    extends ConsumerState<OperatorWorkOrdersPage> {
  WorkPhase? _selectedFilter;

  // TODO: Reemplazar con datos del provider
  late List<WorkOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = _getMockOrders();
  }

  List<WorkOrder> get _filteredOrders {
    if (_selectedFilter == null) return _orders;
    return _orders.where((o) => o.currentPhase == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: CustomScrollView(
        slivers: [
          // AppBar
          _buildAppBar(),

          // Resumen de estadisticas
          SliverToBoxAdapter(
            child: FadeInDown(
              child: _StatsSummary(orders: _orders),
            ),
          ),

          // Filtros
          SliverToBoxAdapter(
            child: FadeInLeft(
              child: _PhaseFilters(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() => _selectedFilter = filter);
                },
                orders: _orders,
              ),
            ),
          ),

          // Lista de ordenes
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _filteredOrders.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyState(filter: _selectedFilter),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = _filteredOrders[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: WorkOrderCard(
                            order: order,
                            onTap: () => _openOrderDetail(order),
                            onQuickAction: () => _handleQuickAction(order),
                          ),
                        );
                      },
                      childCount: _filteredOrders.length,
                    ),
                  ),
          ),

          // Espacio al final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Escanear QR de orden o buscar
          _showSearchDialog();
        },
        backgroundColor: const Color(0xFF3498db),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear'),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFF2c3e50),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Mis Ordenes de Trabajo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_orders.length} ordenes asignadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // TODO: Refrescar ordenes
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Ver notificaciones
          },
        ),
      ],
    );
  }

  void _openOrderDetail(WorkOrder order) {
    context.push('/operator/order/${order.id}');
  }

  void _handleQuickAction(WorkOrder order) async {
    final nextPhase = order.nextPhase;
    if (nextPhase == null) return;

    // Si es recepcion, ir al checklist
    if (order.currentPhase == WorkPhase.pendingReception) {
      context.push('/operator/reception/${order.id}');
      return;
    }

    // Confirmar cambio de fase
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${_getActionVerb(order.currentPhase)} Orden'),
        content: Text(
          '¿Deseas cambiar el estado de la orden #${order.orderNumber} a "${nextPhase.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implementar cambio de fase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orden actualizada a ${nextPhase.displayName}'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    }
  }

  String _getActionVerb(WorkPhase phase) {
    switch (phase) {
      case WorkPhase.received:
        return 'Iniciar Diagnostico de';
      case WorkPhase.diagnosis:
        return 'Iniciar Trabajo en';
      case WorkPhase.inProgress:
        return 'Completar';
      case WorkPhase.qualityCheck:
        return 'Aprobar';
      case WorkPhase.completed:
        return 'Entregar';
      default:
        return 'Actualizar';
    }
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe2e8f0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Buscar Orden',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Numero de orden o patente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  Navigator.pop(context);
                  // TODO: Buscar orden
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Escanear QR
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escanear QR'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<WorkOrder> _getMockOrders() {
    return [
      WorkOrder(
        id: '1',
        ticketId: 'TKT-001',
        orderNumber: '2024-0042',
        clientId: 'client-001',
        clientName: 'Juan Perez',
        clientPhone: '+56 9 1234 5678',
        workType: WorkType.cameraInstallation,
        title: 'Instalacion de Camara de Retroceso',
        description: 'Instalacion completa con pantalla en espejo',
        services: ['Camara HD', 'Pantalla espejo', 'Instalacion'],
        vehicle: const VehicleInfo(
          brand: 'Toyota',
          model: 'Corolla',
          year: 2022,
          licensePlate: 'ABCD-12',
          color: 'Gris',
          mileage: 35000,
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
        id: '2',
        ticketId: 'TKT-002',
        orderNumber: '2024-0043',
        clientId: 'client-002',
        clientName: 'Maria Garcia',
        clientPhone: '+56 9 8765 4321',
        workType: WorkType.detailing,
        title: 'Detailing Premium Completo',
        description: 'Limpieza interior y exterior con proteccion ceramica',
        services: ['Lavado exterior', 'Aspirado interior', 'Ceramica'],
        vehicle: const VehicleInfo(
          brand: 'Honda',
          model: 'CR-V',
          year: 2021,
          licensePlate: 'EFGH-34',
          color: 'Blanco',
          mileage: 42000,
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
        id: '3',
        ticketId: 'TKT-003',
        orderNumber: '2024-0044',
        clientId: 'client-003',
        clientName: 'Pedro Sanchez',
        clientPhone: '+56 9 5555 5555',
        workType: WorkType.oilChange,
        title: 'Cambio de Aceite y Filtros',
        description: 'Cambio de aceite sintetico 5W-30 y filtros',
        services: ['Aceite 5W-30', 'Filtro aceite', 'Filtro aire'],
        vehicle: const VehicleInfo(
          brand: 'Mazda',
          model: 'CX-5',
          year: 2020,
          licensePlate: 'IJKL-56',
          color: 'Rojo',
          mileage: 58000,
        ),
        currentPhase: WorkPhase.diagnosis,
        priority: WorkPriority.normal,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: true,
        receptionPhotos: [],
        requiredParts: ['Aceite 5W-30 5L', 'Filtro aceite', 'Filtro aire'],
        receivedParts: ['Aceite 5W-30 5L', 'Filtro aceite'],
        allPartsReceived: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        estimatedMinutes: 60,
        estimatedCost: 65000,
      ),
      WorkOrder(
        id: '4',
        ticketId: 'TKT-004',
        orderNumber: '2024-0045',
        clientId: 'client-004',
        clientName: 'Ana Rodriguez',
        clientPhone: '+56 9 4444 4444',
        workType: WorkType.sensorInstallation,
        title: 'Instalacion Sensores de Estacionamiento',
        description: 'Sensores delanteros y traseros con pantalla',
        services: ['4 sensores traseros', '4 sensores delanteros', 'Pantalla'],
        vehicle: const VehicleInfo(
          brand: 'Kia',
          model: 'Sportage',
          year: 2023,
          licensePlate: 'MNOP-78',
          color: 'Negro',
          mileage: 12000,
        ),
        currentPhase: WorkPhase.qualityCheck,
        priority: WorkPriority.urgent,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: true,
        receptionPhotos: [],
        requiredParts: [],
        receivedParts: [],
        allPartsReceived: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        startedAt: DateTime.now().subtract(const Duration(hours: 4)),
        estimatedMinutes: 150,
        estimatedCost: 200000,
      ),
      WorkOrder(
        id: '5',
        ticketId: 'TKT-005',
        orderNumber: '2024-0046',
        clientId: 'client-005',
        clientName: 'Carlos Mendez',
        clientPhone: '+56 9 3333 3333',
        workType: WorkType.mechanicalRepair,
        title: 'Revision de Frenos',
        description: 'Revision y cambio de pastillas de freno',
        services: ['Revision', 'Pastillas delanteras', 'Liquido frenos'],
        vehicle: const VehicleInfo(
          brand: 'Hyundai',
          model: 'Tucson',
          year: 2019,
          licensePlate: 'QRST-90',
          color: 'Azul',
          mileage: 75000,
        ),
        currentPhase: WorkPhase.completed,
        priority: WorkPriority.normal,
        phaseHistory: [],
        receptionChecklist: [],
        receptionCompleted: true,
        receptionPhotos: [],
        requiredParts: [],
        receivedParts: [],
        allPartsReceived: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        startedAt: DateTime.now().subtract(const Duration(hours: 20)),
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        estimatedMinutes: 120,
        estimatedCost: 95000,
        finalCost: 92000,
      ),
    ];
  }
}

class _StatsSummary extends StatelessWidget {
  final List<WorkOrder> orders;

  const _StatsSummary({required this.orders});

  @override
  Widget build(BuildContext context) {
    final pending = orders
        .where((o) =>
            o.currentPhase == WorkPhase.pendingReception ||
            o.currentPhase == WorkPhase.received)
        .length;
    final inProgress = orders
        .where((o) =>
            o.currentPhase == WorkPhase.diagnosis ||
            o.currentPhase == WorkPhase.inProgress ||
            o.currentPhase == WorkPhase.waitingParts)
        .length;
    final completed = orders
        .where((o) =>
            o.currentPhase == WorkPhase.qualityCheck ||
            o.currentPhase == WorkPhase.completed)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.hourglass_empty,
              label: 'Pendientes',
              count: pending,
              color: const Color(0xFFf39c12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.construction,
              label: 'En Trabajo',
              count: inProgress,
              color: const Color(0xFF3498db),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              label: 'Listos',
              count: completed,
              color: const Color(0xFF27ae60),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseFilters extends StatelessWidget {
  final WorkPhase? selectedFilter;
  final ValueChanged<WorkPhase?> onFilterChanged;
  final List<WorkOrder> orders;

  const _PhaseFilters({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            count: orders.length,
            isSelected: selectedFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pendientes',
            count: orders
                .where((o) => o.currentPhase == WorkPhase.pendingReception)
                .length,
            isSelected: selectedFilter == WorkPhase.pendingReception,
            color: const Color(0xFFf39c12),
            onTap: () => onFilterChanged(WorkPhase.pendingReception),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'En Progreso',
            count:
                orders.where((o) => o.currentPhase == WorkPhase.inProgress).length,
            isSelected: selectedFilter == WorkPhase.inProgress,
            color: const Color(0xFF3498db),
            onTap: () => onFilterChanged(WorkPhase.inProgress),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Control QC',
            count: orders
                .where((o) => o.currentPhase == WorkPhase.qualityCheck)
                .length,
            isSelected: selectedFilter == WorkPhase.qualityCheck,
            color: const Color(0xFF1abc9c),
            onTap: () => onFilterChanged(WorkPhase.qualityCheck),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completados',
            count:
                orders.where((o) => o.currentPhase == WorkPhase.completed).length,
            isSelected: selectedFilter == WorkPhase.completed,
            color: const Color(0xFF27ae60),
            onTap: () => onFilterChanged(WorkPhase.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF3498db);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor
              : effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? effectiveColor
                : effectiveColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : effectiveColor,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : effectiveColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : effectiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final WorkPhase? filter;

  const _EmptyState({this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filter != null ? Icons.filter_alt_off : Icons.inbox_outlined,
              size: 80,
              color: const Color(0xFFbdc3c7),
            ),
            const SizedBox(height: 16),
            Text(
              filter != null
                  ? 'No hay ordenes ${filter!.displayName.toLowerCase()}'
                  : 'No tienes ordenes asignadas',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7f8c8d),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filter != null
                  ? 'Intenta con otro filtro'
                  : 'Las nuevas ordenes apareceran aqui',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF95a5a6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
