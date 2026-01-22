import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_config_reservations_widgets.dart';
import '../providers/reservation_provider.dart';
import '../../domain/entities/reservation.dart';

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
    final reservationState = ref.watch(reservationProvider);
    final List<Reservation> reservations = reservationState.reservations;
    final int totalReservations = reservations.length;
    final int todayReservations =
        reservations.where((r) => _isToday(r.reservationDate)).length;

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Reservas',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
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
                        value: totalReservations.toString(),
                        label: 'Totales',
                        icon: Icons.pending,
                        color: const Color(0xFFf39c12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ReservationStatCard(
                        value: todayReservations.toString(),
                        label: 'Hoy',
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
                    reservations
                        .where((r) => _isToday(r.reservationDate))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(List<Reservation> reservations) {
    final filteredReservations = reservations.where((reservation) {
      final matchesSearch = reservation.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesSearch;
    }).toList();

    if (filteredReservations.isEmpty) {
      return const ReservationsEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reservationProvider.notifier).getReservations();
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
                if (!isConfirm) {
                  final confirmed = await _showConfirmDialog(
                    '¿Eliminar reserva?',
                    '¿Estás seguro de eliminar esta reserva?',
                  );
                  if (confirmed) {
                    await ref
                        .read(reservationProvider.notifier)
                        .deleteReservation(reservation.id);
                  }
                  return confirmed;
                }
                return false;
              },
              onViewDetails: () => _showReservationDetails(reservation),
              onEdit: () {},
            ),
          );
        },
      ),
    );
  }

  bool _isToday(String reservationDate) {
    final date = DateTime.tryParse(reservationDate);
    if (date == null) {
      return false;
    }
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

  void _showReservationDetails(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => ReservationDetailDialog(reservation: reservation),
    );
  }
}
