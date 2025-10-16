import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_card.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_input_field.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernConfigReservationsPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigReservationsPage';
  
  const ModernConfigReservationsPage({super.key});

  @override
  ModernConfigReservationsPageState createState() => ModernConfigReservationsPageState();
}

class ModernConfigReservationsPageState extends ConsumerState<ModernConfigReservationsPage> 
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
                      child: _buildStatCard(
                        '89',
                        'Pendientes',
                        Icons.pending,
                        const Color(0xFFf39c12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '156',
                        'Completadas',
                        Icons.check_circle,
                        const Color(0xFF27ae60),
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

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return ModernCard(
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(List<ReservationData> reservations) {
    final filteredReservations = reservations.where((reservation) {
      final matchesSearch = reservation.clientName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == 'Todas' || 
          reservation.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredReservations.isEmpty) {
      return _buildEmptyState();
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
            child: _buildReservationCard(reservation),
          );
        },
      ),
    );
  }

  Widget _buildReservationCard(ReservationData reservation) {
    final statusColor = _getStatusColor(reservation.status);
    
    return Dismissible(
      key: Key(reservation.id),
      background: _buildDismissBackground(
        const Color(0xFF27ae60),
        Icons.check,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        const Color(0xFFe74c3c),
        Icons.delete,
        Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar del cliente
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        reservation.clientName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Información del cliente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.clientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reservation.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Detalles de la reserva
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.calendar_today,
                      '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time,
                      reservation.time,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.email_outlined,
                      reservation.clientEmail,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Acciones
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Ver Detalles',
                      icon: Icons.visibility,
                      style: ModernButtonStyle.secondary,
                      onPressed: () => _showReservationDetails(reservation),
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernButton(
                      text: 'Editar',
                      icon: Icons.edit,
                      style: ModernButtonStyle.primary,
                      onPressed: () {},
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF7f8c8d),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7f8c8d),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF7f8c8d).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.event_busy,
              size: 60,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay reservas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No se encontraron reservas con los filtros aplicados',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(Color color, IconData icon, Alignment alignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return const Color(0xFFf39c12);
      case 'Confirmada':
        return const Color(0xFF3498db);
      case 'Completada':
        return const Color(0xFF27ae60);
      case 'Cancelada':
        return const Color(0xFFe74c3c);
      default:
        return const Color(0xFF7f8c8d);
    }
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Buscar Reserva'),
        content: ModernInputField(
          hint: 'Nombre del cliente...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          ModernButton(
            text: 'Cerrar',
            style: ModernButtonStyle.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Filtrar por Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusFilters.map((status) {
            return RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: _filterStatus,
              activeColor: const Color(0xFF3498db),
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
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
          ModernButton(
            text: 'Confirmar',
            style: ModernButtonStyle.primary,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails(ReservationData reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(reservation.status),
                      _getStatusColor(reservation.status).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    reservation.clientName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detalles de la Reserva',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Cliente:', reservation.clientName),
            _buildDetailRow('Email:', reservation.clientEmail),
            _buildDetailRow('RUT:', reservation.clientRut),
            _buildDetailRow('Servicio:', reservation.serviceName),
            _buildDetailRow(
              'Fecha:',
              '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
            ),
            _buildDetailRow('Hora:', reservation.time),
            _buildDetailRow('Estado:', reservation.status),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Cerrar',
                style: ModernButtonStyle.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7f8c8d),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
        ],
      ),
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

class ReservationData {
  final String id;
  final String clientName;
  final String clientEmail;
  final String clientRut;
  final String serviceName;
  final DateTime date;
  final String time;
  final String status;

  ReservationData({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.clientRut,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
  });
}