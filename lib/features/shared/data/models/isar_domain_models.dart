import 'package:isar_community/isar.dart';

part 'isar_domain_models.g.dart';

@Collection()
class UserModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String backendId;

  @Index()
  late String email;

  late String nombre;
  late String rut;
  late String fechaNacimiento;
  late String telefono;
  late String direccion;
  String? passwordHash;
  String? imagenPerfil;
  String? bio;
  String role = 'user';

  @Index()
  late bool isSynced;

  @Index()
  late DateTime updatedAt;

  @Backlink(to: 'user')
  final reservations = IsarLinks<ReservationModel>();

  @Backlink(to: 'user')
  final tickets = IsarLinks<TicketModel>();
}

@Collection()
class ServiceModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String backendId;

  @Index()
  late String name;

  late String description;
  late int minPrice;
  late int maxPrice;
  late int durationMinutes;
  late bool requiresReservation;
  late bool isActive;
  late List<String> images;
  int? categoryId;

  @Index()
  late bool isSynced;

  @Index()
  late DateTime updatedAt;

  @Backlink(to: 'service')
  final reservations = IsarLinks<ReservationModel>();

  @Backlink(to: 'service')
  final slots = IsarLinks<SlotModel>();

  @Backlink(to: 'service')
  final tickets = IsarLinks<TicketModel>();
}

@Collection()
class VehicleModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String backendId;

  @Index()
  late String brand;

  late String model;
  late String year;
  late String trim;
  String? plate;

  @Index()
  late bool isSynced;

  @Index()
  late DateTime updatedAt;

  @Backlink(to: 'vehicle')
  final reservations = IsarLinks<ReservationModel>();
}

@Collection()
class SlotModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String backendId;

  @Index()
  late String date;

  late String startTime;
  late String endTime;

  @Index()
  late bool isSynced;

  @Index()
  late DateTime updatedAt;

  final service = IsarLink<ServiceModel>();

  @Backlink(to: 'slot')
  final reservations = IsarLinks<ReservationModel>();
}

@Collection()
class ReservationModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String backendId;

  @Index()
  late String reservationDate;

  late String reservationTime;
  late String name;
  late String rut;
  late String email;
  String vehiclePlate = '';
  String endTimeEstimated = '';
  String customerNotes = '';
  String mechanicNotes = '';
  bool reminder = false;
  int? statusId;
  int? serviceId;
  int? clientId;
  int? slotId;

  @Index()
  late bool isSynced;

  @Index()
  late DateTime updatedAt;

  final user = IsarLink<UserModel>();
  final service = IsarLink<ServiceModel>();
  final vehicle = IsarLink<VehicleModel>();
  final slot = IsarLink<SlotModel>();

  @Backlink(to: 'reservation')
  final tickets = IsarLinks<TicketModel>();
}

@Collection()
class TicketModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String backendId;

  /// Ticket indexa reservationId: la unica ruta hacia Reservation.
  @Index()
  late String reservationId;

  late String nombre;
  late String description;
  DateTime? desde;
  DateTime? hasta;
  late DateTime createdAt;
  late DateTime updatedAt;
  int? idServicio;
  String? idUser;
  String estado = 'pendiente';
  String importancia = 'media';
  String urgencia = 'media';

  @Index()
  late bool isSynced;

  final reservation = IsarLink<ReservationModel>();
  final service = IsarLink<ServiceModel>();
  final user = IsarLink<UserModel>();
}

@Collection()
class TicketLookupModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String key; // formato: "estado:1" o "importancia:1" o "urgencia:1"

  @Index()
  late String type; // "estado", "importancia", "urgencia"

  @Index()
  late int backendId;

  late String name;
  late DateTime updatedAt;
}

@Collection()
class TicketEstadoModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int backendId;

  @Index()
  late String name;

  late DateTime updatedAt;
}

@Collection()
class TicketImportanciaModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int backendId;

  @Index()
  late String name;

  late DateTime updatedAt;
}

@Collection()
class TicketUrgenciaModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int backendId;

  @Index()
  late String name;

  late DateTime updatedAt;
}
