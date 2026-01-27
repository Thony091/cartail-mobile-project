import 'package:portafolio_project/features/ticket/domain/entities/estado_ticket.dart';
import 'package:portafolio_project/features/ticket/domain/entities/importancia_ticket.dart';
import 'package:portafolio_project/features/ticket/domain/entities/urgencia_ticket.dart';


/// Entidad que representa un ticket en el sistema.
///
/// Los tickets pueden ser reservas, compras o pedidos que son
/// asignados a operarios para su gestión.
class Ticket {
  final int id;
  final String nombre;
  final String description;
  final DateTime? desde;
  final DateTime? hasta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int idServicio;
  final String? idUser;
  final String idReserva;
  final EstadoTicket estado;
  final ImportanciaTicket importancia;
  final UrgenciaTicket urgencia;
  
  Ticket({
    required this.id,
    required this.nombre,
    required this.description,
    required this.desde,
    required this.hasta,
    required this.createdAt,
    required this.updatedAt,
    required this.idServicio,
    required this.idUser,
    required this.idReserva,
    required this.estado,
    required this.importancia,
    required this.urgencia,
  });

  /// Crea una copia del ticket con los campos especificados modificados
  Ticket copyWith({
    int? id,
    String? nombre,
    String? description,
    DateTime? desde,
    DateTime? hasta,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? idServicio,
    String? idUser,
    String? idReserva,
    EstadoTicket? estado,
    ImportanciaTicket? importancia,
    UrgenciaTicket? urgencia,
  }) {
    return Ticket(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      description: description ?? this.description,
      desde: desde ?? this.desde,
      hasta: hasta ?? this.hasta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      idServicio: idServicio ?? this.idServicio,
      idUser: idUser ?? this.idUser,
      idReserva: idReserva ?? this.idReserva,
      estado: estado ?? this.estado,
      importancia: importancia ?? this.importancia,
      urgencia: urgencia ?? this.urgencia,
    );
  }
}
