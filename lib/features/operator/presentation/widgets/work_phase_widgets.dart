import 'package:flutter/material.dart';
import '../../domain/entities/work_order.dart';

/// Widget que muestra el badge de fase actual
class WorkPhaseBadge extends StatelessWidget {
  final WorkPhase phase;
  final bool showIcon;
  final double fontSize;

  const WorkPhaseBadge({
    super.key,
    required this.phase,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getPhaseColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPhaseColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getPhaseIcon(),
              size: fontSize + 2,
              color: _getPhaseColor(),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            phase.shortName,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _getPhaseColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor() {
    switch (phase) {
      case WorkPhase.pendingReception:
        return const Color(0xFFf39c12);
      case WorkPhase.received:
        return const Color(0xFF9b59b6);
      case WorkPhase.diagnosis:
        return const Color(0xFF3498db);
      case WorkPhase.inProgress:
        return const Color(0xFF2980b9);
      case WorkPhase.waitingParts:
        return const Color(0xFFe67e22);
      case WorkPhase.qualityCheck:
        return const Color(0xFF1abc9c);
      case WorkPhase.completed:
        return const Color(0xFF27ae60);
      case WorkPhase.delivered:
        return const Color(0xFF2ecc71);
      case WorkPhase.cancelled:
        return const Color(0xFFe74c3c);
    }
  }

  IconData _getPhaseIcon() {
    switch (phase) {
      case WorkPhase.pendingReception:
        return Icons.hourglass_empty;
      case WorkPhase.received:
        return Icons.inventory_2;
      case WorkPhase.diagnosis:
        return Icons.search;
      case WorkPhase.inProgress:
        return Icons.construction;
      case WorkPhase.waitingParts:
        return Icons.pending_actions;
      case WorkPhase.qualityCheck:
        return Icons.verified;
      case WorkPhase.completed:
        return Icons.check_circle;
      case WorkPhase.delivered:
        return Icons.local_shipping;
      case WorkPhase.cancelled:
        return Icons.cancel;
    }
  }
}

/// Widget que muestra la prioridad
class WorkPriorityBadge extends StatelessWidget {
  final WorkPriority priority;

  const WorkPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority == WorkPriority.normal || priority == WorkPriority.low) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority == WorkPriority.urgent
                ? Icons.warning_amber
                : Icons.priority_high,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            priority.displayName.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority) {
      case WorkPriority.high:
        return const Color(0xFFe67e22);
      case WorkPriority.urgent:
        return const Color(0xFFe74c3c);
      default:
        return Colors.grey;
    }
  }
}

/// Widget de timeline vertical que muestra las fases
class WorkPhaseTimeline extends StatelessWidget {
  final WorkPhase currentPhase;
  final List<PhaseLog> phaseHistory;
  final bool compact;

  const WorkPhaseTimeline({
    super.key,
    required this.currentPhase,
    required this.phaseHistory,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final phases = WorkPhase.values
        .where((p) => p != WorkPhase.cancelled && p != WorkPhase.waitingParts)
        .toList();

    return Column(
      children: phases.asMap().entries.map((entry) {
        final index = entry.key;
        final phase = entry.value;
        final isLast = index == phases.length - 1;
        final isCompleted = phase.order < currentPhase.order;
        final isCurrent = phase == currentPhase;
        final log = phaseHistory.where((l) => l.phase == phase).firstOrNull;

        return _TimelineItem(
          phase: phase,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
          timestamp: log?.timestamp,
          notes: log?.notes,
          compact: compact,
        );
      }).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final WorkPhase phase;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final DateTime? timestamp;
  final String? notes;
  final bool compact;

  const _TimelineItem({
    required this.phase,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    this.timestamp,
    this.notes,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linea y circulo
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 28 : 20,
                  height: isCurrent ? 28 : 20,
                  decoration: BoxDecoration(
                    color: _getCircleColor(),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: _getCircleColor(), width: 3)
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: _getCircleColor().withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCompleted || isCurrent
                        ? Icons.check
                        : Icons.circle_outlined,
                    size: isCurrent ? 16 : 12,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? const Color(0xFF27ae60)
                          : const Color(0xFFe2e8f0),
                    ),
                  ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                bottom: compact ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          phase.displayName,
                          style: TextStyle(
                            fontSize: compact ? 14 : 16,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent
                                ? const Color(0xFF2c3e50)
                                : isCompleted
                                    ? const Color(0xFF27ae60)
                                    : const Color(0xFF95a5a6),
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498db),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ACTUAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (timestamp != null && !compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(timestamp!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                  ],
                  if (notes != null && notes!.isNotEmpty && !compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCircleColor() {
    if (isCurrent) return const Color(0xFF3498db);
    if (isCompleted) return const Color(0xFF27ae60);
    return const Color(0xFFbdc3c7);
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours}h';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Barra de progreso horizontal para la orden
class WorkProgressBar extends StatelessWidget {
  final double progress;
  final WorkPhase currentPhase;

  const WorkProgressBar({
    super.key,
    required this.progress,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentPhase.displayName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3498db),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFe2e8f0),
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (progress < 0.3) return const Color(0xFFf39c12);
    if (progress < 0.7) return const Color(0xFF3498db);
    return const Color(0xFF27ae60);
  }
}

/// Boton de accion para avanzar fase
class PhaseActionButton extends StatelessWidget {
  final WorkPhase currentPhase;
  final WorkPhase? nextPhase;
  final bool canAdvance;
  final VoidCallback? onAdvance;
  final bool isLoading;

  const PhaseActionButton({
    super.key,
    required this.currentPhase,
    required this.nextPhase,
    required this.canAdvance,
    this.onAdvance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (nextPhase == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canAdvance && !isLoading ? onAdvance : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFbdc3c7),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(_getButtonIcon()),
        label: Text(
          _getButtonText(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (nextPhase) {
      case WorkPhase.received:
        return const Color(0xFF9b59b6);
      case WorkPhase.diagnosis:
        return const Color(0xFF3498db);
      case WorkPhase.inProgress:
        return const Color(0xFF2980b9);
      case WorkPhase.qualityCheck:
        return const Color(0xFF1abc9c);
      case WorkPhase.completed:
        return const Color(0xFF27ae60);
      case WorkPhase.delivered:
        return const Color(0xFF2ecc71);
      default:
        return const Color(0xFF3498db);
    }
  }

  IconData _getButtonIcon() {
    switch (nextPhase) {
      case WorkPhase.received:
        return Icons.inventory_2;
      case WorkPhase.diagnosis:
        return Icons.search;
      case WorkPhase.inProgress:
        return Icons.play_arrow;
      case WorkPhase.qualityCheck:
        return Icons.verified;
      case WorkPhase.completed:
        return Icons.check_circle;
      case WorkPhase.delivered:
        return Icons.local_shipping;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getButtonText() {
    switch (nextPhase) {
      case WorkPhase.received:
        return 'Confirmar Recepcion';
      case WorkPhase.diagnosis:
        return 'Iniciar Diagnostico';
      case WorkPhase.inProgress:
        return 'Iniciar Trabajo';
      case WorkPhase.qualityCheck:
        return 'Enviar a Control de Calidad';
      case WorkPhase.completed:
        return 'Marcar como Completado';
      case WorkPhase.delivered:
        return 'Confirmar Entrega';
      default:
        return 'Avanzar';
    }
  }
}

/// Informacion del vehiculo en card
class VehicleInfoCard extends StatelessWidget {
  final VehicleInfo vehicle;

  const VehicleInfoCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Color(0xFF3498db),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.color,
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
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoItem(
                icon: Icons.confirmation_number,
                label: 'Patente',
                value: vehicle.licensePlate,
              ),
              const SizedBox(width: 24),
              if (vehicle.mileage != null)
                _InfoItem(
                  icon: Icons.speed,
                  label: 'Kilometraje',
                  value: '${vehicle.mileage} km',
                ),
            ],
          ),
          if (vehicle.vin != null) ...[
            const SizedBox(height: 12),
            _InfoItem(
              icon: Icons.qr_code,
              label: 'VIN',
              value: vehicle.vin!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF95a5a6)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF95a5a6),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tipo de trabajo badge
class WorkTypeBadge extends StatelessWidget {
  final WorkType workType;

  const WorkTypeBadge({super.key, required this.workType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF34495e).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: const Color(0xFF34495e),
          ),
          const SizedBox(width: 4),
          Text(
            workType.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34495e),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (workType) {
      case WorkType.detailing:
        return Icons.cleaning_services;
      case WorkType.mechanicalRepair:
        return Icons.build;
      case WorkType.oilChange:
        return Icons.oil_barrel;
      case WorkType.tireService:
        return Icons.tire_repair;
      case WorkType.paintJob:
        return Icons.format_paint;
      case WorkType.electrical:
        return Icons.electrical_services;
      case WorkType.cameraInstallation:
        return Icons.videocam;
      case WorkType.sensorInstallation:
        return Icons.sensors;
      case WorkType.audioInstallation:
        return Icons.speaker;
      case WorkType.accessoryInstallation:
        return Icons.extension;
      case WorkType.generalMaintenance:
        return Icons.handyman;
      case WorkType.other:
        return Icons.miscellaneous_services;
    }
  }
}
