class TicketChecklistTemplate {
  final List<int> stateIds;
  final List<String> items;

  const TicketChecklistTemplate({
    required this.stateIds,
    required this.items,
  });
}

class TicketChecklistRegistry {
  static const List<TicketChecklistTemplate> templates = [
    TicketChecklistTemplate(
      stateIds: [1, 2],
      items: [
        'Servicio revisado',
        'Herramientas verificadas',
        'Condiciones iniciales validadas',
      ],
    ),
    TicketChecklistTemplate(
      stateIds: [3],
      items: [
        'Diagnostico realizado',
        'Trabajo iniciado',
        'Puntos criticos verificados',
      ],
    ),
    TicketChecklistTemplate(
      stateIds: [4, 5],
      items: [
        'Revision final completada',
        'Area de trabajo limpia',
        'Cliente informado',
      ],
    ),
  ];

  static List<String> templateForState(int stateId) {
    for (final template in templates) {
      if (template.stateIds.contains(stateId)) {
        return template.items;
      }
    }
    return const [];
  }
}
