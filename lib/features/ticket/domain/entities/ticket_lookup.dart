class TicketLookup {
  final int id;
  final String type; // 'estado', 'importancia', 'urgencia'
  final String name;
  final DateTime updatedAt;

  TicketLookup({
    required this.id,
    required this.type,
    required this.name,
    required this.updatedAt,
  });

  TicketLookup copyWith({
    int? id,
    String? type,
    String? name,
    DateTime? updatedAt,
  }) {
    return TicketLookup(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TicketLookup(id: $id, type: $type, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketLookup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}
