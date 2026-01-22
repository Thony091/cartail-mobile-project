import 'package:flutter/material.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../domain/entities/reservation.dart';

class ReservationStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const ReservationStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final Future<bool> Function(bool confirm) onConfirmDismiss;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onConfirmDismiss,
    required this.onViewDetails,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF3498db);

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
        return onConfirmDismiss(direction == DismissDirection.startToEnd);
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
                        colors: [accentColor, accentColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        reservation.name[0].toUpperCase(),
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
                          reservation.name,
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
                ],
              ),

              const SizedBox(height: 16),

              // Detalles de la reserva
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.calendar_today,
                      reservation.reservationDate,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time,
                      reservation.reservationTime,
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
                      reservation.email,
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
                      onPressed: onViewDetails,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernButton(
                      text: 'Editar',
                      icon: Icons.edit,
                      style: ModernButtonStyle.primary,
                      onPressed: onEdit,
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
        Icon(icon, size: 16, color: const Color(0xFF7f8c8d)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7f8c8d)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground(
    Color color,
    IconData icon,
    Alignment alignment,
  ) {
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

}

class ReservationsEmptyState extends StatelessWidget {
  const ReservationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class SearchReservationDialog extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const SearchReservationDialog({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Buscar Reserva'),
      content: ModernInputField(
        hint: 'Nombre del cliente...',
        prefixIcon: const Icon(Icons.search),
        onChanged: onSearch,
      ),
      actions: [
        ModernButton(
          text: 'Cerrar',
          style: ModernButtonStyle.secondary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class FilterReservationDialog extends StatelessWidget {
  final String currentFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;

  const FilterReservationDialog({
    super.key,
    required this.currentFilter,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Filtrar por Estado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((status) {
          return RadioListTile<String>(
            title: Text(status),
            value: status,
            groupValue: currentFilter,
            activeColor: const Color(0xFF3498db),
            onChanged: (value) {
              if (value != null) {
                onFilterChanged(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class ReservationDetailDialog extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailDialog({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    const Color(0xFF3498db),
                    const Color(0xFF3498db).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  reservation.name[0].toUpperCase(),
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
          _buildDetailRow('Cliente:', reservation.name),
          _buildDetailRow('Email:', reservation.email),
          _buildDetailRow('RUT:', reservation.rut),
          _buildDetailRow('Servicio:', reservation.serviceName),
          _buildDetailRow('Fecha:', reservation.reservationDate),
          _buildDetailRow('Hora:', reservation.reservationTime),
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF2c3e50)),
            ),
          ),
        ],
      ),
    );
  }

}
