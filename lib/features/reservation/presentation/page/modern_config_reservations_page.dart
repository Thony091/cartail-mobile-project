import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_config_reservations_widgets.dart';

class ModernConfigReservationsPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigReservationsPage';

  const ModernConfigReservationsPage({super.key});

  @override
  ModernConfigReservationsPageState createState() =>
      ModernConfigReservationsPageState();
}

class ModernConfigReservationsPageState
    extends ConsumerState<ModernConfigReservationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterStatus = 'Todas';

  final List<String> _statusFilters = [
    'Todas',
    'Pendiente',
    'Confirmada',
    'Completada',
    'Cancelada',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simulación de datos
    final List<ReservationData> reservations = _getSimulatedReservations();

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Reservas',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
        ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: Column(
          children: [
            // Estadísticas
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ReservationStatCard(
                        value: '89',
                        label: 'Pendientes',
                        icon: Icons.pending,
                        color: const Color(0xFFf39c12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ReservationStatCard(
                        value: '156',
                        label: 'Completadas',
                        icon: Icons.check_circle,
                        color: const Color(0xFF27ae60),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tabs
            FadeInLeft(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF7f8c8d),
                  tabs: const [
                    Tab(text: 'Todas las Reservas'),
                    Tab(text: 'Hoy'),
                  ],
                ),
              ),
            ),

            // Lista de reservas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReservationsList(reservations),
                  _buildReservationsList(
                    reservations.where((r) => _isToday(r.date)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(List<ReservationData> reservations) {
    final filteredReservations = reservations.where((reservation) {
      final matchesSearch = reservation.clientName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesFilter =
          _filterStatus == 'Todas' || reservation.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredReservations.isEmpty) {
      return const ReservationsEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredReservations.length,
        itemBuilder: (context, index) {
          final reservation = filteredReservations[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: ReservationCard(
              reservation: reservation,
              onConfirmDismiss: (isConfirm) async {
                if (isConfirm) {
                  return await _showConfirmDialog(
                    '¿Confirmar reserva?',
                    '¿Deseas marcar esta reserva como confirmada?',
                  );
                } else {
                  return await _showConfirmDialog(
                    '¿Cancelar reserva?',
                    '¿Estás seguro de cancelar esta reserva?',
                  );
                }
              },
              onViewDetails: () => _showReservationDetails(reservation),
              onEdit: () {},
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchReservationDialog(
        onSearch: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterReservationDialog(
        currentFilter: _filterStatus,
        filters: _statusFilters,
        onFilterChanged: (value) {
          setState(() {
            _filterStatus = value;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showReservationDetails(ReservationData reservation) {
    showDialog(
      context: context,
      builder: (context) => ReservationDetailDialog(reservation: reservation),
    );
  }

  List<ReservationData> _getSimulatedReservations() {
    return [
      ReservationData(
        id: '1',
        clientName: 'Juan Pérez',
        clientEmail: 'juan@email.com',
        clientRut: '12345678-9',
        serviceName: 'Detailing Completo',
        date: DateTime.now(),
        time: '10:00',
        status: 'Pendiente',
      ),
      ReservationData(
        id: '2',
        clientName: 'María González',
        clientEmail: 'maria@email.com',
        clientRut: '98765432-1',
        serviceName: 'Lavado Express',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '14:30',
        status: 'Confirmada',
      ),
      ReservationData(
        id: '3',
        clientName: 'Carlos Silva',
        clientEmail: 'carlos@email.com',
        clientRut: '11111111-1',
        serviceName: 'Pulido y Encerado',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: '09:00',
        status: 'Completada',
      ),
      ReservationData(
        id: '4',
        clientName: 'Ana Martínez',
        clientEmail: 'ana@email.com',
        clientRut: '22222222-2',
        serviceName: 'Limpieza de Tapiz',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '16:00',
        status: 'Pendiente',
      ),
    ];
  }
}
