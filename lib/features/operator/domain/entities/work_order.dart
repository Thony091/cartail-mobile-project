/// Fases del proceso de trabajo de una orden
enum WorkPhase {
  /// Orden recibida, esperando recepcion del vehiculo/materiales
  pendingReception,

  /// Vehiculo/materiales recibidos, pendiente de revision
  received,

  /// En proceso de diagnostico/revision inicial
  diagnosis,

  /// Trabajo en progreso
  inProgress,

  /// En espera de repuestos o materiales adicionales
  waitingParts,

  /// Control de calidad
  qualityCheck,

  /// Trabajo completado, listo para entrega
  completed,

  /// Entregado al cliente
  delivered,

  /// Cancelado
  cancelled;

  String get displayName {
    switch (this) {
      case WorkPhase.pendingReception:
        return 'Pendiente de Recepcion';
      case WorkPhase.received:
        return 'Recibido';
      case WorkPhase.diagnosis:
        return 'En Diagnostico';
      case WorkPhase.inProgress:
        return 'En Progreso';
      case WorkPhase.waitingParts:
        return 'Esperando Repuestos';
      case WorkPhase.qualityCheck:
        return 'Control de Calidad';
      case WorkPhase.completed:
        return 'Completado';
      case WorkPhase.delivered:
        return 'Entregado';
      case WorkPhase.cancelled:
        return 'Cancelado';
    }
  }

  String get shortName {
    switch (this) {
      case WorkPhase.pendingReception:
        return 'Pendiente';
      case WorkPhase.received:
        return 'Recibido';
      case WorkPhase.diagnosis:
        return 'Diagnostico';
      case WorkPhase.inProgress:
        return 'En Progreso';
      case WorkPhase.waitingParts:
        return 'Esperando';
      case WorkPhase.qualityCheck:
        return 'QC';
      case WorkPhase.completed:
        return 'Completado';
      case WorkPhase.delivered:
        return 'Entregado';
      case WorkPhase.cancelled:
        return 'Cancelado';
    }
  }

  /// Orden de la fase en el flujo de trabajo
  int get order {
    switch (this) {
      case WorkPhase.pendingReception:
        return 0;
      case WorkPhase.received:
        return 1;
      case WorkPhase.diagnosis:
        return 2;
      case WorkPhase.inProgress:
        return 3;
      case WorkPhase.waitingParts:
        return 4;
      case WorkPhase.qualityCheck:
        return 5;
      case WorkPhase.completed:
        return 6;
      case WorkPhase.delivered:
        return 7;
      case WorkPhase.cancelled:
        return -1;
    }
  }
}

/// Tipo de trabajo/servicio
enum WorkType {
  detailing,
  mechanicalRepair,
  oilChange,
  tireService,
  paintJob,
  electrical,
  cameraInstallation,
  sensorInstallation,
  audioInstallation,
  accessoryInstallation,
  generalMaintenance,
  other;

  String get displayName {
    switch (this) {
      case WorkType.detailing:
        return 'Detailing';
      case WorkType.mechanicalRepair:
        return 'Reparacion Mecanica';
      case WorkType.oilChange:
        return 'Cambio de Aceite';
      case WorkType.tireService:
        return 'Servicio de Neumaticos';
      case WorkType.paintJob:
        return 'Pintura';
      case WorkType.electrical:
        return 'Sistema Electrico';
      case WorkType.cameraInstallation:
        return 'Instalacion de Camaras';
      case WorkType.sensorInstallation:
        return 'Instalacion de Sensores';
      case WorkType.audioInstallation:
        return 'Sistema de Audio';
      case WorkType.accessoryInstallation:
        return 'Instalacion de Accesorios';
      case WorkType.generalMaintenance:
        return 'Mantencion General';
      case WorkType.other:
        return 'Otro';
    }
  }

  String get icon {
    switch (this) {
      case WorkType.detailing:
        return 'cleaning_services';
      case WorkType.mechanicalRepair:
        return 'build';
      case WorkType.oilChange:
        return 'oil_barrel';
      case WorkType.tireService:
        return 'tire_repair';
      case WorkType.paintJob:
        return 'format_paint';
      case WorkType.electrical:
        return 'electrical_services';
      case WorkType.cameraInstallation:
        return 'videocam';
      case WorkType.sensorInstallation:
        return 'sensors';
      case WorkType.audioInstallation:
        return 'speaker';
      case WorkType.accessoryInstallation:
        return 'extension';
      case WorkType.generalMaintenance:
        return 'handyman';
      case WorkType.other:
        return 'miscellaneous_services';
    }
  }
}

/// Prioridad de la orden de trabajo
enum WorkPriority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case WorkPriority.low:
        return 'Baja';
      case WorkPriority.normal:
        return 'Normal';
      case WorkPriority.high:
        return 'Alta';
      case WorkPriority.urgent:
        return 'Urgente';
    }
  }
}

/// Registro de cambio de fase
class PhaseLog {
  final WorkPhase phase;
  final DateTime timestamp;
  final String? operatorId;
  final String? operatorName;
  final String? notes;

  const PhaseLog({
    required this.phase,
    required this.timestamp,
    this.operatorId,
    this.operatorName,
    this.notes,
  });
}

/// Informacion del vehiculo
class VehicleInfo {
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final int? mileage;
  final String? vin;

  const VehicleInfo({
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    this.mileage,
    this.vin,
  });

  String get fullName => '$brand $model $year';
}

/// Item de checklist para recepcion
class ChecklistItem {
  final String id;
  final String label;
  final String description;
  final String category;
  final bool isRequired;
  final bool isChecked;
  final String? notes;
  final List<String>? photoUrls;

  const ChecklistItem({
    required this.id,
    required this.label,
    this.description = '',
    required this.category,
    this.isRequired = false,
    this.isChecked = false,
    this.notes,
    this.photoUrls,
  });

  ChecklistItem copyWith({
    String? id,
    String? label,
    String? description,
    String? category,
    bool? isRequired,
    bool? isChecked,
    String? notes,
    List<String>? photoUrls,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      category: category ?? this.category,
      isRequired: isRequired ?? this.isRequired,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}

/// Orden de trabajo principal
class WorkOrder {
  final String id;
  final String ticketId;
  final String orderNumber;

  // Cliente
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;

  // Operario asignado
  final String? operatorId;
  final String? operatorName;

  // Tipo y descripcion
  final WorkType workType;
  final String title;
  final String description;
  final List<String> services;

  // Vehiculo
  final VehicleInfo vehicle;

  // Estado y fase
  final WorkPhase currentPhase;
  final WorkPriority priority;
  final List<PhaseLog> phaseHistory;

  // Checklist de recepcion
  final List<ChecklistItem> receptionChecklist;
  final bool receptionCompleted;
  final DateTime? receptionDate;
  final List<String> receptionPhotos;

  // Materiales/repuestos
  final List<String> requiredParts;
  final List<String> receivedParts;
  final bool allPartsReceived;

  // Tiempos
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? deliveredAt;
  final int? estimatedMinutes;

  // Costos
  final int estimatedCost;
  final int? finalCost;

  // Notas
  final String? operatorNotes;
  final String? clientNotes;

  const WorkOrder({
    required this.id,
    required this.ticketId,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.operatorId,
    this.operatorName,
    required this.workType,
    required this.title,
    required this.description,
    required this.services,
    required this.vehicle,
    required this.currentPhase,
    required this.priority,
    required this.phaseHistory,
    required this.receptionChecklist,
    required this.receptionCompleted,
    this.receptionDate,
    required this.receptionPhotos,
    required this.requiredParts,
    required this.receivedParts,
    required this.allPartsReceived,
    required this.createdAt,
    this.scheduledDate,
    this.startedAt,
    this.completedAt,
    this.deliveredAt,
    this.estimatedMinutes,
    required this.estimatedCost,
    this.finalCost,
    this.operatorNotes,
    this.clientNotes,
  });

  // Getters utiles
  bool get isAssigned => operatorId != null;
  bool get isPending => currentPhase == WorkPhase.pendingReception;
  bool get isInProgress =>
      currentPhase == WorkPhase.inProgress ||
      currentPhase == WorkPhase.diagnosis;
  bool get isCompleted => currentPhase == WorkPhase.completed;
  bool get isDelivered => currentPhase == WorkPhase.delivered;
  bool get isCancelled => currentPhase == WorkPhase.cancelled;
  bool get isWaiting => currentPhase == WorkPhase.waitingParts;

  /// Calcula el progreso como porcentaje (0.0 a 1.0)
  double get progressPercentage {
    if (isCancelled) return 0.0;
    if (isDelivered) return 1.0;

    const totalPhases = 7; // Desde pendingReception hasta delivered
    final currentOrder = currentPhase.order;
    return currentOrder / totalPhases;
  }

  /// Tiempo transcurrido desde el inicio
  Duration? get elapsedTime {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  /// Siguiente fase logica
  WorkPhase? get nextPhase {
    switch (currentPhase) {
      case WorkPhase.pendingReception:
        return WorkPhase.received;
      case WorkPhase.received:
        return WorkPhase.diagnosis;
      case WorkPhase.diagnosis:
        return WorkPhase.inProgress;
      case WorkPhase.inProgress:
        return allPartsReceived
            ? WorkPhase.qualityCheck
            : WorkPhase.waitingParts;
      case WorkPhase.waitingParts:
        return WorkPhase.inProgress;
      case WorkPhase.qualityCheck:
        return WorkPhase.completed;
      case WorkPhase.completed:
        return WorkPhase.delivered;
      case WorkPhase.delivered:
      case WorkPhase.cancelled:
        return null;
    }
  }

  /// Puede avanzar a la siguiente fase
  bool get canAdvance {
    if (currentPhase == WorkPhase.pendingReception) {
      return receptionCompleted;
    }
    return nextPhase != null;
  }
}
