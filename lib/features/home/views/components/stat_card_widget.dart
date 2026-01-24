import 'package:flutter/material.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_card.dart';
import 'dashboard_modals.dart';

enum DashboardModalType {
  services,
  reservations,
  works,
  tickets,
  messages,
  operators,
}

class StatCardWidget extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final DashboardModalType? modalType;
  final bool isEnabled;

  const StatCardWidget({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.modalType,
    this.isEnabled = true,
  });

  void _showModal(BuildContext context) {
    if (!isEnabled || modalType == null) return;

    Widget modal;
    switch (modalType!) {
      case DashboardModalType.services:
        modal = const ServicesDetailModal();
        break;
      case DashboardModalType.reservations:
        modal = const ReservationsDetailModal();
        break;
      case DashboardModalType.works:
        modal = const WorksDetailModal();
        break;
      case DashboardModalType.tickets:
        modal = const TicketsDetailModal();
        break;
      case DashboardModalType.messages:
        modal = const MessagesDetailModal();
        break;
      case DashboardModalType.operators:
        return; // Disabled for now
    }

    showDialog(
      context: context,
      builder: (context) => modal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && modalType != null ? () => _showModal(context) : null,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: ModernCard(
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              if (modalType != null && isEnabled) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: color.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}