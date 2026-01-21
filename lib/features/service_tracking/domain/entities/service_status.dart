/// Estado del servicio visible para el cliente
enum ServiceStatus {
  /// Servicio recibido y en cola
  received,

  /// En proceso de trabajo
  inProgress,

  /// Trabajo completado, pendiente de entrega
  ready,

  /// Entregado al cliente
  delivered;

  String get displayName {
    switch (this) {
      case ServiceStatus.received:
        return 'Recibido';
      case ServiceStatus.inProgress:
        return 'En Proceso';
      case ServiceStatus.ready:
        return 'Listo para Entrega';
      case ServiceStatus.delivered:
        return 'Entregado';
    }
  }

  String get description {
    switch (this) {
      case ServiceStatus.received:
        return 'Tu vehículo ha sido recibido y está en espera de atención';
      case ServiceStatus.inProgress:
        return 'Nuestro equipo está trabajando en tu vehículo';
      case ServiceStatus.ready:
        return 'El trabajo está completo. Puedes venir a recoger tu vehículo';
      case ServiceStatus.delivered:
        return 'Servicio completado y entregado';
    }
  }

  String get userFriendlyMessage {
    switch (this) {
      case ServiceStatus.received:
        return '¡Recibimos tu vehículo! Pronto comenzaremos a trabajar.';
      case ServiceStatus.inProgress:
        return '¡Estamos trabajando en tu vehículo! Te notificaremos cuando esté listo.';
      case ServiceStatus.ready:
        return '¡Tu vehículo está listo! Puedes venir a recogerlo.';
      case ServiceStatus.delivered:
        return '¡Gracias por confiar en nosotros! Esperamos verte pronto.';
    }
  }

  int get order {
    switch (this) {
      case ServiceStatus.received:
        return 1;
      case ServiceStatus.inProgress:
        return 2;
      case ServiceStatus.ready:
        return 3;
      case ServiceStatus.delivered:
        return 4;
    }
  }
}

/// Registro de actualización de estado
class StatusUpdate {
  final ServiceStatus status;
  final DateTime timestamp;
  final String? message;

  const StatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
  });
}

/// Información del vehículo para el cliente
class UserVehicleInfo {
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String color;

  const UserVehicleInfo({
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
  });

  String get fullName => '$brand $model $year';
}

/// Servicio solicitado por el usuario
class UserServiceRequest {
  final String id;
  final String orderNumber;

  // Información del servicio
  final String serviceName;
  final String serviceDescription;
  final List<String> includedItems;

  // Vehículo
  final UserVehicleInfo vehicle;

  // Estado actual
  final ServiceStatus currentStatus;
  final List<StatusUpdate> statusHistory;

  // Tiempos
  final DateTime requestedAt;
  final DateTime? estimatedCompletionDate;
  final DateTime? completedAt;

  // Costo
  final int estimatedCost;
  final int? finalCost;

  // Contacto del taller
  final String workshopPhone;
  final String? assignedOperatorName;

  const UserServiceRequest({
    required this.id,
    required this.orderNumber,
    required this.serviceName,
    required this.serviceDescription,
    required this.includedItems,
    required this.vehicle,
    required this.currentStatus,
    required this.statusHistory,
    required this.requestedAt,
    this.estimatedCompletionDate,
    this.completedAt,
    required this.estimatedCost,
    this.finalCost,
    required this.workshopPhone,
    this.assignedOperatorName,
  });

  // Getters útiles
  bool get isCompleted => currentStatus == ServiceStatus.delivered;
  bool get isReady => currentStatus == ServiceStatus.ready;
  bool get isActive =>
      currentStatus == ServiceStatus.received ||
      currentStatus == ServiceStatus.inProgress;

  double get progressPercentage {
    return currentStatus.order / 4.0;
  }

  Duration? get estimatedTimeRemaining {
    if (estimatedCompletionDate == null) return null;
    if (isCompleted || isReady) return Duration.zero;
    final remaining = estimatedCompletionDate!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
